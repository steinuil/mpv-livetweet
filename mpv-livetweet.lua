-- Credentials
token = "Paste your oauth_token here"
token_secret = "Paste your oauth_token_secret here"

-- OS (remove the "--" in front of the line that matches your OS)
--local os_name = "osx"
--local os_name = "windows"
--os_name = "nix"

-- Set to false if you don't want the script to retrieve the hashtag
search_hashtag = true

-- Script
local twitter = require 'luatwit'
local base64 = require 'base64'
local utils = require 'luatwit.util'
local http = require 'socket.http'
local json = require 'dkjson'
local ltn12 = require 'ltn12'

local twitter_keys = {
	consumer_key = "7svu0BZBvEqCuA3XbCUbXoHPA",
	consumer_secret = base64.decode('NlU4UnlONTVWY3R2WXRvaDBtZ0JxVU84cDJnTH' ..
		'FRRnZGUDBNUkRMaFVoT0VPTXJaVGk='),
	oauth_token = token,
	oauth_token_secret = token_secret
}

local anilist_keys = {
	client_id = "steenuil-elxbm",
	client_secret = base64.decode('REI2UU42UTF2bGYyenJEN05PRERCVXRNMg==')
}

function get_anilist_token()
	print("Getting an AniList token...")
	local args = 'grant_type=client_credentials&client_id=' ..
	             anilist_keys["client_id"] .. '&client_secret=' ..
				 anilist_keys["client_secret"]
	local response = {}

	local res, code, head = http.request{
		url = 'http://anilist.co/api/auth/access_token?' .. args,
		method = "POST",
		sink = ltn12.sink.table(response)
	}

	local table = json.decode(response[1])
	anilist_keys["access_token"] = table["access_token"]
	print("AniList token obtained.")
end

function get_hashtag()
	if anilist_keys["access_token"] == nil then get_anilist_token() end

	local prefix = "http://anilist.co/api/"
	local token = '&access_token=' .. anilist_keys["access_token"]
	local hashtag = ""
	local filename = mp.get_property("filename")
	local ext = "%." .. mp.get_property("file-format")

	local subst = { ext, '%b[]', '%b()', '%d%d%a?%d?', '[sS]pecial[a-zA-Z]?' }
	local query = filename:gsub('_', " ")
	for i, v in ipairs(subst) do query = query:gsub(v, "") end
	for i, v in ipairs({'[^a-zA-Z0-9]','%s+'}) do query = query:gsub(v, " ") end
	--print('Searching for "' .. query .. '"...')

	local request = http.request(prefix .. 'anime/search/' ..  query .. '?' .. token)
	local results = json.decode(request)
	if results == nil then hashtag = ""
	elseif results["status"] == 401 then
		print("AniList token expired.")
		get_anilist_token()
		get_hashtag()
	else
		local anime_r = http.request(prefix .. 'anime/' ..  results[1]["id"] .. '?' .. token)
		local anime = json.decode(anime_r)
		hashtag = anime["hashtag"]
		if hashtag == nil then hashtag = "" end
	end
	return hashtag
end

function tweet(text)
	local file = os.tmpname()
	os.remove(file) -- os.tmpname() creates the file on some OS
	local img_name = file .. '.png'

	mp.commandv("screenshot_to_file", img_name, "subtitles")
	print("Screenshot taken.")

	if search_hashtag and old_filename ~= mp.get_property("filename") then hashtag = get_hashtag() end
	if text then
		print("Getting text input...")
		if os_name == "nix" then
			text_in = io.popen('zenity --title mpv-livetweet --entry --text' ..
			                   ' "Tweet body" --entry-text " ' .. hashtag .. '"')
		elseif os_name == "osx" then
			text_in = io.popen('/usr/bin/osascript -e \'tell application "mpv" to set tweet to ' ..
				'text returned of (display dialog "" with title "Tweet body" default answer " ' ..
				hashtag .. '" buttons "Tweet" default button 1)\' -e \'do shell script "echo " ' ..
				'& quoted form of tweet\'')
		elseif os_name == "windows" then
			local tmp_file = os.tmpname() .. ".vbs"
			local open_file = io.open(tmp_file, "w")
			open_file:write('WScript.StdOut.Write(InputBox(" ' .. hashtag .. '", "Tweet body"))')
			open_file:close()
			text_in = io.popen('cscript //B //Nologo ' .. tmp_file)
			os.remove(tmp_file)
		end

		body = text_in:read("*a")
		text_in:close()
	else
		if search_hashtag and hashtag ~= "" then print("Tweeting with hashtag " .. hashtag) end
		body = hashtag
	end
	mp.resume()

	print("Uploading screenshot...")
	local client = twitter.api.new(twitter_keys)
	local media, err = client:upload_media{
		media = assert(utils.attach_file(img_name))
	}
	local tw, err = media:tweet{ status = body }

	if err["status"] == "200 OK" then
		mp.osd_message("Screenshot tweeted!")
		print("Screenshot tweeted!")
	else
		mp.osd_message("Screenshot not tweeted, check the console for errors")
		print("Something went wrong. Error code: " .. err["status"])
		for k, v in pairs(err) do print(k .. ": " .. v) end
	end
	os.remove(img_name)
	old_filename = mp.get_property("filename")
end

old_filename = ""
hashtag = ""

mp.add_key_binding("Alt+w", "tweet", function() tweet(false) end)
mp.add_key_binding("Shift+Alt+W", "tweet_text", function() tweet(true) end)
