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

function send(img_name, img_data, body)
	local client = twitter.api.new(keys)
	local media, err = client:upload_media{
		media = assert(utils.attach_file(img_name))
	}
	local tw, err = media:tweet{ status = body }
end

function tweet(text)
	local img_name = os.tmpname() .. ".png"
	os.remove(img_name)
	mp.commandv("screenshot_to_file", img_name, "subtitles")
	local open_img = io.open(img_name)
	local img_data = open_img:read("*a")
	open_img:close()

	if text then
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
	send(img_name, img_data, body)
	os.remove(img_name)
	mp.osd_message("Screenshot tweeted!")
end

function tweet_no_text() tweet(false) end
function tweet_text() tweet(true) end

mp.add_key_binding("Alt+w", "tweet", tweet_no_text)
mp.add_key_binding("Shift+Alt+W", "tweet_text", tweet_text)
