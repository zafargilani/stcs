# usage: ruby source.rb /fully/qualified/path/to/directory[accts] > source.txt
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
source_list = []
max_depth = 0

acct_list.each do |acct|
  begin
    infile = open("#{ARGV[0]}/#{acct}")
    #gzi = Zlib::GzipReader.new(infile)
    #gzi.each_line do |line|
    infile.each_line do |line|
      begin
        pline = JSON.parse(line)
	if pline["user"]["screen_name"] == acct
	  if source_list.include? pline["source"] # match found
	    # do nothing
	  else
            source_list.push(pline["source"])
	  end
        end
      rescue
        next
      end
    end
    # if you don't like JSON
    out = "#{acct}: #{source_list}"
    puts out
    #out_json = {
    #  "screen_name" => "#{acct}",
    #  "tree" => "#{source_list}"
    #}
    #puts out_json
    # reset vars
    source_list.clear
  rescue => e
    puts e
  end
end

