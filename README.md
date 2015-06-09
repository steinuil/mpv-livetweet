mpv-livetweet
=============
**Some library this script depends on decided to fuck up in luarocks so I currently have no means to test this, the script is probably broken.**

Be that dick who tweets screenshots of their favourite anime spoiling everyone **without even having to leave your player!**

> *"It's like Skyrim with a share button."* - **Kevic Adams**

Download the script [here](https://github.com/steinuil/mpv-livetweet/archive/text.zip).

mpv-livetweet requires the
### Requirements
  * [luatwit](https://github.com/darkstalker/LuaTwit)
  * [Zenity](https://wiki.gnome.org/Projects/Zenity) (only for Linux/BSD/etc)

Installation
------------
  * Run `get-keys.lua` and follow the instructions to get your OAuth keys.

	```
	lua get-keys.lua
	```
	The keys should be printed on the console. It should look like this:

	```
	screen_name     steinuil
	oauth_token     dasklhdnmpunexoibrunkljdsflkj191919409
	oauth_token_secret      AIUSUMAOoq983092874bibiuwewqlknjSUXt
	user_id 99999999
	```
  * Open `mpv-livetweet.lua` with a text editor and paste the `oauth_token` and `oauth_token_secret` *enclosed in double quotes* where it tells you to.
  * Uncomment the line matching your OS, save and close the script.
  * Move `mpv-livetweet.lua` to `~/.mpv/scripts` or `%APPDATA%/mpv/scripts` depending on your OS.
  * Press `alt+w` to tweet a screenshot and `shift+alt+w` to tweet a screenshot with text.

Troubleshooting
---------------
This script isn't exactly idiot-proof so if something doesn't work you'll either have to ask me or `#{favourite-search-engine}` it and figure it out yourself.

### The `get_keys.lua` script throws an error!
Please follow the instructions ***thoroughly***.

### I just tweeted a hundred thousand screenshots while watching SaeKano and now my followers are halved!
Stop having shit taste.

TODO
----
  - [ ] Make the script read mail, as per the [law of software envelopment](http://catb.org/jargon/html/Z/Zawinskis-Law.html).
  - [ ] Make the script more verbose.
  - [ ] Auto-detect the name of the anime you're watching and tweet with the respective hashtag.
  - [ ] Integrate the AniList DB to retrieve said hashtag.
  - [X] Use [yad](https://code.google.com/p/yad/) to display a window for the tweet body on Linux.
    * [X] Come up with something similar for Windows. Maybe a simple C# program?
  - [ ] Add support for multiple screenshots.

----
![image](http://www.wiliam.com.au/content/upload/blog/worksonmymachine.jpg)

If it doesn't work on yours, file an issue or bug me on twitter [@steinuil](https://twitter.com/steinuil)

**Warning**: might cause anal pain to your followers. Use at your own risk.
