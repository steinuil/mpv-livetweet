# mpv-livetweet

Be that dick who tweets screenshots of their favourite anime spoiling everyone **without even having to leave your player!**

> _"whoa, integrated tweeting in movie players. The relentless march of progress"_ - **[@jons520](https://twitter.com/jons520/status/611668022902697984)**

> _"lol straight to twitter, your followers probably hate you"_ - **[ChrisK2](https://github.com/ChrisK2)**

> _"you're creating a monster"_ - **Cidoku**

### Features

- Text adding
- Multi-screenshot drifting
- Annie-May hashtag retrieving

## Installation

Compile the twitter crate with Rust and copy the resulting `target/release/twitter` binary somewhere.

```
cargo build --release
```

Create a new Twitter app and get your consumer API key, consumer API secret and your own token key and secrets.

Create a folder called `script-opts` in your mpv config folder (the one containing `mpv.conf`) and create a file called `mpv-livetweet.conf` in it with these options:

```
curl_path=/path/to/curl
twitter_path=/path/to/twitter/binary
consumer_key=your app's consumer API key
consumer_secret=your app's consumer API secret
access_token_key=your access token key
access_token_secret=your access token secret
```

The script tries to fetch the hashtag of the anime you're currently watching with the AniList API and appends it to the tweet text. If you don't want it to be fetched, set the `fetch_hashtag` option to `no` in the config file.

```
fetch_hashtag=no
```

## Commands

| Shortcut  | When queue is empty            | With screenshots in queue |
| --------- | ------------------------------ | ------------------------- |
| **Alt+s** | Queue a screenshot             | Queue a screenshot        |
| **Alt+t** | Take a screenshot and tweet it | Tweet queued screenshots  |
| **Alt+c** | -                              | Delete queued screenshots |

The keybinds can be changed in the config file.

```
keybind_queue_screenshot=Alt+s
keybind_tweet=Alt+t
keybind_cancel=Alt+c
```

---

Excessive use of the script might cause butthurt and follower loss. Use responsibly and in small doses.
