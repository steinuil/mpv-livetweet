-- Credentials
token = "Paste your oauth_token here"
token_secret = "Paste your oauth_token_secret here"

-- OS (remove the "--" in front of the line that matches your OS)
--local os_name = "osx"
--local os_name = "windows"
--local os_name = "nix"

-- Set to false if you don't want the script to retrieve the hashtag
local hashtag = true

-- Script
local twitter = require 'luatwit'
local utils = require 'luatwit.util'
local http = require 'socket.http'
local json = require 'dkjson'
local ltn12 = require 'ltn12'
local base64 = require 'base64'

local twitter_keys = {
	consumer_key = "7svu0BZBvEqCuA3XbCUbXoHPA",
	consumer_secret = base64.decode(
		'NlU4UnlONTVWY3R2WXRvaDBtZ0JxVU84cDJnTHFRRnZGUDBNUkRMaFVoT0VPTXJaVGk='),
	oauth_token = token,
	oauth_token_secret = token_secret
}

local anilist_keys = {
	client_id = "steenuil-elxbm",
	client_secret = base64.decode('REI2UU42UTF2bGYyenJEN05PRERCVXRNMg==')
}

function get_anilist_token()
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

	local anime_name = mp.get_property("filename")
	local query = string.gsub(anime_name, "%..*", "")
	query = string.gsub(query, "%[.-%].?", "")
	query = string.gsub(query, "%(.-%)", "")
	query = string.gsub(query, " %d%d ", "")
	query = string.gsub(query, "[^a-zA-Z0-9]", " ")

	local request = http.request(prefix .. 'anime/search/' ..
	                             query .. '?' .. token)
	local results = json.decode(request)
	if results == nil then hashtag = ""
	elseif results["status"] == 401 then
		print("AniList token expired, getting a new one...")
		get_anilist_token()
		get_hashtag()
	else
		local anime_r = http.request(prefix .. 'anime/' ..
		                             results[1]["id"] .. '?' .. token)
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


	if text then
		local yolo = ""
		if hashtag then yolo = get_hashtag() end
		print("Getting text input...")
		if os_name == "nix" then
			text_in = io.popen('zenity --title mpv-livetweet --entry --text' ..
			                   ' "Tweet body" --entry-text "' .. yolo .. '"')
		elseif os_name == "osx" then
			text_in = io.popen('/usr/bin/osascript -e \'tell ' ..
				'application "mpv" to set tweet to text returned of' ..
				' (display dialog "" with title "Tweet body" default' ..
				' answer "' .. yolo .. '" buttons "Tweet" default button 1)\' ' ..
				'-e \'do shell script "echo " & quoted form of tweet\'')
		elseif os_name == "windows" then
			text_in = io.popen('cscript //B //Nologo get-body.vbs')
		end

		body = text_in:read("*a")
		text_in:close()
	else
		body = ""
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
end

mp.add_key_binding("Alt+w", "tweet", function() tweet(false) end)
mp.add_key_binding("Shift+Alt+W", "tweet_text", function() tweet(true) end)
