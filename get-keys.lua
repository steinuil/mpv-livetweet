local twitter = require('luatwit')
local base64 = require('base64')
local client = twitter.api.new({
  consumer_key = "7svu0BZBvEqCuA3XbCUbXoHPA",
  consumer_secret = base64.decode('NlU4UnlONTVWY3R2WXRvaDBtZ0JxVU84cDJnTH' .. 'FRRnZGUDBNUkRMaFVoT0VPTXJaVGk=')
})
assert(client:oauth_request_token())
print("Navigate to this url with your browser:\n  " .. tostring(client:oauth_authorize_url()) .. "\n\n  Enter the PIN:")
local pin = assert(io.read():match('%d+'), 'invalid pin')
local token = assert(client:oauth_access_token({
  oauth_verifier = pin
}))
print('Select your OS (linux/macos/windows):')
local os_name
while true do
  os_name = assert(io.read())
  if os_name ~= 'linux' and os_name ~= 'macos' and os_name ~= 'windows' then
    print('Invalid OS name, choose of the following: linux, macos, windows')
  else
    break
  end
end
print('Writing options to file')
local options = "oauth_token = '" .. tostring(token['oauth_token']) .. "'\n  oauth_token_secret = '" .. tostring(token['oauth_token_secret']) .. "'\n\n  os_name = '" .. tostring(os_name) .. "'\n  "
local file = ''
do
  local _with_0 = io.open('mpv-livetweet.lua', 'r')
  file = _with_0:read('*all')
  _with_0:close()
end
do
  local _with_0 = io.open('mpv-livetweet.lua', 'w')
  _with_0:write(options .. file)
  _with_0:close()
  return _with_0
end
