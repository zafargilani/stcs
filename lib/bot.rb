require 'twitter_ebooks'

# This is an example bot definition with event handlers commented out
# You can define and instantiate as many bots as you like

class BobTheBot < Ebooks::Bot

  def initialize(consumer_key, consumer_secret, oauth_token, oauth_token_secret, collector:nil,bot_name:"gilhuss")

      @consumer_key       = consumer_key
      @consumer_secret    = consumer_secret
      @oauth_token        = oauth_token
      @oauth_token_secret = oauth_token_secret
      @auth_method        = :oauth
      @collector = collector

    # Make a MyBot and attach it to an account
    super(bot_name) do |bot|
      bot.access_token = oauth_token # Token connecting the app to this account
      bot.access_token_secret = oauth_token_secret # Secret connecting the app to this account
    end
  end

  # Configuration here applies to all MyBots
  def configure
    # Consumer details come from registering an app at https://dev.twitter.com/
    # Once you have consumer details, use "ebooks auth" for new access tokens
    self.consumer_key = @consumer_key  # Your app consumer key
    self.consumer_secret = @consumer_secret # Your app consumer secret

    # Users to block instead of interacting with
    self.blacklist = ['tnietzschequote']

    # Range in seconds to randomize delay when bot.delay is called
    self.delay_range = 1..6
  end

  def on_startup

    @collector.dump_sample_users

    scheduler.every '24h' do
      # Tweet something every 24 hours
      # See https://github.com/jmettraux/rufus-scheduler
      # tweet("hi")
      # pictweet("hi", "cuteselfie.jpg")
    end
  end

  def on_message(dm)
    p "There was a message #{tweet.inspect}"
    # Reply to a DM
    # reply(dm, "secret secrets")
  end

  def on_follow(user)
    # Follow a user back
    follow(user.screen_name)
  end

  def on_mention(tweet)
    p "There was a mention #{tweet.inspect}"
    # Reply to a mention
    reply(tweet, "oh hullo")
  end

  def on_timeline(tweet)
    p "There was a tweet on timeline #{tweet.inspect}"
    # Reply to a tweet in the bot's timeline
    # reply(tweet, "nice tweet")
  end

  def on_favorite(user, tweet)
    p "There was a favourite #{tweet.inspect}"
    # Follow user who just favorited bot's tweet
    # follow(user.screen_name)
  end
end


