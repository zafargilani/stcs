# usage: ruby graphrepliesmentions.rb /fully/qualified/path/to/directory[accts] /fully/qualified/path/to/file[.csv]
require 'zlib'
require 'json'
require 'time'

# graph is formed from influencer and influenced, i.e.
# retweeted statuses, quoted statuses, replies and mentions

# from raw/json tweets get graph network of each user,
# here -- replies and mentions (very low activity)

# read accounts from a file
# read accts/files from a directory
acct_list = Dir.entries(ARGV[0])
acct_list.delete(".") # remove . from the list
acct_list.delete("..") # remove .. from the list
acct_list.sort!

pline = ""
out = ""
target = ""

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
	  if pline['in_reply_to_screen_name'] != nil
            target = pline['in_reply_to_screen_name']
	  else
	    target = pline['entities']['user_mentions']['screen_name']
	  end
        # retweeted
        elsif pline['retweeted_status']['user']['screen_name'].include? acct
	  if pline['retweeted_status']['in_reply_to_screen_name'] != nil
            target = pline['retweeted_status']['in_reply_to_screen_name']
	  else
	    target = pline['retweeted_status']['entities']['user_mentions']['screen_name']
	  end
        # quoted
        elsif pline['quoted_status']['user']['screen_name'].include? acct
	  if pline['quoted_status']['in_reply_to_screen_name'] != nil
            target = pline['quoted_status']['in_reply_to_screen_name']
	  else
	    target = pline['quoted_status']['entities']['user_mentions']['screen_name']
	  end
        end
      rescue
        next
      end
      out = "#{acct},#{target}"
      File.open("#{ARGV[1]}", 'a') do |f|
        f.puts(out)
      end # auto file close
    end
  rescue => e
    puts e
  end
end

