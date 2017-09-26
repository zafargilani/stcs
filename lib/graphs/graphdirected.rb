# usage: ruby graphdirected.rb /fully/qualified/path/to/directory[accts] /fully/qualified/path/to/file[.csv]
require 'zlib'
require 'json'
require 'time'

# read accounts from a file
# read accts/files from a directory
acct_list = Dir.entries(ARGV[0])
acct_list.delete(".") # remove . from the list
acct_list.delete("..") # remove .. from the list
acct_list.sort!

# using the raw/json file build a graph network for each user
# and the user's influence group (follower, retweet/quote, reply/mention)
# with node and edge weights,
# note that each tuple {acct,target} could have multiple rows
# with different values for edge weights (and slightly different
# for node weights) because each row is built using a single tweet,
# where each tweet has slightly different numbers as these numbers
# might have been updated from when the previous tweet was posted

pline = ""
out = ""

utc_time = 0
target = ""

directed = 0

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
	  directed = 1 # acct is retweeting, quoting, replying or mentioning other accts, therefore acct is target, target is acct

	  utc_time = Time.parse( pline['created_at'] ).to_i 

	  if pline.key?('retweeted_status') and !pline['retweeted_status']['user']['screen_name'].include? acct
	    target = pline['retweeted_status']['user']['screen_name']
	  elsif pline.key?('quoted_status') and !pline['quoted_status']['user']['screen_name'].include? acct
	    target = pline['quoted_status']['user']['screen_name']
	  end
	# retweet: if this acct is retweeting then some other acct tweeted
	elsif pline['retweeted_status']['user']['screen_name'].include? acct
	  directed = 0 # acct is being retweeted, quoted, replied or mentioned, therefore acct is acct, target is target
	  
	  utc_time = Time.parse( pline['retweeted_status']['created_at'] ).to_i

	  if pline.key?('user') and !pline['user']['screen_name'].include? acct
	    target = pline['user']['screen_name']
	  elsif pline.key?('quoted_status') and !pline['quoted_status']['user']['screen_name'].include? acct
	    target = pline['quoted_status']['user']['screen_name']
	  end
	# quoted: if this acct is quoting then some other acct tweeted
	elsif pline['quoted_status']['user']['screen_name'].include? acct
	  directed = 0 # acct is being retweeted, quoted, replied or mentioned, therefore acct is acct, target is target
	  
	  utc_time = Time.parse( pline['quoted_status']['created_at'] ).to_i
	  
	  if pline.key?('user') and !pline['user']['screen_name'].include? acct
	    target = pline['user']['screen_name']
	  elsif pline.key?('retweeted_status') and !pline['retweeted_status']['user']['screen_name'].include? acct
	    target = pline['retweeted_status']['user']['screen_name']
	  end
	end
      rescue
        next
      end
      if directed == 0
        out = "#{acct},#{target},#{utc_time}"
      elsif directed == 1
        out = "#{target},#{acct},#{utc_time}"
      end
      File.open("#{ARGV[1]}", 'a') do |f|
        f.puts(out)
      end # auto file close
    end
  rescue => e
    puts e
  end
end

