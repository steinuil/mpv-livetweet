mpv-livetweet
=============
Be that dick who tweets screenshots of their favourite anime spoiling everyone **without even having to leave your player!**

> *"It's like Skyrim with a share button."* - **Kevic Adams**

mpv-livetweet requires the [luatwit](https://github.com/darkstalker/LuaTwit) library.

Download the script [here](https://github.com/steinuil/mpv-livetweet/archive/v0.2.2.zip).

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
  * Open the script with an editor and paste the oauth_token and oauth_token_secret *enclosed in double quotes* where it tells you to.
    * Change the temp directory values if needed.
  * Drop `mpv-livetweet.lua` in the lua scripts folder (usually `~/.mpv/lua/` or `~/.mpv/scripts/`)
  * Press `alt+w` to take a screenshot and tweet it

Troubleshooting
---------------
This script isn't exactly idiot-proof so if something doesn't work you'll either have to ask me or `${favourite-search-engine}` it and figure it out yourself.

### I can't install luarocks!
dunno lol

### The `get_keys.lua` script throws an error!
Please follow the instructions ***thoroughly***.

### When I start mpv it throws a bunch of errors in the console about luatwit!
Your luatwit installation is probably missing some files. Try to figure out where it's installed (for me it's `/usr/local/share/lua/5.2/`) and make sure all the files listed [in this folder](https://github.com/darkstalker/LuaTwit/tree/master/src) are in yours.

### The script tells me it tweeted the screenshot but nothing's happening!
Either your tokens are wrong or something weird's happening on twitter's side. Run `get_keys.lua` again, update your credentials and try again.

I'll try to make the script more aware of this kind of stuff so you don't have to curse at it too much.

### I just tweeted a hundred thousand screenshots while watching SaeKano and now my followers are halved!
Stop having shit taste.

TODO
----
  * Make the script read mail, as per the [law of software envelopment](http://catb.org/jargon/html/Z/Zawinskis-Law.html).
  * Make the script more verbose.
  * Auto-detect the name of the anime you're watching and tweet with the respective hashtag.
  * Integrate the AniList DB to retrieve said hashtag.
  * Add a window or something to write the text for the tweet for Linux and Windows, preferably something cross-platform that fixes the shitty Mac hack too.
  * Add support for multiple screenshots.

----
![image](http://www.wiliam.com.au/content/upload/blog/worksonmymachine.jpg)

**Warning**: might cause rectal pains to your followers. Use at your own risk.

Written by [@steinuil](https://twitter.com/steinuil)
