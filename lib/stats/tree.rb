# usage: ruby tree.rb /fully/qualified/path/to/directory[accts] /fully/qualified/path/to/file[.txt]
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
tree_list = []
max_depth = 0

acct_list.each do |acct|
  begin
    infile = open("#{ARGV[0]}/#{acct}")
    #gzi = Zlib::GzipReader.new(infile)
    #gzi.each_line do |line|
    infile.each_line do |line|
      begin
        pline = JSON.parse(line)
        # simple case: original tweet
        if pline["user"]["screen_name"].include? acct # == acct
          # do nothing
        # retweeted
        elsif pline["retweeted_status"]["user"]["screen_name"].include? acct
          tree_list.push(pline["user"]["screen_name"])
        # quoted
        elsif pline["quoted_status"]["user"]["screen_name"].include? acct
          tree_list.push(pline["user"]["screen_name"])
        end
      rescue
        next
      end
    end
    # if you don't like JSON
    out = "#{acct}: #{tree_list}"
    File.open("#{ARGV[1]}", 'a') do |f|
      f.puts(out)
    end # auto file close
    #out_json = {
    #  "screen_name" => "#{acct}",
    #  "tree" => "#{tree_list}"
    #}
    #puts out_json
    # reset vars
    tree_list.clear
  rescue => e
    puts e
  end
end

