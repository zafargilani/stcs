require 'twitter_ebooks'

# This is an example bot definition with event handlers commented out
# You can define and instantiate as many bots as you like

class BobTheBot < Ebooks::Bot

  def initialize(consumer_key, consumer_secret, oauth_token, oauth_token_secret, 
    collector:nil, bot_name:"gilhuss", follow_number:0, follow_frequency:0, unfollow_number:0, unfollow_frequency:0)

      @consumer_key       = consumer_key
      @consumer_secret    = consumer_secret
      @oauth_token        = oauth_token
      @oauth_token_secret = oauth_token_secret
      @auth_method        = :oauth
      @collector = collector

      @follow_frequency = follow_frequency
      @follow_number = follow_number

      @unfollow_frequency = unfollow_frequency
      @unfollow_number = unfollow_number

      p "Bot configuration = (#{follow_frequency},#{follow_number},#{unfollow_frequency},#{unfollow_number})"

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

  def random_follow(number_of_users:10)
    p "Following #{number_of_users} users..."
    users = @collector.dump_sample_users(number_of_users:number_of_users)

    return if users == nil

    users.each do |user|
        follow(user)
    end
  end

  def random_unfollow(number_of_users:10)
    qfollowers = []
    qfriend = []

    p "followers: ----------------"

    i = 0
    twitter.followers.each do |follower|
      qfollowers[i] = follower.screen_name
      i+= 1
    end

    p qfollowers.inspect

    p "friends: ----------------"
    
    i=0
    twitter.friends.each do |friend|
      qfriend[i] = friend.screen_name
      i+= 1
    end

    p qfriend.inspect

    p "difference: --------------"

    non_followers = qfriend - qfollowers
    p non_followers.inspect

    p "Removing : --------------"
    r = Random.new
    for j in 0..number_of_users
      break if non_followers.size == 0
      pos = r.rand(0..non_followers.size-1)
      unfollow(non_followers[j])
      non_followers -= [non_followers[j]]
    end

  end

  def on_startup

    for i in 0..2
      begin
        retweet(@collector.dump_topic_tweet(topic:"recruit",min_retweets:5000))
      rescue => e
          p "twitter error : #{e}"
      end
    end

    begin
      scheduler.every "1h" do
        retweet(@collector.dump_sample_tweet(min_retweets:100000))
      end

    rescue => e
        p "twitter error : #{e}"
    end
    
    if @follow_frequency > 0

      begin
        random_follow(number_of_users:@follow_number)
      rescue => e
        p "twitter error : #{e}"
      end

      scheduler.every "#{@follow_frequency}h" do
        begin
          random_follow(number_of_users:@follow_number)
        rescue => e
          p "twitter error : #{e}"
        end
        # Tweet something every 24 hours
        # See https://github.com/jmettraux/rufus-scheduler
        # tweet("hi")
        # pictweet("hi", "cuteselfie.jpg")
      end
    end

    if @unfollow_frequency > 0

      scheduler.every "#{@unfollow_frequency}h" do

        begin
          random_unfollow(number_of_users:@unfollow_number)
        rescue => e
          p "twitter error : #{e}"
        end
        # Tweet something every 24 hours
        # See https://github.com/jmettraux/rufus-scheduler
        # tweet("hi")
        # pictweet("hi", "cuteselfie.jpg")
      end
    end

  end

  def on_message(dm)
    p "There was a message #{dm.inspect}"
    # Reply to a DM
    #reply(dm, "dolphins!")
  end

  def on_follow(user)
    # Follow a user back
    p "New user following!! #{user.screen_name}"
    #follow(user.screen_name)
  end

  def on_mention(tweet)
    p "There was a mention #{tweet.inspect}"
    # Reply to a mention
    #reply(tweet, "oh hullo")
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


