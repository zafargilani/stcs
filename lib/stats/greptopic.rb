# usage: ruby greptopic.rb /fully/qualified/path/to/topiclist[.txt] /fully/qualified/path/to/.gz[sources] /fully/qualified/path/to/output/directory
require 'zlib'
require 'json'
require 'time'

# filter out tweets (per topic or screenname) in their respective topic files

topic_list = []
File.open(ARGV[0], 'r') do |f|
  f.each_line do |line|
    topic_list.push("#{line.strip!}")
  end
end # auto file close
topic_list.uniq!
topic_list.sort!
#puts topic_list

pline = ""
tweet = ""

file_list = Dir.entries(ARGV[1])
file_list.delete(".") # remove . from the list
file_list.delete("..") # remove .. from the list
#file_list.sort!
#file_list.sort_by { |f| f.split("-")[2].to_i }
#puts file_list

file_list.each do |file|
  #puts ".. file: #{file} .."
  begin
    infile = open("#{ARGV[1]}/#{file}")
    gzi = Zlib::GzipReader.new(infile)
    gzi.each_line do |line|
      begin
        pline = JSON.parse(line)
	topic_list.each do |topic|
	  begin
            # check each line against the complete topic_list, instead of traversing over the whole .gz repeatedly
            if pline['user']['screen_name'].downcase.include? topic.downcase
              tweet = "#{pline['text']}"
            elsif pline['retweeted_status']['user']['screen_name'].downcase.include? topic.downcase
              tweet = "#{pline['retweeted_status']['text']}"
            elsif pline['quoted_status']['user']['screen_name'].downcase.include? topic.downcase
              tweet = "#{pline['quoted_status']['text']}"
	    elsif pline['text'].downcase.include? topic.downcase
              tweet = "#{pline['text']}"
            elsif pline['retweeted_status']['text'].downcase.include? topic.downcase
              tweet = "#{pline['retweeted_status']['text']}"
            elsif pline['quoted_status']['text'].downcase.include? topic.downcase
              tweet = "#{pline['quoted_status']['text']}"
	    else
	      tweet = ""
	    end
	
            if tweet != "" # write if not empty
	    #puts "found .. #{tweet} .. writing to file .."
              File.open("#{ARGV[2]}/#{topic}", 'a') do |f|
	        f.puts(JSON.generate(pline))
	      end # auto file close
	    end
	  rescue
	    next
	  end
	end
      rescue
        next
      end
    end
  rescue => e
    puts e
  end
end

