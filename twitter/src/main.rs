use clap::Clap;

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
}

#[tokio::main]
async fn main() {
    let config = Config::parse();

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

    for handle in media_handles {
        draft.add_media(handle.id);
    }

    let resp = draft.send(&token).await.unwrap();

    print!(
        "https://twitter.com/{}/status/{}",
        resp.response.user.unwrap().screen_name,
        resp.response.id
    );
}
