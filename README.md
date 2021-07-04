# mpv-livetweet

Be that dick who tweets screenshots of their favourite anime spoiling everyone **without even having to leave your player!**

> _"whoa, integrated tweeting in movie players. The relentless march of progress"_ - **[@jons520](https://twitter.com/jons520/status/611668022902697984)**

> _"lol straight to twitter, your followers probably hate you"_ - **[ChrisK2](https://github.com/ChrisK2)**

> _"you're creating a monster"_ - **Cidoku**

### Features

- Text adding
- Multi-screenshot drifting
- Annie-May hashtag retrieving

## Usage

Create your config using the `get_keys` binary. A browser window will open and you'll get a code after clicking Authorize. Write the code into the terminal and a file called `mpv-livetweet.conf` will be created.

Create a folder called `script-opts` in your mpv config folder (the one containing `mpv.conf`) and move the `mpv-livetweet.conf` file into it.

Copy the `twitter` binary somewhere and copy its path.

Open `mpv-livetweet.conf` and configure the path to `curl` and to the `twitter` binary.

```
# On Windows 10 curl_path is C:\Windows\SysWOW64\curl.exe
curl_path=/path/to/curl
twitter_path=/path/to/twitter/binary
```

Copy `mpv-livetweet.lua` to the `scripts` folder in your mpv config folder.

The script tries to fetch the hashtag of the anime you're currently watching with the AniList API and appends it to the tweet text. If you don't want it to be fetched, set the `fetch_hashtag` option to `no` in the config file.

```
fetch_hashtag=no
```

By default the script sends tweets as a reply to the last tweet it sent during the same session. You can clear the last tweet ID by exiting the player, using the keybind, or you can disable this functionality by setting the `as_reply` option to `no` in the config file.

```
as_reply=no`
```

## Commands

| Shortcut  | When queue is empty            | With screenshots in queue |
| --------- | ------------------------------ | ------------------------- |
| **Alt+s** | Queue a screenshot             | Queue a screenshot        |
| **Alt+t** | Take a screenshot and tweet it | Tweet queued screenshots  |
| **Alt+c** | -                              | Delete queued screenshots |
| **Alt+x** | Clear the last tweet ID        | Clear the last tweet ID   |

The keybinds can be changed in the config file.

```
keybind_queue_screenshot=Alt+s
keybind_tweet=Alt+t
keybind_cancel=Alt+c
keybind_clear_reply=Alt+x
```

### From source

Acquire a consumer API key and secret from a twitter app, either from an existing one or by creating your own on https://developer.twitter.com/en/apps.

Compile the `twitter` and `get_keys` crates with Rust with the CONSUMER_KEY and CONSUMER_SECRET env variables set to the tokens you acquired.

```
CONSUMER_KEY=foo CONSUMER_SECRET=bar cargo build --release
```

Or on Powershell:

```
$ENV:CONSUMER_KEY="foo"; $ENV:CONSUMER_SECRET="bar"; cargo build --release
```

---

Excessive use of the script might cause butthurt and follower loss. Use responsibly and in small doses.
