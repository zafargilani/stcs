# Authors:	Zafar Gilani (UCAM), Mario Almeida (UPC and TID Barcelona)
# Date: 	Oct 2015
# Version:	1.0
# Purpose:	Collect tweets from Twitter Streaming API and dump into MongoDB

require 'tweetstream'
#require 'bson'
require 'json'
require 'time'

#class String
#  def convert_base(from, to)
#    self.to_i(from).to_s(to)
#    # In Ruby 1.9.2+ the more strict below is possible:
#    # Integer(self, from).to_s(to)
#  end
#end

TweetStream.configure do |config|
  config.consumer_key       = '9E0f7GpXu6ekRIqJZqxcU5KUU'
  config.consumer_secret    = 'eHgIi5g1pos6infbGORkKr2bMvzY5olasUZDguqVHo600KdVIV'
  config.oauth_token        = '3047040941-CJZHgHvhNLGxFjmO5Im8gewCqKTGQbutqiSTk9D'
  config.oauth_token_secret = 'Pk8SttdWIlCnymS40ENYm7pIujqWWJmjVudeGMoRB8eXE'
  config.auth_method        = :oauth
end

## This will pull a sample of all tweets based on
## your Twitter account's Streaming API role.
#TweetStream::Client.new.sample do |status|
#  # The status object is a special Hash with
#  # method access to its keys.
#  puts "#{status.text}"
#end

#tracking_keywords = Array['bbc'];

client = TweetStream::Client.new

#params = Hash.new;
#params[:track] = tracking_keywords;

#client.filter(params) do |status|
#  puts "#{status.text} - #{status.created_at}"
#  tweets.insert_one({text: status.text}).n
#end

i = 1 # iterator keeping total count

## File writer
ptime = Time.now
file = File.new("/local/scratch/twitter-data/#{ptime.year}-#{ptime.month}-#{ptime.day}.uk.txt", "w")

begin
  #client.userstream do |status|
  client.sample do |status|
    if ptime.day != Time.now.day # check for day, if new day then new file
      ptime = Time.now
      file = File.new("/local/scratch/twitter-data/#{ptime.year}-#{ptime.month}-#{ptime.day}.uk.txt", "w")
    end

    puts i
    json = JSON.generate(status.attrs)
    #puts "#{json}"
    #puts "#{status.user.id}-#{status.user.name} | #{status.text} | #{status.created_at}" #if status.user.lang=="en"
    #puts "\nZZZ #{status.user.id} #{status.user.name} ZZZ\n\n"
    #puts "\nZZZ #{status.retweeted_status.user.id} #{status.retweeted_status.user.name} ZZZ\n\n" if status.retweet?
    file.write("#{json}\n")
    #client.follow(status.retweeted_status.user.id)
    #puts "\nZZZ  #{status.to_bson} ZZZ\n\n"
    #puts "\nZZZ #{status.user.methods.sort} ZZZ\n\n" # to get method list
    #puts "\nZZZ #{status.user.lang} ZZZ\n\n"
    i += 1
  end
#rescue TweetStream::ReconnectError
rescue => e
  #puts "Tweetstream crashed due to reconnect error, will restart shortly"
  puts e
end

