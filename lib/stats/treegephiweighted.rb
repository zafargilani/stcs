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
target = ""
fo_fr_ratio = 0
favourited_count = 0
days = 0
tweet_freq = 0
favourited_count_tweet_freq_ratio = 0
max_depth = 0

acct_list.each do |acct|
  begin
    infile = open("#{ARGV[0]}/#{acct}")
    #gzi = Zlib::GzipReader.new(infile)
    #gzi.each_line do |line|
    infile.each_line do |line|
      begin
        pline = JSON.parse(line)
	# retweets/quotes graph of the acct
        # original tweet
        if pline["user"]["screen_name"].include? acct # == acct
	  # fo_fr_ratio
	  fo_fr_ratio = pline["user"]["followers_count"].to_f / pline["user"]["friends_count"].to_f
	  # favourited_count_tweet_freq_ratio
	  favourited_count = ( pline["user"]["favourites_count"] ).to_f
	  days = ( ( Time.parse( pline["created_at"] ).to_f - Time.parse( pline["user"]["created_at"] ).to_f ) / 60 / 60 / 24 ).to_f
	  tweet_freq = pline["user"]["statuses_count"].to_f / days
	  favourited_count_tweet_freq_ratio = favourited_count / tweet_freq
	end
	# retweeted
        if pline["retweeted_status"]["user"]["screen_name"].include? acct
          target = pline["user"]["screen_name"]
        # quoted
        elsif pline["quoted_status"]["user"]["screen_name"].include? acct
          target = pline["user"]["screen_name"]
        end
      rescue
        next
      end
      out = "#{acct},#{target},#{fo_fr_ratio},#{favourited_count},#{favourited_count_tweet_freq_ratio}"
      File.open("#{ARGV[1]}", 'a') do |f|
        f.puts(out)
      end # auto file close
    end
  rescue => e
    puts e
  end
end

