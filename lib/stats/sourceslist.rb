# usage: ruby sourceslist.rb /fully/qualified/path/to/directory[accts] /fully/qualified/path/to/file[.txt]
require 'zlib'
require 'json'

# read accounts from a file
# read accts/files from a directory
acct_list = Dir.entries(ARGV[0])
acct_list.delete(".") # remove . from the list
acct_list.delete("..") # remove .. from the list
acct_list.sort!

# get user sources from raw tweets/json
# dump this in an output file from time to time

pline = ""
out = ""
source_list = Hash.new(0)
max_depth = 0

acct_list.each do |acct|
  begin
    infile = open("#{ARGV[0]}/#{acct}")
    #gzi = Zlib::GzipReader.new(infile)
    #gzi.each_line do |line|
    infile.each_line do |line|
      begin
        pline = JSON.parse(line)
	if pline['user']['screen_name'].include? acct # == acct
	  source_list["#{pline['source']}"] += 1
	elsif pline['retweeted_status']['user']['screen_name'].include? acct
	  source_list["#{pline['retweeted_status']['source']}"] += 1
	elsif pline['quoted_status']['user']['screen_name'].include? acct
	  source_list["#{pline['quoted_status']['source']}"] += 1
	end
      rescue
        next
      end
    end
  rescue => e
    puts e
  end
end
#out = "#{source_list.flatten}"
out = "#{source_list.keys}\n#{source_list.values}"
File.open("#{ARGV[1]}", 'a') do |f|
  f.puts(out)
end # auto file close

