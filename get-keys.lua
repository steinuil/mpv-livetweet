#!/usr/bin/env lua
local twitter = require 'luatwit'
local base64 = require 'base64'

local client = twitter.api.new({
	consumer_key = "7svu0BZBvEqCuA3XbCUbXoHPA",
	consumer_secret = base64.decode('NlU4UnlONTVWY3R2WXRvaDBtZ0JxVU84cDJnTH' ..
		'FRRnZGUDBNUkRMaFVoT0VPTXJaVGk='),
})

assert(client:oauth_request_token())
print("Navigate to this url with your browser")
print(client:oauth_authorize_url())
print()
io.write("Enter the PIN: ")
local pin = assert(io.read():match("%d+"), "invalid pin")

local token = assert(client:oauth_access_token{ oauth_verifier = pin })
print()
print("Copy these keys and paste them in mpv-livetweet.lua")
print("oauth_token: " .. token["oauth_token"])
print("oauth_token_secret: " .. token["oauth_token_secret"])
