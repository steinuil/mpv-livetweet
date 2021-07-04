use clap::Clap;
use tokio::io::AsyncBufReadExt;

#[derive(Clap)]
struct Config {
    #[clap(long, default_value = "mpv-livetweet.conf")]
    out_file: String,
}

#[tokio::main]
async fn main() {
    let config = Config::parse();

    let consumer_token =
        egg_mode::KeyPair::new(std::env!("CONSUMER_KEY"), std::env!("CONSUMER_SECRET"));
    let request_token = egg_mode::auth::request_token(&consumer_token, "oob")
        .await
        .unwrap();
    let auth_url = egg_mode::auth::authorize_url(&request_token);

    if let Err(_) = webbrowser::open(&auth_url) {
        println!("Go to this URL on your browser:");
        println!("{}", &auth_url);
    }

    let mut verifier = String::new();

    println!("Enter the pin:");

    tokio::io::BufReader::new(tokio::io::stdin())
        .read_line(&mut verifier)
        .await
        .unwrap();

    let (token, _, _) = egg_mode::auth::access_token(consumer_token, &request_token, &verifier)
        .await
        .unwrap();

    let (consumer_token, access_token) = match token {
        egg_mode::auth::Token::Bearer(_) => unreachable!(),
        egg_mode::auth::Token::Access { consumer, access } => (consumer, access),
    };

    let mpv_livetweet_conf = format!(
        "consumer_key={}\nconsumer_secret={}\naccess_token_key={}\naccess_token_secret={}\n",
        consumer_token.key, consumer_token.secret, access_token.key, access_token.secret
    );

    tokio::fs::write(&config.out_file, mpv_livetweet_conf)
        .await
        .unwrap();

    println!("Tokens saved to {}", config.out_file);
}
