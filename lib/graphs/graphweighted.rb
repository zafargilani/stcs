# usage: ruby graphweighted.rb /fully/qualified/path/to/directory[accts] /fully/qualified/path/to/file[.csv]
require 'zlib'
require 'json'
require 'time'

# from raw/json tweets get a graph network for each user,
# retweets and quotes only (very high activity),
# with node and edge weights

# note that each tuple {acct,target} could have multiple rows
# with different values for edge weights (and slightly different
# for node weights) because each row is built using a single tweet,
# where each tweet has slightly different numbers as these numbers
# might have been updated from when the previous tweet was posted

# read accounts from a file
# read accts/files from a directory
acct_list = Dir.entries(ARGV[0])
acct_list.delete(".") # remove . from the list
acct_list.delete("..") # remove .. from the list
acct_list.sort!

pline = ""
out = ""

days_acct = 0
tweet_freq = 0
fo_fr_ratio_acct = 0
node_weight = 0 # fo_fr_ratio_acct / tweet_freq

target = ""
in_reply_to_screen_name = ""
days_target = ""
replies_mentions = 0
fo_fr_ratio_target = 0
edge_weight = 0 # replies_mentions * (fo_fr_ratio_acct / fo_fr_ratio_target)

acct_list.each do |acct|
  begin
    infile = open("#{ARGV[0]}/#{acct}")
    #gzi = Zlib::GzipReader.new(infile)
    #gzi.each_line do |line|
    infile.each_line do |line|
      begin
        pline = JSON.parse(line)
	# calculate node weight: ratio of fo_fr_ratio (more indicative of human)
	# and tweet_freq (more indicative of bot)
        
	# calculate edge weight: product of no. of replies or mentions between two nodes
	# and ratio of fo_fr_ratios of two nodes
	
	# original tweet: if this acct is tweeting, then some other acct might have retweeted or quoted
        if pline['user']['screen_name'].include? acct
	  days_acct = ( ( Time.parse( pline['created_at'] ).to_f 
		    - Time.parse( pline['user']['created_at'] ).to_f ) / 60 / 60 / 24 ).to_f
	  #tweet_freq = pline['user']['statuses_count'].to_f / days_acct
	 
	  if pline['user']['friends_count'] == 0 
	    fo_fr_ratio_acct = pline['user']['followers_count'].to_f
	  else
	    fo_fr_ratio_acct = pline['user']['followers_count'].to_f / pline['user']['friends_count'].to_f
	  end

	  if pline.key?('retweeted_status')
	    target = pline['retweeted_status']['user']['screen_name']
	    days_target = ( ( Time.parse( pline['retweeted_status']['created_at'] ).to_f 
		    - Time.parse( pline['retweeted_status']['user']['created_at'] ).to_f ) / 60 / 60 / 24 ).to_f
	    replies_mentions = 1
	    fo_fr_ratio_target = pline['retweeted_status']['user']['followers_count'].to_f / pline['retweeted_status']['user']['friends_count'].to_f
	  elsif pline.key?('quoted_status')
	    target = pline['quoted_status']['user']['screen_name']
	    days_target = ( ( Time.parse( pline['quoted_status']['created_at'] ).to_f 
		    - Time.parse( pline['quoted_status']['user']['created_at'] ).to_f ) / 60 / 60 / 24 ).to_f
	    replies_mentions = 0.5
	    fo_fr_ratio_target = pline['quoted_status']['user']['followers_count'].to_f / pline['quoted_status']['user']['friends_count'].to_f
	  else
	    days_target = days_acct
	    replies_mentions = 0.01
	    fo_fr_ratio_target = 0.01
	  end
	# retweet: if this acct is retweeting then some other acct tweeted
	elsif pline['retweeted_status']['user']['screen_name'].include? acct
	  days_acct = ( ( Time.parse( pline['retweeted_status']['created_at'] ).to_f 
		    - Time.parse( pline['retweeted_status']['user']['created_at'] ).to_f ) / 60 / 60 / 24 ).to_f
	  #tweet_freq = pline['retweeted_status']['user']['statuses_count'].to_f / days_acct
	 
	  if pline['retweeted_status']['user']['friends_count'] == 0 
	    fo_fr_ratio_acct = pline['retweeted_status']['user']['followers_count'].to_f
	  else
	    fo_fr_ratio_acct = pline['retweeted_status']['user']['followers_count'].to_f / pline['retweeted_status']['user']['friends_count'].to_f
	  end
	  
	  if pline.key?('user')
	    target = pline['user']['screen_name']
	    days_target = ( ( Time.parse( pline['created_at'] ).to_f 
		    - Time.parse( pline['user']['created_at'] ).to_f ) / 60 / 60 / 24 ).to_f
	    replies_mentions = 1
	    fo_fr_ratio_target = pline['user']['followers_count'].to_f / pline['user']['friends_count'].to_f
	  elsif pline.key?('quoted_status')
	    target = pline['quoted_status']['user']['screen_name']
	    days_target = ( ( Time.parse( pline['quoted_status']['created_at'] ).to_f 
		    - Time.parse( pline['quoted_status']['user']['created_at'] ).to_f ) / 60 / 60 / 24 ).to_f
	    replies_mentions = 0.5
	    fo_fr_ratio_target = pline['quoted_status']['user']['followers_count'].to_f / pline['quoted_status']['user']['friends_count'].to_f
	  else
	    days_target = days_acct
	    replies_mentions = 0.01
	    fo_fr_ratio_target = 0.01
	  end
	# quoted: if this acct is quoting then some other acct tweeted
	elsif pline['quoted_status']['user']['screen_name'].include? acct
	  days_acct = ( ( Time.parse( pline['quoted_status']['created_at'] ).to_f 
		    - Time.parse( pline['quoted_status']['user']['created_at'] ).to_f ) / 60 / 60 / 24 ).to_f
	  #tweet_freq = pline['quoted_status']['user']['statuses_count'].to_f / days_acct
	 
	  if pline['quoted_status']['user']['friends_count'] == 0 
	    fo_fr_ratio_acct = pline['quoted_status']['user']['followers_count'].to_f
	  else
	    fo_fr_ratio_acct = pline['quoted_status']['user']['followers_count'].to_f / pline['quoted_status']['user']['friends_count'].to_f
	  end
	  
	  if pline.key?('user')
	    target = pline['user']['screen_name']
	    days_target = ( ( Time.parse( pline['created_at'] ).to_f 
		    - Time.parse( pline['user']['created_at'] ).to_f ) / 60 / 60 / 24 ).to_f
	    replies_mentions = 0.5
	    fo_fr_ratio_target = pline['user']['followers_count'].to_f / pline['user']['friends_count'].to_f
	  elsif pline.key?('retweeted_status')
	    target = pline['retweeted_status']['user']['screen_name']
	    days_target = ( ( Time.parse( pline['retweeted_status']['created_at'] ).to_f 
		    - Time.parse( pline['retweeted_status']['user']['created_at'] ).to_f ) / 60 / 60 / 24 ).to_f
	    replies_mentions = 1
	    fo_fr_ratio_target = pline['retweeted_status']['user']['followers_count'].to_f / pline['retweeted_status']['user']['friends_count'].to_f
	  else
	    days_target = days_acct
	    replies_mentions = 0.01
	    fo_fr_ratio_target = 0.01
	  end
	end
	
	#node_weight = fo_fr_ratio_acct / tweet_freq
	node_weight = fo_fr_ratio_acct / days_acct
	# node_weight is normalised, but for manual normalisation see below
	# normalise: run with above, use the generated files to get Xmax and Xmin, re-run to normalise
	# sort -s -t, -k3 -gr gephigraph2weighted.2016-4.bots.10M | less
	# sort -s -t, -k3 -g  gephigraph2weighted.2016-4.bots.10M | less
	#node_weight = (node_weight - 0.0001) / (2801473 - 0.0001) # for bots.10M
	#node_weight = (node_weight - 0.008) / (1781 - 0.008) # for bots.1M.old
	#node_weight = (node_weight - 5.70e-06) / (301132 - 5.70e-06) # for humans.10M
	#node_weight = (node_weight - 0.05) / (21350 - 0.05) # for humans.1M.old

	edge_weight = replies_mentions * (fo_fr_ratio_acct / fo_fr_ratio_target) / days_target
	# edge_weight is normalised, but for manual normalisation see below
	# normalise: run with above, use the generated files to get Xmax and Xmin, re-run to normalise
	# sort -s -t, -k4 -gr gephigraph2weighted.2016-4.bots.10M | less
	# sort -s -t, -k4 -g  gephigraph2weighted.2016-4.bots.10M | less
	#edge_weight = (edge_weight - 4.07e-05) / (202486679 - 4.07e-05) # for bots.10M
	#edge_weight = (edge_weight - 7.2e-06) / (9142013 - 7.2e-06) # for bots.1M.old
	#edge_weight = (edge_weight - 0.0005) / (15633768 - 0.0005) # for humans.10M
	#edge_weight = (edge_weight - 2.75e-05) / (1260866 - 2.75e-05) # for humans.1M.old
      rescue
        next
      end
      out = "#{acct},#{target},#{node_weight.abs},#{edge_weight.abs}"
      File.open("#{ARGV[1]}", 'a') do |f|
        f.puts(out)
      end # auto file close
    end
  rescue => e
    puts e
  end
end

