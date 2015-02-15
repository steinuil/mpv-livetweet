tell application "mpv"
	set tweet to text returned of (display dialog "" default answer "" buttons "Tweet" default button 1)
end tell
do shell script "echo " & quoted form of tweet