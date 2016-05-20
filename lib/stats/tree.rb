require 'zlib'
require 'json'
require 'time'

# read accounts from a file
acct_list = []
begin
  acct_file = open("accts.list")
  acct_file.each_line do |l|
    acct_list.push(l.slice(0..(l.index(':')-1)))#.delete!("\n")) # slice and get the pesky newline characters removed
  end
  acct_file.close()
rescue => e
  puts e
end

# get user tree from raw tweets/json
# dump this in an output file from time to time

pline = ""
out = ""
tree_list = []
max_depth = 0

acct_list.each do |acct|
  begin
    infile = open("/data2/zf-twitter-classifier/2016-4.#{acct}")#.concat(acct))
    #gzi = Zlib::GzipReader.new(infile)
    #gzi.each_line do |line|
    infile.each_line do |line|
      begin
        pline = JSON.parse(line)
        # simple case: original tweet
        if pline["user"]["screen_name"] == acct
          # do nothing
        # retweeted
        elsif pline["retweeted_status"]["user"]["screen_name"] == acct
          tree_list.push(pline["user"]["screen_name"])
        # quoted
        elsif pline["quoted_status"]["user"]["screen_name"] == acct
          tree_list.push(pline["user"]["screen_name"])
        end
      rescue
        next
      end
    end
    # Liang doesn't like JSON
    out = "#{acct}: #{tree_list}"
    puts out
    #out_json = {
    #  "screen_name" => "#{acct}",
    #  "tree" => "#{tree_list}"
    #}
    #puts out_json
    # reset vars
  rescue => e
    puts e
  end
end

