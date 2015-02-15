-- Options
token = "Paste the oauth_token key here"
token_secret = "Paste the oauth_token_secret key here"

shot = "/tmp/shot.png"	-- edit this only if you're using windows

-- Script
local twitter = require 'luatwit'
local mputils = require 'mp.utils'

local keys = {
	consumer_key = "7svu0BZBvEqCuA3XbCUbXoHPA",
	consumer_secret = "6U8RyN55VctvYtoh0mgBqUO8p2gLqQFvFP0MRDLhUhOEOMrZTi",
	oauth_token = token,
	oauth_token_secret = token_secret
}

function tweet()
	mp.commandv("screenshot_to_file", shot, "subtitles")
	local openshot = io.open(shot)
	local img_data = openshot:read("*a")
	openshot:close()
	os.remove(shot)

	mp.resume()

	local client = twitter.new(keys)
	local tw, headers = client:tweet_with_media{
		status = "", ["media[]"] = {
			filename = shot,
			data = img_data,
		},
	}
	mp.osd_message("Screenshot tweeted!")
end

mp.add_key_binding("alt+w", "tweet", function() tweet() end)
