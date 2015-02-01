local OAuth = require "OAuth"
local client = OAuth.new("7svu0BZBvEqCuA3XbCUbXoHPA", "6U8RyN55VctvYtoh0mgBqUO8p2gLqQFvFP0MRDLhUhOEOMrZTi", {
    RequestToken = "https://api.twitter.com/oauth/request_token", 
    AuthorizeUser = {"https://api.twitter.com/oauth/authorize", method = "GET"},
    AccessToken = "https://api.twitter.com/oauth/access_token"
}) 
local callback_url = "oob"
local values = client:RequestToken({ oauth_callback = callback_url })
local oauth_token = values.oauth_token  -- we'll need both later
local oauth_token_secret = values.oauth_token_secret

local tracking_code = "90210"   -- this is some random value
local new_url = client:BuildAuthorizationUrl({ oauth_callback = callback_url, state = tracking_code })

print("Navigate to this url with your browser, please...")
print(new_url)
print("\r\nOnce you have logged in and authorized the application, enter the PIN")

local oauth_verifier = assert(io.read("*n"))    -- read the PIN from stdin
oauth_verifier = tostring(oauth_verifier)       -- must be a string

-- now we'll use the tokens we got in the RequestToken call, plus our PIN
local client = OAuth.new("consumer_key", "consumer_secret", {
    RequestToken = "https://api.twitter.com/oauth/request_token", 
    AuthorizeUser = {"https://api.twitter.com/oauth/authorize", method = "GET"},
    AccessToken = "https://api.twitter.com/oauth/access_token"
}, {
    OAuthToken = oauth_token,
    OAuthVerifier = oauth_verifier
})
client:SetTokenSecret(oauth_token_secret)

local values, err, headers, status, body = client:GetAccessToken()
for k, v in pairs(values) do
    print(k,v)
end
