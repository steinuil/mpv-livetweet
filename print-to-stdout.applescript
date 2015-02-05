tell application "System Events"
	set tweet to text returned of (display dialog "" default answer "" buttons "Tweet" default button 1)
end tell
tell application "mpv" to activate
do shell script "echo " & quoted form of tweet