# Authors:  Zafar Gilani (UCAM), Mario Almeida (UPC and TID Barcelona)
# Date:   Oct 2015
# Version:  1.0
# Purpose:  Collect tweets from Twitter Streaming API and dump into MongoDB

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
  end

  def get_client
    client = TweetStream::Client.new
  end

  def dump_sample_tweet(min_retweets:100)
    return if min_retweets <= 0

    client = TweetStream::Client.new
    tweet = nil

    client.sample do |status|
      #p status.attrs
      print "#{status.retweeted_status.retweet_count}.."

      if status.retweeted_status.retweet_count > min_retweets
        max_retweet = status.retweet_count
        tweet = status
        break
      end

    end
    tweet

  end

  def dump_sample_users(number_of_users:10)

    return if number_of_users <= 0

    client = TweetStream::Client.new
    i = 0
    users = []
    client.sample do |status|
      #p status.attrs
      users[i] = status.user.screen_name
      p users[i]
      i+=1
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
            file = File.new("/local/scratch/twitter-data/#{ptime.year}-#{ptime.month}-#{ptime.day}.uk.txt", "w")
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