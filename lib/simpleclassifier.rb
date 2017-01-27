# usage: ruby simpleclassifier.rb /fully/qualified/path/to/output/directory/
require 'time'
require 'json'

# known sources used by humans, others probably by automated accounts / bots
# not including TweetDeck and SnappyTV because used mostly by automated accounts with human intervention
KNOWN_SOURCES = ["Twitter Web Client", "Twitter for iPhone", "Twitter for Android", "Twitter for Windows Phone",
		 "Twitter for iPad", "UberSocial", "Instagram", "Facebook", "Mobile Web (M2)", "Mobile Web (M5)"]

# popularity ranges
LOWER_10M = 9000000
UPPER_10M = 11000000
LOWER_1M = 900000
UPPER_1M = 1100000
LOWER_100K = 90000
UPPER_100K = 110000
LOWER_1K = 900
UPPER_1K = 1100

out = ""
tweet = ""
kind = ""
group = ""

ptime = Time.now

# get the 2nd last tweet from the stream - last could be garbled
tweet = `tail -n2 /data/reserve/twitter/#{ptime.year}-#{ptime.month}-#{ptime.day}.uk.txt | head -n1`
#File.open("/data/reserve/twitter/#{ptime.year}-#{ptime.month}-#{ptime.day}.uk.txt") do |stream|
#  2.times{stream.gets}
#  tweet = $_
#end # auto file close

while (!tweet.empty?) do
  begin
    ptweet = JSON.parse(tweet)

    # get relevant tweet properties
    source = ptweet['source']
    screen_name = ptweet['user']['screen_name']
    followers_count = ptweet['user']['followers_count'].to_i
    
    source_sl = source.slice(source.index('>')+1, source.length)
    source_sl = source_sl.slice(0, source_sl.index('<'))
    #puts source_sl

    # determine: kind (later include daily tweet frequency?)
    if KNOWN_SOURCES.include? source_sl # then definitely a human
      kind = "human"
    else # otherwise likely a bot
      kind = "bot"
    end

    # determine: popularity group
    # output: group, kind, name, source, followers
    if followers_count >= LOWER_10M and followers_count <= UPPER_10M # 10M
      group = "10M"
    elsif followers_count >= LOWER_1M and followers_count <= UPPER_1M # 1M
      group = "1M"
    elsif followers_count >= LOWER_100K and followers_count <= UPPER_100K # 100K
      group = "100k"
    elsif followers_count >= LOWER_1K and followers_count <= UPPER_1K # 1K
      group = "1k"
    else
      group = "nogroup"
    end

    out = "#{group}, #{kind}, #{screen_name}, #{source}, #{followers_count}"
    #puts out
    File.open("#{ARGV[0]}/simpleclassifier.#{ptime.year}-#{ptime.month}-#{ptime.day}.#{group}.csv", 'a') do |f|
      f.puts(out)
    end # auto file close

    # clear
    kind = ""
    group = ""
  rescue => e
    puts e
  end
  sleep 2
  tweet = `tail -n2 /data/reserve/twitter/#{ptime.year}-#{ptime.month}-#{ptime.day}.uk.txt | head -n1`
end

