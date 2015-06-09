-- Credentials
token = "Paste your oauth_token key here"
token_secret = "Paste your oauth_token_secret key here"

-- OS (remove the "--" in front of the line that matches your OS)
--local os = "osx"
--local os = "windows"
--local os = "nix"

-- Script
require 'luatwit'
require 'mp.utils'

local keys = {
	consumer_key = "7svu0BZBvEqCuA3XbCUbXoHPA",
	consumer_secret = "6U8RyN55VctvYtoh0mgBqUO8p2gLqQFvFP0MRDLhUhOEOMrZTi",
	oauth_token = token,
	oauth_token_secret = token_secret
}

function send(img_name, img_data, body)
	local client = luatwit.api.new(keys)
	local tw, headers = client:tweet_with_media{
		status = body, ["media[]"] = { filename = img_name, data = img_data }
	}
end

function tweet(text)
	local img_name = os.tmpname()
	os.remove(img_name)
	mp.commandv("screenshot_to_file", img_name, "subtitles")
	local open_img = io.open(img_name)
	local img_data = open_img:read("*a")
	open_img:close()
	os.remove(img_name)

	if text and os ~= "windows" then
		if os == "nix" then
			local text_in = io.popen('zenity --title mpv-livetweet --entry --text "Tweet body"')
		elseif os == "osx" then
			local text_in = io.popen('/usr/bin/osascript -e \'tell application "mpv" to set tweet to text returned of (display dialog "" with title "Tweet body" default answer "" buttons "Tweet" default button 1)\' -e \'do shell script "echo " & quoted form of tweet\'')
		--elseif os == "windows" then
		--	local text_in = io.popen('cscript //B //Nologo get-body.vbs')
		end

		local body = text_in:read("*a")
		text_in:close()
	else
		local body = ""
	end

	mp.resume()
	send(img_name, img_data, body)
	mp.osd_message("Screenshot tweeted!")
end

mp.add_key_binding("alt+w", "tweet", tweet(true))
mp.add_key_binding("shift+alt+w", "tweet_with_text", tweet(false))
