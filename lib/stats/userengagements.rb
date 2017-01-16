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
statuses = 0 			# statuses (tweets + retweets)
tweets = 0 			# tweets = statuses - retweets
retweets_quotes = 0 		# retweets + quotes = 'RT' is in text in retweeted_status or quoted_status
				# (a quote is a retweet but also includes user's comment)
favourites_count_sum = [] 	# number of favourites/likes marked by this user
#replies_count_sum = [] 	# replies only
replies_mentions_count_sum = [] # replies + mentions (a mention is '@user')
				# both are direct communications or interactions
likes_count_sum = [] 		# number of favourites/likes received by this tweet
retweet_count_sum = []		# summed count of number of times a tweet is retweeted
lists_count_sum = [] 		# lists followed by this user / account age ratio
fo_fr_ratio_sum = [] 		# followers / friends ratio of this user
tweet_freq_sum = [] 		# statuses / days ratio of this user
fav_tw_ratio_sum = [] 		# favourites/likes of a tweet / statuses ratio of this user
daily_fav_freq = 0		# favourites / days
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
        if pline['user']['screen_name'].include? acct # == acct
	  if source_list.include? pline['source'] # match found
	    # do nothing
	  else
	    source_list.push(pline['source'])
	  end

          favourites_count = pline['user']['favourites_count'].to_f
          favourites_count_sum.push(favourites_count)

          likes_count = pline['favorite_count'].to_f
	  likes_count_sum.push(likes_count)

          retweet_count = pline['retweet_count'].to_f
	  retweet_count_sum.push(retweet_count)

	  if pline['user']['friends_count'] == 0
            fo_fr_ratio = pline['user']['followers_count'].to_f
	  else
	    fo_fr_ratio = pline['user']['followers_count'].to_f / pline['user']['friends_count'].to_f
	  end
          fo_fr_ratio_sum.push(fo_fr_ratio)
 
          user_time = Time.parse( pline['user']['created_at'] ).to_f
          tweet_time = Time.parse( pline['created_at'] ).to_f
          days = ( ( tweet_time - user_time ) / 60 / 60 / 24 ).to_f
          tweet_freq = pline['user']['statuses_count'].to_f / days
          tweet_freq_sum.push(tweet_freq)
          
	  lists_count = pline['user']['listed_count'].to_f / days
          lists_count_sum.push(lists_count)

          fav_tw_ratio = pline['favorite_count'].to_f / pline['user']['statuses_count'].to_f
          fav_tw_ratio_sum.push(fav_tw_ratio)

	  # can do ['entities']['user_mentions'] too but will skew
	  if pline['in_reply_to_status_id'] != nil or pline['text'].include? "@"
	    replies_mentions_count_sum.push(1)
	  end

          if pline['text'].include? "http" or pline['text'].match(/.[a-z]*\//) # captures all urls
	  #if pline['entities']['media'][0]['media_url'] != nil # only captures [entities]..[media_url] or [entities][url] (some are empty)
            urls_count += 1
	  end

          if pline['text'].include? "RT"
	    retweets_quotes += 1
	  end

          #k = k + (likes_count + retweet_count + lists_count + fo_fr_ratio + tweet_freq + fav_tw_ratio).to_f

          statuses += 1
        # retweeted
        elsif pline['retweeted_status']['user']['screen_name'].include? acct
	  if source_list.include? pline['source'] # match found
	    # do nothing
	  else
	    source_list.push(pline['source'])
	  end

          favourites_count = pline['retweeted_status']['user']['favourites_count'].to_f
          favourites_count_sum.push(favourites_count)

	  likes_count = pline['retweeted_status']['favorite_count'].to_f
	  likes_count_sum.push(likes_count)

          retweet_count = pline['retweeted_status']['retweet_count'].to_f
          retweet_count_sum.push(retweet_count)

	  if pline['retweeted_status']['user']['friends_count'] == 0
	    fo_fr_ratio = pline['retweeted_status']['user']['followers_count'].to_f # 7
	  else
	    fo_fr_ratio = pline['retweeted_status']['user']['followers_count'].to_f / pline['retweeted_status']['user']['friends_count'].to_f # 7
	  end
	  fo_fr_ratio_sum.push(fo_fr_ratio)

          user_time = Time.parse( pline['retweeted_status']['user']['created_at'] ).to_f
          tweet_time = Time.parse( pline['retweeted_status']['created_at'] ).to_f
          days = ( ( tweet_time - user_time ) / 60 / 60 / 24 ).to_f
          tweet_freq = pline['retweeted_status']['user']['statuses_count'].to_f / days
          tweet_freq_sum.push(tweet_freq)
          
	  lists_count = pline['retweeted_status']['user']['listed_count'].to_f / days
          lists_count_sum.push(lists_count)

          fav_tw_ratio = pline['retweeted_status']['favorite_count'].to_f / pline['retweeted_status']['user']['statuses_count'].to_f # 9
          fav_tw_ratio_sum.push(fav_tw_ratio)

	  # can do ['entities']['user_mentions'] too but will skew
	  if pline['retweeted_status']['in_reply_to_status_id'] != nil or pline['retweeted_status']['text'].include? "@"
	    replies_mentions_count_sum.push(1)
	  end
          
          if pline['text'].include? "http" or pline['text'].match(/.[a-z]*\//) # captures all urls
          #if pline['retweeted_status']['entities']['media'][0]['media_url'] != nil # only captures [entities]..[media_url] or [entities][url] (some are empty)
	    urls_count += 1
	  end

          if pline['retweeted_status']['text'].include? "RT"
	    retweets_quotes += 1
	  end

	  #k = k + (likes_count + retweet_count + lists_count + fo_fr_ratio + tweet_freq + fav_tw_ratio).to_f

          statuses += 1
        # quoted
        elsif pline['quoted_status']['user']['screen_name'].include? acct
	  if source_list.include? pline['source'] # match found
	    # do nothing
	  else
	    source_list.push(pline['source'])
	  end

          favourites_count = pline['quoted_status']['user']['favourites_count'].to_f
          favourites_count_sum.push(favourites_count)

          likes_count = pline['quoted_status']['favorite_count'].to_f
          likes_count_sum.push(likes_count)

          retweet_count = pline['quoted_status']['retweet_count'].to_f
          retweet_count_sum.push(retweet_count)

	  if pline['quoted_status']['user']['friends_count'] == 0
	    fo_fr_ratio = pline['quoted_status']['user']['followers_count'].to_f
	  else
	    fo_fr_ratio = pline['quoted_status']['user']['followers_count'].to_f / pline['quoted_status']['user']['friends_count'].to_f
	  end
	  fo_fr_ratio_sum.push(fo_fr_ratio)

          user_time = Time.parse( pline['quoted_status']['user']['created_at'] ).to_f
          tweet_time = Time.parse( pline['quoted_status']['created_at'] ).to_f
          days = ( ( tweet_time - user_time ) / 60 / 60 / 24 ).to_f
          tweet_freq = pline['quoted_status']['user']['statuses_count'].to_f / days
          tweet_freq_sum.push(tweet_freq)
          
	  lists_count = pline['quoted_status']['user']['listed_count'].to_f / days
          lists_count_sum.push(lists_count)

          fav_tw_ratio = pline['quoted_status']['favorite_count'].to_f / pline['quoted_status']['user']['statuses_count'].to_f
          fav_tw_ratio_sum.push(fav_tw_ratio)

	  # can do ['entities']['user_mentions'] too but will skew
	  if pline['quoted_status']['in_reply_to_status_id'] != nil or pline['quoted_status']['text'].include? "@"
	    replies_mentions_count_sum.push(1)
	  end
          
          if pline['text'].include? "http" or pline['text'].match(/.[a-z]*\//) # captures all urls
	  #if pline['quoted_status']['entities']['media'][0]['media_url'] != nil # only captures [entities]..[media_url] or [entities][url] (some are empty)
	    urls_count += 1
	  end
          
          if pline['quoted_status']['text'].include? "RT"
	    retweets_quotes += 1
	  end

	  #k = k + (likes_count + retweet_count + lists_count + fo_fr_ratio + tweet_freq + fav_tw_ratio).to_f

          statuses += 1
        end
      rescue
        next
      end
    end
    # statuses, tweets, retweets_quotes - all normalised by n days of dataset
    tweets = statuses - retweets_quotes
    # sum all arrays
    favourites_count_sumd = favourites_count_sum.inject(:+)
    replies_mentions_count_sumd = replies_mentions_count_sum.inject(:+)
    # autocorrect
    if replies_mentions_count_sumd.nil?
      replies_mentions_count_sumd = 0
    end
    likes_count_sumd = likes_count_sum.inject(:+)
    retweet_count_sumd = retweet_count_sum.inject(:+)
    lists_count_sumd = lists_count_sum.inject(:+)
    fo_fr_ratio_sumd = fo_fr_ratio_sum.inject(:+)
    tweet_freq_sumd = tweet_freq_sum.inject(:+)
    fav_tw_ratio_sumd = fav_tw_ratio_sum.inject(:+)
    # normalise, prep output, .fdiv is more stable than /
    # normalisation against statuses also ensures no repetitive sum
    # the ones not normalised are normalised by n days of dataset,
    # such as statuses, tweets, retweets_quotes, replies, urls, sources
    favourites_count_avgd = favourites_count_sumd.fdiv(statuses)
    likes_count_avgd = likes_count_sumd.fdiv(statuses)
    retweet_count_avgd = retweet_count_sumd.fdiv(statuses)
    lists_count_avgd = lists_count_sumd.fdiv(statuses)
    fo_fr_ratio_avgd = fo_fr_ratio_sumd.fdiv(statuses)
    tweet_freq_avgd = tweet_freq_sumd.fdiv(statuses)
    fav_tw_ratio_avgd = fav_tw_ratio_sumd.fdiv(statuses)
    daily_fav_freq = favourites_count_avgd.fdiv(days)
    out = "#{acct}, #{statuses}, #{tweets}, #{retweets_quotes}, #{favourites_count_avgd}, "
    out = out + "#{replies_mentions_count_sumd}, #{likes_count_avgd}, #{retweet_count_avgd}, "
    out = out + "#{lists_count_avgd}, #{fo_fr_ratio_avgd}, #{tweet_freq_avgd}, #{fav_tw_ratio_avgd}, #{days}, "
    out = out + "#{source_list.size}, #{urls_count}, #{daily_fav_freq}" # can do source_list.uniq but no need due to 'if else' above
    #out = out + ", #{k/statuses}"
    File.open("#{ARGV[1]}", 'a') do |f|
      f.puts(out)
    end # auto file close
    #puts out
    #out_json = {
    #  "screen_name" => "#{acct}",
    #  "statuses" => statuses,
    #  "tweets" => tweets,
    #  "retweets_quotes" => retweets_quotes,
    #  "favourites_count" => favourites_count_sum / statuses,
    #  "replies_count_sum" => replies_count_sum,
    #  "likes_count" => likes_count_sum / statuses,
    #  "retweet_count" => retweet_count_sum / statuses,
    #  "lists_count" => lists_count_sum / statuses,
    #  "fo_fr_ratio" => fo_fr_ratio_sum / statuses,
    #  "tweet_freq" => tweet_freq_sum / statuses,
    #  "fav_tw_ratio" => fav_tw_ratio_sum / statuses,
    #  "days" => days,
    #  "source_list" => "#{source_list.size}",
    #  "urls_count" => "#{urls_count}"
    #  "k" => k / statuses
    #}
    #puts out_json
    # reset vars
    pline = ""
    out = ""
    source_list.clear
    statuses = 0
    tweets = 0
    retweets_quotes = 0
    favourites_count_sum.clear
    replies_mentions_count_sum.clear
    likes_count_sum.clear
    retweet_count_sum.clear
    lists_count_sum.clear
    fo_fr_ratio_sum.clear
    tweet_freq_sum.clear
    fav_tw_ratio_sum.clear
    days, urls_count, k = 0, 0, 0
  rescue => e
    raise e
  end
end

