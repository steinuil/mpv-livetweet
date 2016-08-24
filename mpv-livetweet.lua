local twitter = require('luatwit')
local utils = require('luatwit.util')
local json = require('dkjson')
local http = require('socket.http')
local ltn12 = require('ltn12')
local base64 = require('base64')
local twitter_keys = {
  consumer_key = '7svu0BZBvEqCuA3XbCUbXoHPA',
  consumer_secret = base64.decode('NlU4UnlONTVWY3R2WXRvaDBtZ0JxVU84cDJnTH' .. 'FRRnZGUDBNUkRMaFVoT0VPTXJaVGk='),
  oauth_token = oauth_token,
  oauth_token_secret = oauth_token_secret
}
local anilist_keys = {
  client_id = 'steenuil-elxbm',
  client_secret = base64.decode('REI2UU42UTF2bGYyenJEN05PRERCVXRNMg==')
}
assert(os_name, 'No OS set!')
local old_filename, hashtag, queue = '', '', { }
local send
send = function(msg)
  print(msg)
  return mp.osd_message(msg)
end
local delete_files
delete_files = function()
  for _index_0 = 1, #queue do
    local file = queue[_index_0]
    os.remove(file)
  end
  queue = { }
end
local filename
filename = function()
  return mp.get_property('filename')
end
local send_tweet
send_tweet = function(body)
  do
    local _with_0 = twitter.api.new(twitter_keys)
    local media = { }
    for _index_0 = 1, #queue do
      local file = queue[_index_0]
      local headers, err = _with_0:upload_media({
        media = utils.attach_file(file)
      })
    end
    if #queue < 2 then
      media = media[1]
    end
    local _, err = _with_0:tweet({
      media_ids = media,
      status = body
    })
    if err['status'] == '200 OK' then
      _ = true, nil
    else
      _ = false, err
    end
    return _with_0
  end
end
local anilist_token
anilist_token = function()
  print('Retrieving AniList token')
  local args = 'grant_type=client_credentials&client_id=' .. anilist_keys['client_id'] .. '&client_secret=' .. anilist_keys['client_secret']
  local response = { }
  http.request({
    url = "http://anilist.co/api/auth/access_token?" .. tostring(args),
    method = 'POST',
    sink = ltn12.sink.table(response)
  })
  anilist_keys['token'] = json.decode(response[1])['access_token']
  return print('AniList token obtained')
end
local get_hashtag
get_hashtag = function()
  if anilist_keys['token'] == nil then
    anilist_token()
  end
  local query = filename()
  do
    local ext = '%.' .. mp.get_property('file-format')
    local s1 = {
      ext,
      '%b[]',
      '%b()',
      '%d%d%a?%d?',
      '[sS]pecial[a-zA-Z]?'
    }
    local s2 = {
      '_',
      '[^a-zA-Z0-9]',
      '%s+'
    }
    for _index_0 = 1, #s1 do
      local i, v = s1[_index_0]
      query = query:gsub(v, '')
    end
    for _index_0 = 1, #s2 do
      local i, v = s2[_index_0]
      query = query:gsub(v, ' ')
    end
  end
  local request
  request = function(action)
    return json.decode(http.request("http://anilist.co/api/anime/" .. tostring(action) .. "?access_token=" .. tostring(anilist_keys['token'])))
  end
  local results = request('search/')
  if results == nil then
    return ''
  elseif results['status'] == 401 then
    print('AniList token expired')
    anilist_token()
    return get_hashtag()
  else
    local h = request(results[1]['id']['hashtag'] or '')
  end
end
local queue_screenshot
queue_screenshot = function(msg)
  if msg == nil then
    msg = true
  end
  if #queue > 3 then
    return send('Queue full, screenshot not taken')
  else
    local shot
    do
      local f = os.tmpname()
      os.remove(f)
      local _ = f .. #queue + 1 .. '.jpg'
      shot = f
    end
    queue[#queue + 1] = shot
    mp.commandv('screenshot_to_file', shot, 'subtitles')
    if msg then
      return send("Queued screenshot " .. tostring(#queue) .. " of 4")
    end
  end
end
local cancel_tweet
cancel_tweet = function()
  if #queue > 0 then
    send('Deleting queued screenshots')
    return delete_files()
  end
end
local prompt_text
prompt_text = function(hashtag)
  local script
  if #hashtag == 0 then
    hashtag = " " .. tostring(hashtag)
  end
  print('Getting text input')
  local command
  local _exp_0 = os_name
  if 'linux' == _exp_0 then
    command = 'zenity --title mpv-livetweet --entry --text "Tweet body ' .. "--entry-text \"" .. tostring(hashtag) .. "\""
  elseif 'macos' == _exp_0 then
    command = "osascript -e 'set tweet to text returned of " .. '(display dialog "" with title "Tweet body" default answer "' .. hashtag .. '" buttons "Tweet" default button 1)\'' .. '-e \' do shell script "echo " & quoted form of tweet\''
  elseif 'windows' == _exp_0 then
    script = os.tmpname() .. '.vbs'
    do
      local _with_0 = io.open(script, 'w')
      _with_0:write("WScript.Stdout.Write(InputBox(\"" .. tostring(hashtag) .. "\", \"Tweet body\"))")
      _with_0:close()
    end
    command = "cscript //B //Nologo " .. tostring(script)
  end
  do
    local _with_0 = io.popen(command)
    local body = _with_0:read('*a')
    _with_0:close()
  end
  if os_name == 'windows' then
    os.remove(script)
  end
  return body
end
local tweet
tweet = function(comment)
  if comment == nil then
    comment = false
  end
  if #queue < 1 then
    queue_screenshot(false)
  end
  if old_filename ~= filename() then
    local ok, err = pcall(get_hashtag)
    if ok then
      hashtag = err
    else
      send('Unable to retrieve hashtag')
      for _index_0 = 1, #err do
        local k, v = err[_index_0]
        print(tostring(k) .. ": " .. tostring(v))
      end
      hashtag = ''
    end
  end
  local body
  if comment then
    while true do
      body = prompt_text(hashtag)
      if not (#body < 116) then
        break
      end
      send('Comment too long! Try again')
    end
  else
    body = hashtag
  end
  send("Tweeting " .. tostring(#queue) .. " screenshots with comment \"" .. tostring(body) .. "\"")
  do
    local ok, err = send_tweet(body)
    if ok then
      send('Screenshots tweeted!')
    else
      send('Something went wrong')
      for _index_0 = 1, #err do
        local k, v = err[_index_0]
        print(tostring(k) .. ": " .. tostring(v))
      end
    end
  end
  delete_files()
  old_filename = filename()
end
local commands = {
  {
    'Alt+a',
    'queue_screenshot',
    function()
      return queue_screenshot()
    end
  },
  {
    'Alt+w',
    'tweet',
    function()
      return tweet()
    end
  },
  {
    'Alt+W',
    'tweet_with_comment',
    function()
      return tweet(true)
    end
  },
  {
    'Alt+C',
    'cancel_tweet',
    function()
      return cancel_tweet()
    end
  }
}
for _index_0 = 1, #commands do
  local c = commands[_index_0]
  mp.add_key_binding(c[1], c[2], c[3])
end
