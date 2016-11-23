# usage: ruby text.rb /fully/qualified/path/to/directory[accts] /fully/qualified/path/to/output/directory
require 'zlib'
require 'json'

# read accounts from a file
# read accts/files from a directory
acct_list = Dir.entries(ARGV[0])
acct_list.delete(".") # remove . from the list
acct_list.delete("..") # remove .. from the list
acct_list.sort!

# get user source from raw tweets/json
# dump this in an output file from time to time

pline = ""
out = ""

acct_list.each do |acct|
  begin
    infile = open("#{ARGV[0]}/#{acct}")
    #gzi = Zlib::GzipReader.new(infile)
    #gzi.each_line do |line|
    infile.each_line do |line|
      begin
        pline = JSON.parse(line)
	if pline['user']['screen_name'].include? acct # == acct
          out = out + "#{pline['text']}\n"
	elsif pline['retweeted_status']['user']['screen_name'].include? acct
          out = out + "#{pline['text']}\n"
	elsif pline['quoted_status']['user']['screen_name'].include? acct
          out = out + "#{pline['text']}\n"
	end
      rescue
        next
      end
    end
    # if you don't like JSON
    File.open("#{ARGV[1]}/#{acct}", 'w') { |file| file.write(out) }
    #out = "#{source_list}"
    #puts out
    #out_json = {
    #  "screen_name" => "#{acct}",
    #  "tree" => "#{source_list}"
    #}
    #puts out_json
    # reset vars
    out = ""
  rescue => e
    puts e
  end
end

