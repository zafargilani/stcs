# usage: ruby userengagements.rb /fully/qualified/path/to/directory[accts]
require 'zlib'
require 'json'
require 'time'

# read accts/files from a directory
acct_list = Dir.entries(ARGV[0])
acct_list.delete(".") # remove . from the list
acct_list.delete("..") # remove .. from the list
acct_list.sort!

# get user engagement from raw tweets/json
# -> per post Summ.( [1] [3] and if [3] > 0: Summ.( [4] ) )
# -> per bot ("user") [6] [7] [8] [9]
# [1] favorite_count
# [3] retweet_count
# [4] in_reply_to_status_id, _str, in_reply_to_user_id, _str, in_reply_to_screen_name
# [6] user -> listed_count
# [7] fo_fr_ratio = user -> followers_count / friends_count
# [8] tweet_freq = user -> statuses_count / days( user -> created_at - created_at )
# [9] fav_tw_ratio = user -> favourites_count / statuses_count
# [10] replies_count
# [11] age_of_account = days
# dump this in an output file from time to time

pline = ""
out = ""
source_list = []
favorite_count_sum, retweet_count_sum, listed_count_sum, fo_fr_ratio_sum, tweet_freq_sum, fav_tw_ratio_sum = 0, 0, 0, 0, 0, 0
replies_count_sum, urls_count, days = 0, 0, 0
count, k = 0, 0

acct_list.each do |acct|
  begin
    infile = open("#{ARGV[0]}/#{acct}")
    #gzi = Zlib::GzipReader.new(infile)
    #gzi.each_line do |line|
    infile.each_line do |line|
      begin
        pline = JSON.parse(line)
        # simple case: original tweet
        if pline["user"]["screen_name"] == acct
	  if source_list.include? pline["source"] # match found
	    # do nothing
	  else
	    source_list.push(pline["source"])
	  end

          favorite_count = ( pline["favorite_count"] ).to_f # 1
          favorite_count_sum = favorite_count_sum + favorite_count

          retweet_count = ( pline["retweet_count"] ).to_f # 3
          retweet_count_sum = retweet_count_sum + retweet_count

          listed_count = ( pline["user"]["listed_count"] ).to_f # 6
          listed_count_sum = listed_count_sum + listed_count

          fo_fr_ratio = pline["user"]["followers_count"].to_f / pline["user"]["friends_count"].to_f # 7
          fo_fr_ratio_sum = fo_fr_ratio_sum + fo_fr_ratio
 
          user_time = Time.parse( pline["user"]["created_at"] ).to_f
          tweet_time = Time.parse( pline["created_at"] ).to_f
          days = ( ( tweet_time - user_time ) / 60 / 60 / 24 ).to_f
          tweet_freq = pline["user"]["statuses_count"].to_f / days # 8
          tweet_freq_sum = tweet_freq_sum + tweet_freq

          fav_tw_ratio = pline["user"]["favourites_count"].to_f / pline["user"]["statuses_count"].to_f # 9
          fav_tw_ratio_sum = fav_tw_ratio_sum + fav_tw_ratio

          if pline["in_reply_to_status_id"] != nil
	    replies_count_sum += 1
	  end

          if pline["text"].include? "http" or pline["text"].match(/.[a-z]*\//) # captures all urls
	  #if pline["entities"]["media"][0]["media_url"] != nil # only captures [entities]..[media_url] or [entities][url] (some are empty)
            urls_count += 1
	  end

          #k = k + (favorite_count + retweet_count + listed_count + fo_fr_ratio + tweet_freq + fav_tw_ratio).to_f

          count += 1
        # retweeted
        elsif pline["retweeted_status"]["user"]["screen_name"] == acct
	  if source_list.include? pline["source"] # match found
	    # do nothing
	  else
	    source_list.push(pline["source"])
	  end

          favorite_count = ( pline["retweeted_status"]["favorite_count"] ).to_f # 1
          favorite_count_sum = favorite_count_sum + favorite_count

          retweet_count = ( pline["retweeted_status"]["retweet_count"] ).to_f # 3
          retweet_count_sum = retweet_count_sum + retweet_count

          listed_count = ( pline["retweeted_status"]["user"]["listed_count"] ).to_f # 6
          listed_count_sum = listed_count_sum + listed_count

          fo_fr_ratio = pline["retweeted_status"]["user"]["followers_count"].to_f / pline["retweeted_status"]["user"]["friends_count"].to_f # 7
          fo_fr_ratio_sum = fo_fr_ratio_sum + fo_fr_ratio

          user_time = Time.parse( pline["retweeted_status"]["user"]["created_at"] ).to_f
          tweet_time = Time.parse( pline["retweeted_status"]["created_at"] ).to_f
          days = ( ( tweet_time - user_time ) / 60 / 60 / 24 ).to_f
          tweet_freq = pline["retweeted_status"]["user"]["statuses_count"].to_f / days # 8
          tweet_freq_sum = tweet_freq_sum + tweet_freq

          fav_tw_ratio = pline["retweeted_status"]["user"]["favourites_count"].to_f / pline["retweeted_status"]["user"]["statuses_count"].to_f # 9
          fav_tw_ratio_sum = fav_tw_ratio_sum + fav_tw_ratio

          if pline["retweeted_status"]["in_reply_to_status_id"] != nil
	    replies_count_sum += 1
	  end
          
          if pline["text"].include? "http" or pline["text"].match(/.[a-z]*\//) # captures all urls
          #if pline["retweeted_status"]["entities"]["media"][0]["media_url"] != nil # only captures [entities]..[media_url] or [entities][url] (some are empty)
	    urls_count += 1
	  end

	  #k = k + (favorite_count + retweet_count + listed_count + fo_fr_ratio + tweet_freq + fav_tw_ratio).to_f

          count += 1
        # quoted
        elsif pline["quoted_status"]["user"]["screen_name"] == acct
	  if source_list.include? pline["source"] # match found
	    # do nothing
	  else
	    source_list.push(pline["source"])
	  end

          favorite_count = ( pline["quoted_status"]["favorite_count"] ).to_f # 1
          favorite_count_sum = favorite_count_sum + favorite_count

          retweet_count = ( pline["quoted_status"]["retweet_count"] ).to_f # 3
          retweet_count_sum = retweet_count_sum + retweet_count

          listed_count = ( pline["quoted_status"]["user"]["listed_count"] ).to_f # 6
          listed_count_sum = listed_count_sum + listed_count

          fo_fr_ratio = pline["quoted_status"]["user"]["followers_count"].to_f / pline["quoted_status"]["user"]["friends_count"].to_f # 7
          fo_fr_ratio_sum = fo_fr_ratio_sum + fo_fr_ratio

          user_time = Time.parse( pline["quoted_status"]["user"]["created_at"] ).to_f
          tweet_time = Time.parse( pline["quoted_status"]["created_at"] ).to_f
          days = ( ( tweet_time - user_time ) / 60 / 60 / 24 ).to_f
          tweet_freq = pline["quoted_status"]["user"]["statuses_count"].to_f / days # 8
          tweet_freq_sum = tweet_freq_sum + tweet_freq

          fav_tw_ratio = pline["quoted_status"]["user"]["favourites_count"].to_f / pline["quoted_status"]["user"]["statuses_count"].to_f # 9
          fav_tw_ratio_sum = fav_tw_ratio_sum + fav_tw_ratio

          if pline["quoted_status"]["in_reply_to_status_id"] != nil
	    replies_count_sum += 1
	  end
          
          if pline["text"].include? "http" or pline["text"].match(/.[a-z]*\//) # captures all urls
	  #if pline["quoted_status"]["entities"]["media"][0]["media_url"] != nil # only captures [entities]..[media_url] or [entities][url] (some are empty)
	    urls_count += 1
	  end
          
	  #k = k + (favorite_count + retweet_count + listed_count + fo_fr_ratio + tweet_freq + fav_tw_ratio).to_f

          count += 1
        end
      rescue
        next
      end
    end
    out = "#{acct}, #{favorite_count_sum/count}, #{retweet_count_sum/count}, #{listed_count_sum/count}, #{fo_fr_ratio_sum/count}, "
    out = out + "#{tweet_freq_sum/count}, #{fav_tw_ratio_sum/count}, #{count}, #{days}, #{replies_count_sum}, #{source_list.size}, #{urls_count}"#, #{k/count}"
    puts out
    #out_json = {
    #  "screen_name" => "#{acct}",
    #  "favorite_count [1]" => favorite_count_sum / count,
    #  "retweet_count [3]" => retweet_count_sum / count,
    #  "listed_count [6]" => listed_count_sum / count,
    #  "fo_fr_ratio [7]" => fo_fr_ratio_sum / count,
    #  "tweet_freq [8]" => tweet_freq_sum / count,
    #  "fav_tw_ratio [9]" => fav_tw_ratio_sum / count,
    #  #"tweet_count" => count,
    #  "days [11]" => days,
    #  "replies_count_sum [10]" => replies_count_sum,
    #  "source_list" => "#{source_list.size}",
    #  "urls_count" => "#{urls_count}"
    #  "k" => k / count
    #}
    #puts out_json
    # reset vars
    source_list.clear
    favorite_count_sum, retweet_count_sum, listed_count_sum, fo_fr_ratio_sum, tweet_freq_sum, fav_tw_ratio_sum = 0, 0, 0, 0, 0, 0
    replies_count_sum, urls_count, days = 0, 0, 0
    count, k = 0, 0
  rescue => e
    puts e
  end
end

