twitter = require 'luatwit'
base64 = require 'base64'

client = twitter.api.new {
  consumer_key: "7svu0BZBvEqCuA3XbCUbXoHPA",
  consumer_secret: base64.decode('NlU4UnlONTVWY3R2WXRvaDBtZ0JxVU84cDJnTH' ..
    'FRRnZGUDBNUkRMaFVoT0VPTXJaVGk='),
}

assert client\oauth_request_token!
print "Navigate to this url with your browser:
  #{client\oauth_authorize_url!}

  Enter the PIN:"

pin = assert(io.read!\match('%d+'), 'invalid pin')
token = assert(client\oauth_access_token { oauth_verifier: pin })

print 'Select your OS (linux/macos/windows):'

local os_name
while true
  os_name = assert io.read!
  if os_name != 'linux' and os_name != 'macos' and os_name != 'windows'
    print 'Invalid OS name, choose of the following: linux, macos, windows'
  else break

print 'Writing options to file'

options = "oauth_token = '#{token['oauth_token']}'
  oauth_token_secret = '#{token['oauth_token_secret']}'

  os_name = '#{os_name}'
  "

with io.open 'mpv-livetweet.lua', '*r'
  file = \read '*all'
  \write options .. file
  \close!
