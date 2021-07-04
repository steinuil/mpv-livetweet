local mp = require("mp")
local mp_options = require("mp.options")
local utils = require("mp.utils")

local options = {
  keybind_queue_screenshot = "Alt+s",
  keybind_tweet = "Alt+t",
  keybind_cancel = "Alt+c",
  keybind_clear_reply = "Alt+x",
  fetch_hashtag = true,
  as_reply = true,
  curl_path = "",
  twitter_path = "",
  consumer_key = "",
  consumer_secret = "",
  access_token_key = "",
  access_token_secret = "",
}

mp_options.read_options(options, "mpv-livetweet")

-- Utils

local function trim(str)
  str = str:gsub('^%s+', '')
  str = str:gsub('%s+$', '')
  return str
end

local function escape(str)
  str = str:gsub('\\', '\\\\')
  str = str:gsub('"', '\\"')
  return str
end

-- Get tweet input

local USER_INPUT_COUNTER = 1

-- sends a request to ask the user for input using formatted options provided
-- creates a script message to recieve the response and call fn
local function get_user_input(fn, options)
  options = options or {}
  local name = mp.get_script_name()
  local response_string = name.."/__user_input_request/"..USER_INPUT_COUNTER
  USER_INPUT_COUNTER = USER_INPUT_COUNTER + 1

  -- create a callback for user-input to respond to
  mp.register_script_message(response_string, function(input, err)
    mp.unregister_script_message(response_string)
    fn(err == "" and input or nil, err)
  end)

  -- send the input command
  mp.commandv("script-message-to", "user_input", "request-user-input",
    response_string,
    name .. '/' .. (options.id or ""),      -- id code for the request
    "["..(options.source or name).."] "..(options.request_text or options.text or ("requesting user input:")),
    options.default_input or "",
    options.queueable and "1" or "",
    options.replace and "1" or ""
  )
end

local function system(args)
  local cmd = io.popen(args, "r")
  local body = cmd:read('*a')
  cmd:close()
  return body
end

-- Fetch hashtag from AniList

local SCREENSHOT_QUEUE = {}
local SCREENSHOT_LIMIT = 4

local function approximate_show_name()
  local patterns_to_remove = {
    "%.%a+$", 			-- extension
    "%b[]", 				-- anything between brackets
    "%b()", 				-- anything between parenthesis
    "%d%d%a?%d?", 	-- episode number and version
    "[sS]pecial%a?"
  }
  local patterns_to_clear = { '_', '[^a-zA-Z0-9]', '%s+' }

  local query = mp.get_property("filename")

  for _, pattern in ipairs(patterns_to_remove) do
    query = query:gsub(pattern, '')
  end
  for _, pattern in ipairs(patterns_to_clear) do
    query = query:gsub(pattern, ' ')
  end

  return trim(query)
end

local HASHTAG_QUERY = 'query ($name: String) { Media(search: $name, type: ANIME) { hashtag } }'

local HASHTAGS_CACHE = {}

local function get_show_hashtag()
  local query = approximate_show_name()

  if HASHTAGS_CACHE[query] then
    return HASHTAGS_CACHE[query]
  end

  local body = utils.format_json({
    query = HASHTAG_QUERY,
    variables = { name = query },
  })

  local response = utils.parse_json(system(
    options.curl_path ..
    " -s" ..
    " -X POST" ..
    ' -H "Content-Type: application/json"' ..
    ' -H "Accept: application/json"' ..
    ' --data "' .. escape(body) .. '"' ..
    " https://graphql.anilist.co/"
  ))

  local hashtag =
    response
    and response.data
    and response.data.Media
    and response.data.Media.hashtag

  if hashtag ~= nil then
    HASHTAGS_CACHE[query] = hashtag
  end

  return hashtag
end

-- Handle screenshot files

local function file_exists(name)
  local f = io.open(name, "r")
  if f == nil then return false end
  f:close()
  return true
end

local function queue_screenshot()
  if #SCREENSHOT_QUEUE >= SCREENSHOT_LIMIT then
    mp.osd_message("Queue full, screenshot not taken")
    return
  end

  local shot = "mpv-livetweet-screenshot-" .. tostring(os.time()) .. ".jpg"
  if file_exists(shot) then
    mp.commandv("File already exists, screenshot not taken")
    return
  end

  SCREENSHOT_QUEUE[#SCREENSHOT_QUEUE + 1] = shot

  mp.commandv("screenshot_to_file", shot, "subtitles")
  mp.osd_message("Queued screenshot " .. tostring(#SCREENSHOT_QUEUE) .. " of 4")
end

local function delete_queued_screenshots()
  for _, shot in ipairs(SCREENSHOT_QUEUE) do
    os.remove(shot)
  end
  SCREENSHOT_QUEUE = {}
end

mp.register_event('shutdown', delete_queued_screenshots)

-- Tweet

local LAST_TWEET_ID = nil

local function clear_reply()
  if options.as_reply then
    mp.osd_message("The next tweet will not be a reply")
    LAST_TWEET_ID = nil
  end
end

local function send_tweet(text)
  local cmd = options.twitter_path ..
    " --consumer-key " .. options.consumer_key ..
    " --consumer-secret " .. options.consumer_secret ..
    " --access-token-key " .. options.access_token_key ..
    " --access-token-secret " .. options.access_token_secret ..
    ' --status "' .. escape(text) .. '"'

  if options.as_reply and LAST_TWEET_ID ~= nil then
    cmd = cmd .. " --reply-to " .. tostring(LAST_TWEET_ID)
  end

  for _, filename in ipairs(SCREENSHOT_QUEUE) do
    cmd = cmd .. ' --file "' .. escape(filename) .. '"'
  end

  return utils.parse_json(system(cmd))
end

local function tweet()
  local hashtag = options.fetch_hashtag and get_show_hashtag() or nil

  if #SCREENSHOT_QUEUE == 0 then
    queue_screenshot()
  end

  local input_text = "Tweeting with " .. tostring(#SCREENSHOT_QUEUE) .. " screenshots"
  if options.as_reply and LAST_TWEET_ID ~= nil then
    input_text = input_text .. " replying to tweet ID " .. tostring(LAST_TWEET_ID)
  end

  get_user_input(
    function(text)
      if text ~= nil then
        local result = send_tweet(trim(text))

        if result.type == "Success" then
          delete_queued_screenshots()
          LAST_TWEET_ID = result.id
          mp.osd_message("Tweet posted to " .. result.url)
        else
          mp.osd_message("Error: " .. result.error)
        end
      end
    end,
    {
      text = input_text,
      default_input = hashtag and (' ' .. hashtag)
    }
  )
end

-- Cancel

local function cancel()
  if #SCREENSHOT_QUEUE == 0 then return end
  mp.osd_message("Deleting queued screenshots")
  delete_queued_screenshots()
end

-- Register keybindings

mp.add_key_binding(options.keybind_queue_screenshot, queue_screenshot)
mp.add_key_binding(options.keybind_tweet, tweet)
mp.add_key_binding(options.keybind_cancel, cancel)
mp.add_key_binding(options.keybind_clear_reply, clear_reply)
