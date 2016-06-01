require 'twitter_ebooks'
require 'rest-client'

# This is an example bot definition with event handlers commented out
# You can define and instantiate as many bots as you like

class BobTheBot < Ebooks::Bot

  def initialize(consumer_key, consumer_secret, oauth_token, oauth_token_secret, 
    collector:nil, bot_name:"gilhuss", follow_number:0, follow_frequency:0, unfollow_number:0, unfollow_frequency:0, follower_ratio:0)

      @consumer_key       = consumer_key
      @consumer_secret    = consumer_secret
      @oauth_token        = oauth_token
      @oauth_token_secret = oauth_token_secret
      @auth_method        = :oauth
      @collector = collector

      @follow_frequency = follow_frequency
      @follow_number = follow_number
      @follower_ratio = follower_ratio

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

  def advanced_random_follow(number_of_users:10)
    number_of_users = number_of_users*100
    p "Checking #{number_of_users} users (to follow only those with language english or spanish)..."
    users = @collector.dump_sample_users(number_of_users:number_of_users)

    return if users == nil

    user_count = 0
    users.each do |user|
      if user_count < @follow_number.to_i
        #if user.language.to_s == "english" or user.language.to_s == "spanish"
        #if user.lang.to_s == "en" or user.lang.to_s == "es"
        #  follow(user)
        #  user_count += 1
        #end
        follow(user)
        user_count += 1
      end
    end
    p "Now following #{user_count} more users out of #{number_of_users} checked for language english or spanish..."
  end


  def random_unfollow(follower_ratio:0.3)
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
    to_remove = non_followers.size * follower_ratio

    p "Removing : --------------"
    r = Random.new
    for j in 0..to_remove.to_i
      break if non_followers.size == 0
      pos = r.rand(0..non_followers.size-1)
      unfollow(non_followers[j])
      non_followers -= [non_followers[j]]
    end

  end


  def advanced_random_unfollow(follower_ratio:0.3,max_unfollow:1000)
    qfollowers = @collector.fetch_all_followers
    qfriend = @collector.fetch_all_friends

    p "friends #{qfriend.size} followers #{qfollowers.size}"

    #p "difference: --------------"

    non_followers = qfriend - qfollowers
    #p non_followers.inspect
    to_remove = qfriend.size - qfollowers.size / follower_ratio
    to_remove = to_remove.to_i

    p "After ratio, number of followers to remove is #{to_remove}"

    if to_remove > max_unfollow
      to_remove = max_unfollow
    end

    p "Capped to #{to_remove}"

    p "Removing : --------------"
    r = Random.new
    for j in 0..to_remove.to_i
      break if non_followers.size == 0
      pos = r.rand(0..non_followers.size-1)
      unfollow(non_followers[j])
      non_followers -= [non_followers[j]]
    end
  end

  def post_tweet_copy(topic:"job opportunity", min_retweets:0)
  #def post_tweet_copy(lang:"en", min_retweets:25)

    keys = []

    begin
      tw = @collector.dump_topic_tweet(topic:topic,min_retweets:min_retweets)
      #tw = @collector.dump_sample_tweet(lang:lang,min_retweets:min_retweets)

      replacements = []

      p "get urls preview"
      p Scanner.get_urls_from_twitter(tw.text).inspect

      p "running each"
      Scanner.get_urls_from_twitter(tw.text).each do |url|
        p "RestClient.get http://localhost/gen/i?u=#{url}"
        response = RestClient.get "http://localhost/gen/i?u=#{url}"
        p response.inspect
        json = JSON.parse(response)
        key= json["unique_key"]
        p key
        keys << key
        replacements << [url, "http://tnyurl.uk/#{key}"]
      end

      txt = tw.text.dup

      p txt
      p replacements.inspect

      replacements.each do |rep|
        txt.gsub! rep[0], rep[1]
      end 

      p txt

      #if not txt.include? '#job'
      #  txt = "#{txt} \#job" if txt.size < 140 - " \#job".size
      #end

      #if not txt.include? '#recruiting'
      #  txt = "#{txt} \#recruiting" if txt.size < 140 - " \#recruiting".size
      #end

      #note that this tweets the txt
      id = tweet(txt).id

      #log tweet ids and url token for each copied tweet
      open('tweet_ids.txt', 'a') { |f|
        f.puts "#{id},#{keys},#{txt}"
      }

    rescue => e
      p "twitter error : #{e}"
      #this happens if the tweet goes over 140 chars
      post_tweet_copy(topic:topic, min_retweets:min_retweets)
      #post_tweet_copy(lang:lang, min_retweets:min_retweets)
    end
  end

  def on_startup

    #retweet(@collector.dump_topic_tweet(topic:"job opportunity",min_retweets:1))
    #post_tweet_copy

    #advanced_random_unfollow
    advanced_random_unfollow(follower_ratio:@follower_ratio, max_unfollow:300)

    begin
      scheduler.every "1h" do
        for i in 0..1
          retweet(@collector.dump_topic_tweet(topic:"job opportunity",min_retweets:1))
          #retweet(@collector.dump_sample_tweet(lang:"en",min_retweets:1))
        end
        post_tweet_copy #no args follows default
    end

    rescue => e
        p "twitter error : #{e}"
    end
    
    if @follow_frequency > 0

      scheduler.every "#{@follow_frequency}m" do
        begin
          #random_follow(number_of_users:@follow_number)
          advanced_random_follow(number_of_users:@follow_number)
        rescue => e
          p "twitter error : #{e}"
        end
      end
    end

    if @follower_ratio > 0

      scheduler.every "#{@unfollow_frequency}h" do
        begin
          advanced_random_unfollow(follower_ratio:@follower_ratio, max_unfollow:100)
        rescue => e
          p "twitter error : #{e}"
        end
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
    #p "There was a tweet on timeline #{tweet.inspect}"
    # Reply to a tweet in the bot's timeline
    # reply(tweet, "nice tweet")
  end

  def on_favorite(user, tweet)
    p "There was a favourite #{tweet.inspect}"
    # Follow user who just favorited bot's tweet
    # follow(user.screen_name)
  end
end



