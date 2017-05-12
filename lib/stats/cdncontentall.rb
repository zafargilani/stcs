# usage: ruby cdncontentall.rb /fully/qualified/path/to/directory[accts] /fully/qualified/path/to/file[.csv]
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
	if pline['user']['screen_name'].include? acct
	  size = `curl -sI #{pline['entities']['media'][0]['media_url_https']} | grep -i 'Content-Length' | awk '{print}' ORS='" ' | awk -F'\"' '{print $2}' | awk -F': ' '{print $2}'` # media_url or media_url_https

	elsif pline['retweeted_status']['user']['screen_name'].include? acct
	  size = `curl -sI #{pline['retweeted_status']['entities']['media'][0]['media_url_https']} | grep -i 'Content-Length' | awk '{print}' ORS='" ' | awk -F'\"' '{print $2}' | awk -F': ' '{print $2}'`

	elsif pline['quoted_status']['user']['screen_name'].include? acct
	  size = `curl -sI #{pline['quoted_status']['entities']['media'][0]['media_url_https']} | grep -i 'Content-Length' | awk '{print}' ORS='" ' | awk -F'\"' '{print $2}' | awk -F': ' '{print $2}'`
	end
	content_size.push( size.to_f / 1024 )
      rescue
        next
      end
    end
    # note that cdn content size is normalised by n days of dataset
    out = "#{acct}: #{content_size.inject(0){ |sum, x| sum + x }} KB" # bytes to KB to MB
    File.open("#{ARGV[1]}", 'a') do |f|
      f.puts(out)
    end # auto file close 
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

