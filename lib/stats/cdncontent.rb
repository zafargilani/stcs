# usage: ruby cdncontent.rb /fully/qualified/path/to/directory[accts] > cdncontent.txt
require 'zlib'
require 'json'

# read accounts from a file
# read accts/files from a directory
acct_list = Dir.entries(ARGV[0])
acct_list.delete(".") # remove . from the list
acct_list.delete("..") # remove .. from the list
acct_list.sort!

# get size of user content uploaded on Twitter CDN (*.twimg.*) from raw tweets/json
# via wget --spider or curl --head
# dump this in an output file from time to time

pline = ""
out = ""
content_size = []

acct_list.each do |acct|
  begin
    infile = open("#{ARGV[0]}/#{acct}")
    #gzi = Zlib::GzipReader.new(infile)
    #gzi.each_line do |line|
    infile.each_line do |line|
      begin
        pline = JSON.parse(line)
	if pline["user"]["screen_name"] == acct
	  if pline["entities"]["media"][0]["media_url"].include? "twimg" # /[a-z]*.twimg.[a-z]*/
	    size = `wget #{pline["entities"]["media"][0]["media_url"]} --spider --server-response -O - 2>&1 | sed -ne '/Content-Length/{s/.*: //;p}'`
	    content_size.push( size.to_f / 1024 )
	  end
	elsif pline["retweeted_status"]["user"]["screen_name"] == acct
	  if pline["retweeted_status"]["entities"]["media"][0]["media_url"].include? "twimg" # /[a-z]*.twimg.[a-z]*/
	    size = `wget #{pline["retweeted_status"]["entities"]["media"][0]["media_url"]} --spider --server-response -O - 2>&1 | sed -ne '/Content-Length/{s/.*: //;p}'`
	    content_size.push( size.to_f / 1024 )
	  end
	elsif pline["quoted_status"]["user"]["screen_name"] == acct
	  if pline["quoted_status"]["entities"]["media"][0]["media_url"].include? "twimg" # /[a-z]*.twimg.[a-z]*/
	    size = `wget #{pline["quoted_status"]["entities"]["media"][0]["media_url"]} --spider --server-response -O - 2>&1 | sed -ne '/Content-Length/{s/.*: //;p}'`
	    content_size.push( size.to_f / 1024 )
	  end
	end
      rescue
        next
      end
    end
    # if you don't like JSON
    out = "#{acct}: #{content_size.inject(0){ |sum, x| sum + x }} KB" # bytes to KB to MB
    puts out
    #out_json = {
    #  "screen_name" => "#{acct}",
    #  "total_content_size" => "#{content_size}"
    #}
    #puts out_json
    # reset vars
    content_size.clear
  rescue => e
    puts e
  end
end

