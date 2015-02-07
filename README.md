mpv-livetweet
=============
**mpv-livetweet** is a script for [mpv](http://mpv.io) that takes a screenshot and uploads it to your twitter account.

mpv-livetweet requires the [luatwit](https://github.com/darkstalker/LuaTwit) library.

Download the script [here](https://github.com/steinuil/mpv-livetweet/archive/v0.2.1-osx.zip).

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
  
### OS X
  * Run install.sh and follow the instructions

	```
	sh install.sh
	```
  * Press **⌥W** to tweet a screenshot and **⇧⌥W** to tweet a screenshot with text.

### Other systems
  * Run get_keys.lua and follow the instructions to get your OAuth keys.

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
  * Open the script with an editor and paste the oauth_token and oauth_token_secret where it tells you to.
    * Change the temp directory values if needed.
  * Drop `mpv-livetweet.lua` in the lua scripts folder (usually `~/.mpv/lua/` or `~/.mpv/scripts/`)
  * Press `alt+w` to take a screenshot and tweet it

TODO
----
  * Auto-detect the name of the anime you're watching and tweet with the respective hashtag.
  * Integrate the AniList DB to retrieve said hashtag.
  * Add a window or something to write the text for the tweet for Linux and Windows, preferably something cross-platform that fixes the shitty Mac hack too.
  * Add support for multiple screenshots.

----
![image](http://www.wiliam.com.au/content/upload/blog/worksonmymachine.jpg)

**Warning**: might cause rectal pains to your followers. Use at your own risk.

Written by [@steinuil](https://twitter.com/steinuil)
