# usage: ruby graphretweetsquotes.rb /fully/qualified/path/to/directory[accts] /fully/qualified/path/to/file[.csv]
require 'zlib'
require 'json'
require 'time'

# graph is formed from influencer and influenced, i.e.
# retweeted statuses, quoted statuses, replies and mentions

# from raw/json tweets get graph network of each user,
# here -- retweets and quotes (very high activity)

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
          # do nothing
        # retweeted
        elsif pline['retweeted_status']['user']['screen_name'].include? acct
          target = pline['user']['screen_name']
        # quoted
        elsif pline['quoted_status']['user']['screen_name'].include? acct
          target = pline['user']['screen_name']
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

