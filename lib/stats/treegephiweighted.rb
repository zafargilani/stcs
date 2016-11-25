# usage: ruby treegephiweighted.rb /fully/qualified/path/to/directory[accts] /fully/qualified/path/to/file[.txt]
require 'zlib'
require 'json'
require 'time'

# read accounts from a file
# read accts/files from a directory
acct_list = Dir.entries(ARGV[0])
acct_list.delete(".") # remove . from the list
acct_list.delete("..") # remove .. from the list
acct_list.sort!

# get user tree from raw tweets/json
# dump this in an output file from time to time

pline = ""
out = ""

days = 0
tweet_freq = 0
fo_fr_ratio = 0
node_weight = 0 # fo_fr_ratio / tweet_freq

target = ""
in_reply_to_screen_name = ""
replies = 0
fo_fr_ratio_acct = 0
fo_fr_ratio_target = 0
edge_weight = 0 # replies * (fo_fr_ratio_acct / fo_fr_ratio_target)

max_depth = 0

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
        # original tweet
        if pline['user']['screen_name'].include? acct # == acct
	  days = ( ( Time.parse( pline['created_at'] ).to_f - Time.parse( pline['user']['created_at'] ).to_f ) / 60 / 60 / 24 ).to_f
	  tweet_freq = pline['user']['statuses_count'].to_f / days
	  
	  fo_fr_ratio = pline['user']['followers_count'].to_f / pline['user']['friends_count'].to_f
	end
	
	node_weight =  fo_fr_ratio / tweet_freq

	# calculate edge weight: product of no. of replies between two nodes
	# and ratio of fo_fr_ratios of two nodes
	in_reply_to_screen_name = pline["in_reply_to_screen_name"]

	# retweeted
        if pline['retweeted_status']['user']['screen_name'].include? acct
          target = pline['user']['screen_name']
	  
	  if in_reply_to_screen_name == pline['retweeted_status']['user']['screen_name']
	    replies = 1
	  else
	    replies = 0.1
	  end

	  fo_fr_ratio_acct = pline['retweeted_status']['user']['followers_count'].to_f / pline['retweeted_status']['user']['friends_count'].to_f
	  fo_fr_ratio_target = pline['user']['followers_count'].to_f / pline['user']['friends_count'].to_f
        # quoted
        elsif pline['quoted_status']['user']['screen_name'].include? acct
          target = pline['user']['screen_name']
	  
	  if in_reply_to_screen_name == pline['quoted_status']['user']['screen_name']
	    replies = 1
	  else
	    replies = 0.1
	  end

	  fo_fr_ratio_acct = pline['quoted_status']['user']['followers_count'].to_f / pline['quoted_status']['user']['friends_count'].to_f
	  fo_fr_ratio_target = pline['user']['followers_count'].to_f / pline['user']['friends_count'].to_f
        end

	edge_weight = replies * (fo_fr_ratio_acct / fo_fr_ratio_target)
      rescue
        next
      end
      out = "#{acct},#{target},#{node_weight},#{edge_weight}"
      File.open("#{ARGV[1]}", 'a') do |f|
        f.puts(out)
      end # auto file close
    end
  rescue => e
    puts e
  end
end

