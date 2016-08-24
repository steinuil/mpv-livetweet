all:
	moonc -o mpv-livetweet.lua src/mpv-livetweet.moon
	moonc -o get-keys.lua src/get-keys.moon

clean:
	rm get-keys.lua mpv-livetweet.lua
