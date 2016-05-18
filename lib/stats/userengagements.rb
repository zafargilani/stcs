require 'zlib'
require 'json'
require 'time'

# read accts (bots, cyborgs, humans) from a file (format: screen_name, type) and populate appropriate lists
# for now using arrays
acct_list_bots = ["AmericanAir", "verizon", "XHNews", "GirIsWant", "footlocker", 
  "Forbes", "CNET", "HugoGloss", "AppSame", "THR"]
acct_list_humans = ["NatbyNature", "awkwardgoogle", "carlaangola", "ErnestoChavana", 
  "GuyKawasaki", "SeanMaxwell", "DeepakChopra", "OrlandoMagic", "victordrija", "cavs"]

acct = "AmericanAir" # temp as this should be a loop

# get user engagement from raw tweets/json
# -> per post Summ.( [1] [3] and if [3] > 0: Summ.( [4] ) )
# -> per bot ("user") [6] [7] [8] [9]
# [1] favorite_count
# [3] retweet_count
# [4] in_reply_to_status_id, _str, in_reply_to_user_id, _str, in_reply_to_screen_name
# [6] user -> listed_count
# [7] follower_friend_ratio = user -> followers_count / friends_count
# [8] tweet_frequency = user -> statuses_count / days( user -> created_at - created_at )
# [9] favourite_tweet_ratio = user -> favourites_count / statuses_count
# dump this in an output file from time to time
# print on screen for now

LIMIT = 3 # limiting to 1k tweets

parsed_line = ""
out = ""
k = 0
count = 0

begin
  infile = open('/data/zf-twitter-data/2016-4-1.uk.txt.gz')
  gzi = Zlib::GzipReader.new(infile)
  gzi.each_line do |line|
    begin
      parsed_line = JSON.parse(line)
      if parsed_line["user"]["screen_name"] == acct and count < LIMIT
        favorite_count = parsed_line["favorite_count"] # 1

        retweet_count = parsed_line["retweet_count"] # 3

        listed_count = parsed_line["user"]["listed_count"] # 6

        follower_friend_ratio = ( parsed_line["user"]["followers_count"].to_i / parsed_line["user"]["friends_count"].to_i ).to_f # 7
        
        user_time = Time.parse( parsed_line["user"]["created_at"] ).to_i
        tweet_time = Time.parse( parsed_line["created_at"] ).to_i
        days = ( tweet_time - user_time ) / 60 / 60 / 24
        tweet_frequency = ( parsed_line["user"]["statuses_count"].to_i / days ).to_f # 8

        favourite_tweet_ratio = ( parsed_line["user"]["favourites_count"].to_i / parsed_line["user"]["statuses_count"].to_i ).to_f # 9

        #out = out + "post: favorite_count #{favorite_count}, retweet_count #{retweet_count}\n"
        #out = out + "bot: listed_count #{listed_count}, follower_friend_ratio #{follower_friend_ratio}, "
        #out = out + "tweet_frequency #{tweet_frequency}, favourite_tweet_ratio #{favourite_tweet_ratio}\n"
        #puts out
        k = k + (favorite_count + retweet_count + listed_count + follower_friend_ratio + tweet_frequency + favourite_tweet_ratio).to_f
        #puts "k = #{k}"

        count += 1
      elsif count >= LIMIT
        k = k / count # avg
        puts "k = #{k}"
        break
      end
      #out = "" # reset
      #k = k / count # avg
      #puts "k = #{k}"
    rescue
      next
    end
  end
rescue => e
  puts e
end

