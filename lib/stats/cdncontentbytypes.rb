# usage: ruby cdncontentbytypes.rb photo|animated_gif|video /fully/qualified/path/to/directory[accts] /fully/qualified/path/to/file[.txt]
require 'zlib'
require 'json'

# read accounts from a file
# read accts/files from a directory
acct_list = Dir.entries(ARGV[1])
acct_list.delete(".") # remove . from the list
acct_list.delete("..") # remove .. from the list
acct_list.sort!

# measure Twitter content size for different content types
# Twitter user uploaded content types: photo:large, animated_gif, video [1]
# Twitter auto-generated content types: photo:thumb, photo:small, photo:medium,
#   video [0], video's photo (:thumb, :small, :medium, :large)
# ref: https://dev.twitter.com/overview/api/entities-in-twitter-objects

pline = ""
out = ""

content_size_photo = []
content_size_animated_gif = []
content_size_video = []

acct_list.each do |acct|
  begin
    infile = open("#{ARGV[1]}/#{acct}")
    #gzi = Zlib::GzipReader.new(infile)
    #gzi.each_line do |line|
    infile.each_line do |line|
      begin
        pline = JSON.parse(line)
	if pline['user']['screen_name'].include? acct
	  if pline['entities']['media'][0]['type'].include? "photo" and ARGV[0] == "photo" # photo:large
	    size = `curl -sI #{pline['entities']['media'][0]['media_url_https']}:large | grep -i 'Content-Length' | awk '{print}' ORS='" ' | awk -F'\"' '{print $2}' | awk -F': ' '{print $2}'`
	    content_size_photo.push(size.to_i)
	  elsif pline['extended_entities']['media'][0]['type'].include? "animated_gif" and ARGV[0] == "animated_gif" # animated gif saved as mp4 with bitrate 0 on Twitter
	    size = `curl -sI #{pline['extended_entities']['media'][0]['video_info']['variants'][0]['url']} | grep -i 'Content-Length' | awk '{print}' ORS='" ' | awk -F'\"' '{print $2}' | awk -F': ' '{print $2}'`
	    content_size_animated_gif.push(size.to_i)
	  elsif pline['extended_entities']['media'][0]['type'].include? "video" and ARGV[0] == "video" # video [1] with higher bitrate
	    size = `curl -sI #{pline['extended_entities']['media'][0]['video_info']['variants'][1]['url']} | grep -i 'Content-Length' | awk '{print}' ORS='" ' | awk -F'\"' '{print $2}' | awk -F': ' '{print $2}'`
	    content_size_video.push(size.to_i)
	  end

	elsif pline['retweeted_status']['user']['screen_name'].include? acct
	  if pline['retweeted_status']['entities']['media'][0]['type'].include? "photo" and ARGV[0] == "photo" # photo:large
	    size = `curl -sI #{pline['retweeted_status']['entities']['media'][0]['media_url_https']}:large | grep -i 'Content-Length' | awk '{print}' ORS='" ' | awk -F'\"' '{print $2}' | awk -F': ' '{print $2}'`
	    content_size_photo.push(size.to_i)
	  elsif pline['retweeted_status']['extended_entities']['media'][0]['type'].include? "animated_gif" and ARGV[0] == "animated_gif" # animated gif saved as mp4 with bitrate 0 on Twitter
	    size = `curl -sI #{pline['retweeted_status']['extended_entities']['media'][0]['video_info']['variants'][0]['url']} | grep -i 'Content-Length' | awk '{print}' ORS='" ' | awk -F'\"' '{print $2}' | awk -F': ' '{print $2}'`
	    content_size_animated_gif.push(size.to_i)
	  elsif pline['retweeted_status']['extended_entities']['media'][0]['type'].include? "video" and ARGV[0] == "video" # video [1] with higher bitrate
	    size = `curl -sI #{pline['retweeted_status']['extended_entities']['media'][0]['video_info']['variants'][1]['url']} | grep -i 'Content-Length' | awk '{print}' ORS='" ' | awk -F'\"' '{print $2}' | awk -F': ' '{print $2}'`
	    content_size_video.push(size.to_i)
	  end

	elsif pline['quoted_status']['user']['screen_name'].include? acct
	  if pline['quoted_status']['entities']['media'][0]['type'].include? "photo" and ARGV[0] == "photo" # photo:large
	    size = `curl -sI #{pline['quoted_status']['entities']['media'][0]['media_url_https']}:large | grep -i 'Content-Length' | awk '{print}' ORS='" ' | awk -F'\"' '{print $2}' | awk -F': ' '{print $2}'`
	    content_size_photo.push(size.to_i)
	  elsif pline['quoted_status']['extended_entities']['media'][0]['type'].include? "animated_gif" and ARGV[0] == "animated_gif" # animated gif saved as mp4 with bitrate 0 on Twitter
	    size = `curl -sI #{pline['quoted_status']['extended_entities']['media'][0]['video_info']['variants'][0]['url']} | grep -i 'Content-Length' | awk '{print}' ORS='" ' | awk -F'\"' '{print $2}' | awk -F': ' '{print $2}'`
	    content_size_animated_gif.push(size.to_i)
	  elsif pline['quoted_status']['extended_entities']['media'][0]['type'].include? "video" and ARGV[0] == "video" # video [1] with higher bitrate
	    size = `curl -sI #{pline['quoted_status']['extended_entities']['media'][0]['video_info']['variants'][1]['url']} | grep -i 'Content-Length' | awk '{print}' ORS='" ' | awk -F'\"' '{print $2}' | awk -F': ' '{print $2}'`
	    content_size_video.push(size.to_i)
	  end
	end
      rescue
        next
      end
    end
    # write output, all values in KB
    if ARGV[0] == "photo"
      out = "#{acct}, #{content_size_photo.inject(0){ |sum, x| sum + x }.fdiv(1024)}"
    elsif ARGV[0] == "animated_gif"
      out = "#{acct}, #{content_size_animated_gif.inject(0){ |sum, x| sum + x }.fdiv(1024)}"
    elsif ARGV[0] == "video"
      out = "#{acct}, #{content_size_video.inject(0){ |sum, x| sum + x }.fdiv(1024)}"
    end
    File.open("#{ARGV[2]}", 'a') do |f|
      f.puts(out)
    end # auto file close
    # reset vars
    out = ""
    content_size_photo.clear
    content_size_animated_gif.clear
    content_size_video.clear
  rescue => e
    puts e
  end
end

