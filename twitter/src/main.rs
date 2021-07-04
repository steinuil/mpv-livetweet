use clap::Clap;
use serde::Serialize;

#[derive(Clap)]
struct Config {
    #[clap(long)]
    consumer_key: String,

    #[clap(long)]
    consumer_secret: String,

    #[clap(long)]
    access_token_key: String,

    #[clap(long)]
    access_token_secret: String,

    #[clap(long)]
    status: String,

    #[clap(long, multiple = true)]
    file: Vec<String>,

    #[clap(long)]
    reply_to: Option<u64>,
}

#[derive(Serialize)]
#[serde(tag = "type")]
enum TweetResult {
    Success { id: String, url: String },
    Failure { error: String },
}

async fn send_tweet(config: Config) -> Result<egg_mode::tweet::Tweet, egg_mode::error::Error> {
    let token = egg_mode::Token::Access {
        consumer: egg_mode::KeyPair::new(config.consumer_key, config.consumer_secret),
        access: egg_mode::KeyPair::new(config.access_token_key, config.access_token_secret),
    };

    let media_handles = futures::future::try_join_all(config.file.iter().map(|filename| {
        let token = token.clone();
        async move {
            let buf = tokio::fs::read(&filename).await?;
            egg_mode::media::upload_media(&buf, &egg_mode::media::media_types::image_jpg(), &token)
                .await
        }
    }))
    .await
    .unwrap();

    let mut draft = egg_mode::tweet::DraftTweet::new(config.status);

    draft.in_reply_to = config.reply_to;

    for handle in media_handles {
        draft.add_media(handle.id);
    }

    let tweet = draft.send(&token).await.unwrap().response;

    Ok(tweet)
}

#[tokio::main]
async fn main() {
    let config = Config::parse();

    let result = match send_tweet(config).await {
        Ok(tweet) => TweetResult::Success {
            id: tweet.id.to_string(),
            url: format!(
                "https://twitter.com/{}/status/{}",
                tweet.user.unwrap().screen_name,
                tweet.id
            ),
        },
        Err(error) => TweetResult::Failure {
            error: error.to_string(),
        },
    };

    print!("{}", serde_json::to_string(&result).unwrap())
}
