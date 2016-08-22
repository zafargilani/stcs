# usage: ruby userengagements.rb /fully/qualified/path/to/directory[accts] /fully/qualified/path/to/file[.csv]
require 'zlib'
require 'json'
require 'time'

# read accts/files from a directory
acct_list = Dir.entries(ARGV[0])
acct_list.delete(".") # remove . from the list
acct_list.delete("..") # remove .. from the list
acct_list.sort!

# Tweets API: https://dev.twitter.com/overview/api/tweets
# Users API: https://dev.twitter.com/overview/api/users

# get user engagement from raw tweets/json
# dump this in an output file from time to time
# note: historically, likes were called favorites

pline = ""
out = ""
source_list = []
count, retweets, favourited_count_sum, replies_count_sum = 0, 0, 0, 0
likes_count_sum, retweet_count_sum, listed_count_sum = 0, 0, 0
fo_fr_ratio_sum, tweet_freq_sum, fav_tw_ratio_sum = 0, 0, 0
days, urls_count, k = 0, 0, 0

acct_list.each do |acct|
  begin
    infile = open("#{ARGV[0]}/#{acct}")
    #gzi = Zlib::GzipReader.new(infile)
    #gzi.each_line do |line|
    infile.each_line do |line|
      begin
        pline = JSON.parse(line)
        # simple case: original tweet
        if pline["user"]["screen_name"].include? acct # == acct
	  if source_list.include? pline["source"] # match found
	    # do nothing
	  else
	    source_list.push(pline["source"])
	  end

          favourited_count = ( pline["user"]["favourites_count"] ).to_f
          favourited_count_sum = favourited_count_sum + favourited_count

          likes_count = ( pline["favorite_count"] ).to_f
	  likes_count_sum = likes_count_sum + likes_count

          retweet_count = ( pline["retweet_count"] ).to_f
	  retweet_count_sum = retweet_count_sum + retweet_count

          listed_count = ( pline["user"]["listed_count"] ).to_f
          listed_count_sum = listed_count_sum + listed_count

          fo_fr_ratio = pline["user"]["followers_count"].to_f / pline["user"]["friends_count"].to_f
          fo_fr_ratio_sum = fo_fr_ratio_sum + fo_fr_ratio
 
          user_time = Time.parse( pline["user"]["created_at"] ).to_f
          tweet_time = Time.parse( pline["created_at"] ).to_f
          days = ( ( tweet_time - user_time ) / 60 / 60 / 24 ).to_f
          tweet_freq = pline["user"]["statuses_count"].to_f / days
          tweet_freq_sum = tweet_freq_sum + tweet_freq

          fav_tw_ratio = pline["user"]["favourites_count"].to_f / pline["user"]["statuses_count"].to_f
          fav_tw_ratio_sum = fav_tw_ratio_sum + fav_tw_ratio

          if pline["in_reply_to_status_id"] != nil
	    replies_count_sum += 1
	  end

          if pline["text"].include? "http" or pline["text"].match(/.[a-z]*\//) # captures all urls
	  #if pline["entities"]["media"][0]["media_url"] != nil # only captures [entities]..[media_url] or [entities][url] (some are empty)
            urls_count += 1
	  end

          if pline["text"].include? "RT"
	    retweets += 1
	  end

          #k = k + (likes_count + retweet_count + listed_count + fo_fr_ratio + tweet_freq + fav_tw_ratio).to_f

          count += 1
        # retweeted
        elsif pline["retweeted_status"]["user"]["screen_name"].include? acct
	  if source_list.include? pline["source"] # match found
	    # do nothing
	  else
	    source_list.push(pline["source"])
	  end

          favourited_count = ( pline["retweeted_status"]["user"]["favourites_count"] ).to_f
          favourited_count_sum = favourited_count_sum + favourited_count

	  likes_count = ( pline["retweeted_status"]["favorite_count"] ).to_f
	  likes_count_sum = likes_count_sum + likes_count

          retweet_count = ( pline["retweeted_status"]["retweet_count"] ).to_f
          retweet_count_sum = retweet_count_sum + retweet_count

          listed_count = ( pline["retweeted_status"]["user"]["listed_count"] ).to_f
          listed_count_sum = listed_count_sum + listed_count

          fo_fr_ratio = pline["retweeted_status"]["user"]["followers_count"].to_f / pline["retweeted_status"]["user"]["friends_count"].to_f # 7
          fo_fr_ratio_sum = fo_fr_ratio_sum + fo_fr_ratio

          user_time = Time.parse( pline["retweeted_status"]["user"]["created_at"] ).to_f
          tweet_time = Time.parse( pline["retweeted_status"]["created_at"] ).to_f
          days = ( ( tweet_time - user_time ) / 60 / 60 / 24 ).to_f
          tweet_freq = pline["retweeted_status"]["user"]["statuses_count"].to_f / days
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

          if pline["text"].include? "RT"
	    retweets += 1
	  end

	  #k = k + (likes_count + retweet_count + listed_count + fo_fr_ratio + tweet_freq + fav_tw_ratio).to_f

          count += 1
        # quoted
        elsif pline["quoted_status"]["user"]["screen_name"].include? acct
	  if source_list.include? pline["source"] # match found
	    # do nothing
	  else
	    source_list.push(pline["source"])
	  end

          favourited_count = ( pline["quoted_status"]["user"]["favourites_count"] ).to_f
          favourited_count_sum = favourited_count_sum + favourited_count

          likes_count = ( pline["quoted_status"]["favorite_count"] ).to_f
          likes_count_sum = likes_count_sum + likes_count

          retweet_count = ( pline["quoted_status"]["retweet_count"] ).to_f
          retweet_count_sum = retweet_count_sum + retweet_count

          listed_count = ( pline["quoted_status"]["user"]["listed_count"] ).to_f
          listed_count_sum = listed_count_sum + listed_count

          fo_fr_ratio = pline["quoted_status"]["user"]["followers_count"].to_f / pline["quoted_status"]["user"]["friends_count"].to_f
          fo_fr_ratio_sum = fo_fr_ratio_sum + fo_fr_ratio

          user_time = Time.parse( pline["quoted_status"]["user"]["created_at"] ).to_f
          tweet_time = Time.parse( pline["quoted_status"]["created_at"] ).to_f
          days = ( ( tweet_time - user_time ) / 60 / 60 / 24 ).to_f
          tweet_freq = pline["quoted_status"]["user"]["statuses_count"].to_f / days
          tweet_freq_sum = tweet_freq_sum + tweet_freq

          fav_tw_ratio = pline["quoted_status"]["user"]["favourites_count"].to_f / pline["quoted_status"]["user"]["statuses_count"].to_f
          fav_tw_ratio_sum = fav_tw_ratio_sum + fav_tw_ratio

          if pline["quoted_status"]["in_reply_to_status_id"] != nil
	    replies_count_sum += 1
	  end
          
          if pline["text"].include? "http" or pline["text"].match(/.[a-z]*\//) # captures all urls
	  #if pline["quoted_status"]["entities"]["media"][0]["media_url"] != nil # only captures [entities]..[media_url] or [entities][url] (some are empty)
	    urls_count += 1
	  end
          
          if pline["text"].include? "RT"
	    retweets += 1
	  end

	  #k = k + (likes_count + retweet_count + listed_count + fo_fr_ratio + tweet_freq + fav_tw_ratio).to_f

          count += 1
        end
      rescue
        next
      end
    end
    out = "#{acct}, #{count}, #{retweets}, #{favourited_count_sum/count}, #{replies_count_sum}, #{likes_count_sum/count}, #{retweet_count_sum/count}, "
    out = out + "#{listed_count_sum/count}, #{fo_fr_ratio_sum/count}, #{tweet_freq_sum/count}, #{fav_tw_ratio_sum/count}, #{days}, "
    out = out + "#{source_list.size}, #{urls_count}"#, #{k/count}"
    File.open("#{ARGV[1]}", 'a') do |f|
      f.puts(out)
    end # auto file close
    #puts out
    #out_json = {
    #  "screen_name" => "#{acct}",
    #  "tweet_count" => count,
    #  "retweets" => retweets,
    #  "favourited_count" => favourited_count_sum / count,
    #  "replies_count_sum" => replies_count_sum,
    #  "likes_count" => likes_count_sum / count,
    #  "retweet_count" => retweet_count_sum / count,
    #  "listed_count" => listed_count_sum / count,
    #  "fo_fr_ratio" => fo_fr_ratio_sum / count,
    #  "tweet_freq" => tweet_freq_sum / count,
    #  "fav_tw_ratio" => fav_tw_ratio_sum / count,
    #  "days" => days,
    #  "source_list" => "#{source_list.size}",
    #  "urls_count" => "#{urls_count}"
    #  "k" => k / count
    #}
    #puts out_json
    # reset vars
    source_list.clear
    count, retweets, favourited_count_sum, replies_count_sum = 0, 0, 0, 0
    likes_count_sum, retweet_count_sum, listed_count_sum = 0, 0, 0
    fo_fr_ratio_sum, tweet_freq_sum, fav_tw_ratio_sum = 0, 0, 0
    days, urls_count, k = 0, 0, 0
  rescue => e
    raise e
  end
end

