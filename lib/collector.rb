require 'tweetstream'
#require 'bson'
require 'json'
require 'time'

class Collector

  def initialize(consumer_key, consumer_secret, oauth_token, oauth_token_secret)
    TweetStream.configure do |config|
      config.consumer_key       = consumer_key
      config.consumer_secret    = consumer_secret
      config.oauth_token        = oauth_token
      config.oauth_token_secret = oauth_token_secret
      config.auth_method        = :oauth
    end

      @consumer_key       = consumer_key
      @consumer_secret    = consumer_secret
      @oauth_token        = oauth_token
      @oauth_token_secret = oauth_token_secret
  end

  def get_twitter_client
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = @consumer_key
      config.consumer_secret     = @consumer_secret
      config.access_token        = @oauth_token 
      config.access_token_secret = @oauth_token_secret
    end
    client
  end

  def get_client
    client = TweetStream::Client.new
  end

  #def dump_sample_tweet(min_retweets:100)
  def dump_sample_tweet(lang:"en",min_retweets:100)
    return if min_retweets <= 0

    client = TweetStream::Client.new
    tweet = nil

    client.sample do |status|
      #p status.attrs
      print "#{status.retweeted_status.retweet_count}.."

      #if status.retweeted_status.retweet_count > min_retweets
      if status.retweeted_status.retweet_count > min_retweets and status.lang == lang 
        max_retweet = status.retweet_count
        tweet = status
        break
      end

    end
    tweet
  end

  def dump_topic_tweet(topic:"job opportunity",min_retweets:100)
    return if min_retweets < 0

    if topic.include? ','
      topics = topic.split(',')
      topic = topics[rand(topics.length)]
    end

    client = TweetStream::Client.new
    tweet = nil

    client.track(topic) do |status|
      #p status.attrs
      print "||#{status.retweeted_status.retweet_count}||"
      print "#{status.text}"

      if status.retweeted_status.retweet_count > min_retweets or min_retweets == 0
        max_retweet = status.retweet_count
        tweet = status
        break
      end

    end
    tweet
  end

  SLICE_SIZE = 100

  def fetch_all_friends(user:"gilhuss")

    @friends = []

    client = get_twitter_client
    #CSV.open("#{twitter_username}_friends_list.txt", 'w') do |csv|
      client.friend_ids(user).each_slice(SLICE_SIZE).with_index do |slice, i|
        client.users(slice).each_with_index do |f, j|
          @friends << f.screen_name
          #csv << [i * SLICE_SIZE + j + 1, f.name, f.screen_name, f.url, f.followers_count, f.location.gsub(/\n+/, ' '), f.created_at, f.description.gsub(/\n+/, ' '), f.lang, f.time_zone, f.verified, f.profile_image_url, f.website, f.statuses_count, f.profile_background_image_url, f.profile_banner_url]
        end
      end
    #end
    #p "Friends : "
    #p @friends.inspect
    @friends
  end

    def fetch_all_followers(user:"gilhuss")

    @followers = []

    client = get_twitter_client
    #CSV.open("#{twitter_username}_friends_list.txt", 'w') do |csv|
      client.follower_ids(user).each_slice(SLICE_SIZE).with_index do |slice, i|
        client.users(slice).each_with_index do |f, j|
          @followers << f.screen_name
          #csv << [i * SLICE_SIZE + j + 1, f.name, f.screen_name, f.url, f.followers_count, f.location.gsub(/\n+/, ' '), f.created_at, f.description.gsub(/\n+/, ' '), f.lang, f.time_zone, f.verified, f.profile_image_url, f.website, f.statuses_count, f.profile_background_image_url, f.profile_banner_url]
        end
      end
    #end
    #p "followers :"
    #p @followers.inspect
    @followers
  end

  def dump_sample_users(number_of_users:10)
    number_of_users = number_of_users*100

    return if number_of_users <= 0

    client = TweetStream::Client.new
    i = 0
    users = []
    p "Selecting users with user.lang = en / es..."
    client.sample do |status|
      #p status.attrs
      if status.user.lang == "en" or status.user.lang == "es"
        users[i] = status.user.screen_name
        p users[i]
        i+=1
      end
      #users[i] = status.user.screen_name
      #p users[i]
      #i+=1
      break if(i == number_of_users)
    end
    users
  end

  def collect(output_folder)
      client = TweetStream::Client.new

      i = 1 # iterator keeping total count

      ptime = Time.now
      file = File.new("#{output_folder}/#{ptime.year}-#{ptime.month}-#{ptime.day}.uk.txt", "w")

      begin
        #client.userstream do |status|
        client.sample do |status|
          if ptime.day != Time.now.day # check for day, if new day then new file
            ptime = Time.now
            file = File.new("/home/szuhg2/twitter-data/#{ptime.year}-#{ptime.month}-#{ptime.day}.uk.txt", "w")
          end

          puts i
          json = JSON.generate(status.attrs)
        
          file.write("#{json}\n")
     
          i += 1
        end
      rescue => e
        #puts "Tweetstream crashed due to reconnect error, will restart shortly"
        puts e
      end

  end
end
