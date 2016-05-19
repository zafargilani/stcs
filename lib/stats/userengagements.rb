require 'zlib'
require 'json'
require 'time'

# read accts (bots, cyborgs, humans) from a file (format: screen_name, type) and populate appropriate lists
# for now using arrays
#acct_list = ["AmericanAir", "verizon", "XHNews", "GirIsWant", "footlocker", # bots
#  "Forbes", "CNET", "HugoGloss", "AppSame", "THR", # bots
#  "NatbyNature", "awkwardgoogle", "carlaangola", "ErnestoChavana", # humans
#  "GuyKawasaki", "SeanMaxwell", "DeepakChopra", "OrlandoMagic", "victordrija", "cavs"] # humans

acct_list = ["AmericanAir", "XHNews", "verizon",
  "GuyKawasaki", "SeanMaxwell", "carlaangola"]

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

parsed_line = ""
out = ""
favorite_count_sum = 0
retweet_count_sum = 0
listed_count_sum = 0
follower_friend_ratio_sum = 0
tweet_frequency_sum = 0
favourite_tweet_ratio_sum = 0
k = 0
count = 0

acct_list.each do |acct|
  begin
    infile = open('/data2/zf-twitter-classifier/2016-4.'.concat(acct))
    #gzi = Zlib::GzipReader.new(infile)
    #gzi.each_line do |line|
    infile.each_line do |line|
      begin
        parsed_line = JSON.parse(line)
        # no need for following as ["user"]["screen_name"] maps to user first, so if it is quoted the script would know
        #if parsed_line["user"]["screen_name"] == acct and parsed_line["quoted_status"]["user"]["screen_name"] != acct
        if parsed_line["user"]["screen_name"] == acct #and parsed_line["quoted_status"]["user"]["screen_name"] != acct
          favorite_count = ( parsed_line["favorite_count"] ).to_f # 1
          favorite_count_sum = favorite_count_sum + favorite_count

          retweet_count = ( parsed_line["retweet_count"] ).to_f # 3
          retweet_count_sum = retweet_count_sum + retweet_count

          listed_count = ( parsed_line["user"]["listed_count"] ).to_f # 6
          listed_count_sum = listed_count_sum + listed_count

          follower_friend_ratio = ( parsed_line["user"]["followers_count"].to_i / parsed_line["user"]["friends_count"].to_i ).to_f # 7
          follower_friend_ratio_sum = follower_friend_ratio_sum + follower_friend_ratio
 
          user_time = Time.parse( parsed_line["user"]["created_at"] ).to_i
          tweet_time = Time.parse( parsed_line["created_at"] ).to_i
          days = ( tweet_time - user_time ) / 60 / 60 / 24
          tweet_frequency = ( parsed_line["user"]["statuses_count"].to_i / days ).to_f # 8
          tweet_frequency_sum = tweet_frequency_sum + tweet_frequency

          favourite_tweet_ratio = ( parsed_line["user"]["favourites_count"].to_i / parsed_line["user"]["statuses_count"].to_i ).to_f # 9
          favourite_tweet_ratio_sum = favourite_tweet_ratio_sum + favourite_tweet_ratio

          #out_hash = {
          #  "screen_name" => "#{parsed_line["user"]["screen_name"]}",
          #  "favorite_count [1]" => favorite_count,
          #  "retweet_count [3]" => retweet_count,
          #  "listed_count [6]" => listed_count,
          #  "follower_friend_ratio [7]" => follower_friend_ratio,
          #  "tweet_frequency [8]" => tweet_frequency,
          #  "favourite_tweet_ratio [9]" => favourite_tweet_ratio
          #}
          #out = out + "post: favorite_count #{favorite_count}, retweet_count #{retweet_count}\n"
          #out = out + "bot: listed_count #{listed_count}, follower_friend_ratio #{follower_friend_ratio}, "
          #out = out + "tweet_frequency #{tweet_frequency}, favourite_tweet_ratio #{favourite_tweet_ratio}\n"
          #puts out
          k = k + (favorite_count + retweet_count + listed_count + follower_friend_ratio + tweet_frequency + favourite_tweet_ratio).to_f
          #puts "k = #{k}"

          count += 1
        end
      rescue
        next
      end
    end
    out_hash = {
      "screen_name" => "#{acct}",
      "favorite_count [1]" => favorite_count_sum / count,
      "retweet_count [3]" => retweet_count_sum / count,
      "listed_count [6]" => listed_count_sum / count,
      "follower_friend_ratio [7]" => follower_friend_ratio_sum / count,
      "tweet_frequency [8]" => tweet_frequency_sum / count,
      "favourite_tweet_ratio [9]" => favourite_tweet_ratio_sum / count,
      "tweet_count" => count,
      "k" => k / count
    }
    puts out_hash
    #k = k / count # avg
    #puts "#{acct}, k = #{k}"
    # reset vars
    favorite_count_sum = 0
    retweet_count_sum = 0
    listed_count_sum = 0
    follower_friend_ratio_sum = 0
    tweet_frequency_sum = 0
    favourite_tweet_ratio_sum = 0
    k = 0
    count = 0
  rescue => e
    puts e
  end
end

