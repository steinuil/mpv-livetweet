mpv-livetweet
=============

mpv-livetweet is a script for [mpv](http://mpv.io) that takes a screenshot and uploads it to your twitter account.

mpv-livetweet requires the [luatwit](https://github.com/darkstalker/LuaTwit) library.

Download the script here.

Usage
-----
Drop it in the lua scripts folder (usually `~/.mpv/lua/` or `~/.mpv/scripts/`), configure it and press `alt+w` to take a screenshot and tweet it.

Installation
------------
Install [LuaTwit](https://github.com/darkstalker/LuaTwit) with [luarocks](luarocks.org):

```
luarocks install luatwit
```
If that somehow doesn't work (it didn't for me), try

```
luarocks install luatwit '--only-server=http://luarocks.org/repositories/rocks-scm'
```

### Authenticating
Run get_keys.lua and follow the instructions to get your OAuth keys.

```
lua get_keys.lua
```
The keys should be printed on the console. It should look like this:

```
screen_name     steinuil
oauth_token     dasklhdnmpunexoibrunkljdsflkj191919409
oauth_token_secret      AIUSUMAOoq983092874bibiuwewqlknjSUXt
user_id 99999999
```
Save the oauth_token and oauth_token_secret somewhere.

### Configuring
Open the script with your editor and paste the oauth_token and oauth_token_secret where it tells you to.

Change the keybind to whatever you want and edit the folder to place the temp file in if needed.