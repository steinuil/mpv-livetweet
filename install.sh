#!/bin/sh

LUADIR=$HOME/.mpv/lua/

printf "Compiling AppleScript... "
/usr/bin/osacompile -o "print-to-stdout.scpt" "print-to-stdout.applescript"
echo "Done"

echo "Checking for scripts directory..."
if [ ! -d $LUADIR ]; then
	printf "Directory not found, creating... "
	mkdir -p $LUADIR
	echo "Done"
else
	echo "Directory found."
fi

echo "Acquiring keys..."
/usr/local/bin/lua get_keys.lua

printf "Patching script for OS X... "
patch mpv-livetweet.lua < osx.patch
echo "Done"

echo "Opening script for editing, paste the oauth_token and oauth_token_secret you got in the previous step where it tells you to."
/usr/bin/open -e mpv-livetweet.lua
read -n1 -rsp "Save the file and press any key to continue... " key
printf "\n"

printf "Moving files to the scripts directory... "
mv "print-to-stdout.scpt" $LUADIR
mv "mpv-livetweet.lua" $LUADIR
echo "Done"
