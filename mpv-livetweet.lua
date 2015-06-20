-- Credentials
token = "Paste your oauth_token key here"
token_secret = "Paste your oauth_token_secret key here"

-- OS (remove the "--" in front of the line that matches your OS)
--local os_name = "osx"
--local os_name = "windows"
--local os_name = "nix"

-- Script
local twitter = require 'luatwit'
local utils = require 'luatwit.util'

local keys = {
	consumer_key = "7svu0BZBvEqCuA3XbCUbXoHPA",
	consumer_secret = "6U8RyN55VctvYtoh0mgBqUO8p2gLqQFvFP0MRDLhUhOEOMrZTi",
	oauth_token = token,
	oauth_token_secret = token_secret
}

function tweet(text)
	local file = os.tmpname()
	os.remove(file) -- os.tmpname() creates the file on some OS
	local img_name = file .. '.png'

	mp.commandv("screenshot_to_file", img_name, "subtitles")
	print("Screenshot taken.")

	if text then
		print("Getting text input...")
		if os_name == "nix" then
			text_in = io.popen('zenity --title mpv-livetweet ' ..
			                   '--entry --text "Tweet body"')
		elseif os_name == "osx" then
			text_in = io.popen('/usr/bin/osascript -e \'tell ' ..
				'application "mpv" to set tweet to text returned of' ..
				' (display dialog "" with title "Tweet body" default' ..
				' answer "" buttons "Tweet" default button 1)\' -e \'do ' ..
				'shell script "echo " & quoted form of tweet\'')
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
	local client = twitter.api.new(keys)
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
