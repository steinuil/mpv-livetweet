-- Setting up
twitter = require 'luatwit'
utils   = require 'luatwit.util'
json    = require 'dkjson'
http    = require 'socket.http'
ltn12   = require 'ltn12'
base64  = require 'base64'

twitter_keys = {
  consumer_key: '7svu0BZBvEqCuA3XbCUbXoHPA',
	consumer_secret: base64.decode('NlU4UnlONTVWY3R2WXRvaDBtZ0JxVU84cDJnTH' ..
		'FRRnZGUDBNUkRMaFVoT0VPTXJaVGk='),
	oauth_token: oauth_token,
	oauth_token_secret: oauth_token_secret
}

anilist_keys = {
  client_id: 'steenuil-elxbm',
	client_secret: base64.decode('REI2UU42UTF2bGYyenJEN05PRERCVXRNMg==')
}

assert os_name, 'No OS set!'
old_filename, hashtag, queue = '', '', {}

-- Utility functions
send = (msg) ->
  print msg
  mp.osd_message msg

delete_files = ->
  os.remove file for file in *queue
  queue = {}

filename = ->
  mp.get_property 'filename'

-- API stuffs
--- Twitter
send_tweet = (body) ->
  with twitter.api.new twitter_keys
    media = {}

    for file in *queue
      headers, err = \upload_media {
        media: utils.attach_file file
      }

    media = media[1] if #queue < 2

    _, err = \tweet { media_ids: media, status: body }

    if err['status'] == '200 OK'
      true, nil
    else
      false, err

--- AniList
anilist_token = ->
  print 'Retrieving AniList token'

  args = 'grant_type=client_credentials&client_id=' ..
    anilist_keys['client_id'] .. '&client_secret=' ..
    anilist_keys['client_secret']
  response = {}

  http.request {
    url: "http://anilist.co/api/auth/access_token?#{args}",
    method: 'POST',
    sink: ltn12.sink.table response
  }

  anilist_keys['token'] = json.decode(response[1])['access_token']

  print 'AniList token obtained'

get_hashtag = (using nil) ->
  anilist_token! if anilist_keys['token'] == nil
  query = filename!

  with query
    ext = '%.' .. mp.get_property 'file-format'
    s1 = { ext, '%b[]', '%b()', '%d%d%a?%d?', '[sS]pecial[a-zA-Z]?' }
    s2 = { '_', '[^a-zA-Z0-9]', '%s+' }
    for i, v in *s1
      query = \gsub v, ''
    for i, v in *s2
      query = \gsub v, ' '

  request = (action) ->
    json.decode(
      http.request(
        "http://anilist.co/api/anime/#{action}" ..
        "?access_token=#{anilist_keys['token']}"))

  results = request 'search/'
  if results == nil
    ''
  elseif results['status'] == 401
    print 'AniList token expired'
    anilist_token!
    get_hashtag!
  else
    h = request results[1]['id']['hashtag'] or ''

-- Dirty stuff
--- Helper functions
queue_screenshot = (msg=true) ->
  if #queue > 3
    send 'Queue full, screenshot not taken'

  else
    shot = with f = os.tmpname!
      os.remove f
      f .. #queue + 1 .. '.jpg'

    queue[#queue + 1] = shot

    mp.commandv 'screenshot_to_file', shot, 'subtitles'
    send "Queued screenshot #{#queue} of 4" if msg

cancel_tweet = ->
  if #queue > 0
    send 'Deleting queued screenshots'
    delete_files!

--- Ugly shit
prompt_text = (hashtag using nil) ->
  local script

  hashtag = " #{hashtag}" if #hashtag == 0
  print 'Getting text input'

  command = switch os_name
    when 'linux'
      'zenity --title mpv-livetweet --entry --text "Tweet body ' ..
      "--entry-text \"#{hashtag}\""

    when 'macos'
      "osascript -e 'set tweet to text returned of " ..
      '(display dialog "" with title "Tweet body" default answer "' ..
      hashtag .. '" buttons "Tweet" default button 1)\'' ..
      '-e \' do shell script "echo " & quoted form of tweet\''

    when 'windows'
      script = os.tmpname! .. '.vbs'
      with io.open script, 'w'
        \write "WScript.Stdout.Write(InputBox(\"#{hashtag}\", \"Tweet body\"))"
        \close!

      "cscript //B //Nologo #{script}"

  with io.popen command
    body = \read '*a'
    \close!

  os.remove script if os_name == 'windows'

  return body

tweet = (comment=false) ->
  queue_screenshot false if #queue < 1

  hashtag = if old_filename != filename!
    ok, err = pcall get_hashtag
    if ok
      err
    else
      send 'Unable to retrieve hashtag'
      print "#{k}: #{v}" for k,v in *err
      ''

  local body

  if comment
    while true
      body = prompt_text hashtag
      break unless #body < 116
      send 'Comment too long! Try again'
  else
    body = hashtag

  send "Tweeting #{#queue} screenshots with comment \"#{body}\""

  with ok, err = send_tweet body
    if ok
      send 'Screenshots tweeted!'
    else
      send 'Something went wrong'
      print "#{k}: #{v}" for k, v in *err

  delete_files!
  old_filename = filename!

-- Assignments
commands = {
  { 'Alt+a', 'queue_screenshot', -> queue_screenshot! },
  { 'Alt+w', 'tweet', -> tweet! },
  { 'Alt+W', 'tweet_with_comment', -> tweet true },
  { 'Alt+C', 'cancel_tweet', -> cancel_tweet! }
}

for c in *commands
  mp.add_key_binding c[1], c[2], c[3]
