-- Credentials
token = "Paste your oauth_token here"
token_secret = "Paste your oauth_token_secret here"

-- OS (remove the "--" in front of the line that matches your OS)
--os_name = "osx"
--os_name = "windows"
--os_name = "nix"

-- Set to false if you don't want the script to retrieve the hashtag
search_hashtag = true

-- Script - don't change anything below this point
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
	print("Getting AniList token...")
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

	local prefix = "http://anilist.co/api/anime/"
	local token = '&access_token=' .. anilist_keys["access_token"]
	local hashtag = ""
	local query = mp.get_property("filename")
	local ext = "%." .. mp.get_property("file-format")

	local subst = { ext, '%b[]', '%b()', '%d%d%a?%d?', '[sS]pecial[a-zA-Z]?' }
	for i, v in ipairs(subst) do query = query:gsub(v, "") end
	for i, v in ipairs({'_','[^a-zA-Z0-9]','%s+'}) do query = query:gsub(v, " ") end
	--print('Searching for "' .. query .. '"...')

	local request = http.request(prefix .. 'search/' ..  query .. '?' .. token)
	local results = json.decode(request)
	if results == nil then
		hashtag = ""
	elseif results["status"] == 401 then
		print("AniList token expired.")
		get_anilist_token()
		get_hashtag()
	else
		local anime_r = http.request(prefix ..  results[1]["id"] .. '?' .. token)
		local anime = json.decode(anime_r)
		hashtag = anime["hashtag"]
		if hashtag == nil then hashtag = "" end
	end
	return hashtag
end

function get_text(hashtag)
	print("Getting text input...")
	if os_name == "nix" then
		command = 'zenity --title mpv-livetweet --entry --text "Tweet body" ' ..
		'--entry-text " ' .. hashtag .. '"'
	elseif os_name == "osx" then
		command = 'osascript -e \'tell application "mpv" to set tweet to text returned of (disp' ..
			'lay dialog "" with title "Tweet body" default answer " ' .. hashtag .. '" buttons ' ..
			'"Tweet" default button 1)\' -e \' do shell script "echo " & quoted form of tweet'
	elseif os_name == "windows" then
		tmp_file = os.tmpname() .. ".vbs"
		local open_file = io.open(tmp_file, "w")
		open_file:write('WScript.StdOut.Write(InputBox(" ' .. hashtag .. '", "Tweet body"))')
		open_file:close()
		command = 'cscript //B //Nologo ' .. tmp_file
	end
	local text_in = io.popen(command)
	if os_name == "windows" then os.remove(tmp_file) end
	local body = text_in:read("*a")
	text_in:close()
	return body
end

function send(msg)
	print(msg)
	mp.osd_message(msg)
end

function cancel_tweet()
	if queue > 0 then
		send("Deleting screenshots in queue...")
		for i = 1, queue do os.remove(file .. i .. ".jpg") end
		queue = 0
	end
end

function queue_screenshot()
	if queue == 4 then
		send("Queue full, screenshot not taken.")
	else
		if queue == 0 then
			file = os.tmpname(); os.remove(file)
		end

		queue = queue + 1
		mp.commandv("screenshot_to_file", file .. queue .. ".jpg", "subtitles")

		if queue < 4 then
			send("Added screenshot " .. queue .. " to the queue.")
		else
			send("Queue full.")
		end
	end
end

function tweet(comment)
	if queue == 0 then queue_screenshot() end

	if search_hashtag and old_filename ~= mp.get_property("filename") then
		hashtag = get_hashtag()
	end

	if comment then
		body = get_text(hashtag)
	else
		if search_hashtag and hashtag ~= "" then print("Tweeting with hashtag " .. hashtag) end
		body = hashtag
	end

	mp.resume()

	local client = twitter.api.new(twitter_keys)
	media = {}
	for i = 1, queue do
		send("Uploading screenshot " .. i .. " of " .. queue .. "...")
		local headers = client:upload_media{
			media = utils.attach_file(file .. i .. ".jpg")
		}
		table.insert(media, headers["media_id_string"])
	end
	local tw, err = client:tweet{ media_ids = media, status = body }

	if err["status"] == "200 OK" then
		send("Screenshots tweeted!")
	else
		send("Something went wrong. Error code: " .. err["status"])
		for k, v in pairs(err) do print(k .. ": " .. v) end
	end

	for i = 1, queue do os.remove(file .. i .. ".jpg") end
	old_filename = mp.get_property("filename")
	queue = 0
end

old_filename, hashtag, queue = "", "", 0

mp.add_key_binding("Alt+a", "queue_screenshot", function() queue_screenshot() end)
mp.add_key_binding("Alt+w", "tweet", function() tweet(false) end)
mp.add_key_binding("Shift+Alt+w", "tweet_with_comment", function() tweet(true) end)
mp.add_key_binding("Shift+Alt+c", "cancel_tweet", function() cancel_tweet() end)
