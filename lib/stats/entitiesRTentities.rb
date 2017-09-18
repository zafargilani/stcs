# usage: ruby entitiesRTentities.rb /fully/qualified/path/to/directory[bot|human] /fully/qualified/path/to/list[bot|human] /fully/qualified/path/to/output
require 'json'
require 'time'

# parse through two lists to check entities performing retweets of same or other entities
# i.e. bots RTing bots, bots RTing humans, humans RTing bots, humans RTing humans

list_in = []
f = File.open(ARGV[1])
f.each_line do |line|
  list_in.push(line.tr("\n", ""))
end
#puts "list: #{list_in}"

count = 0
pline = ""
out = ""

list_out = []

file_list = Dir.entries(ARGV[0])
file_list.delete(".") # remove . from the list
file_list.delete("..") # remove .. from the list
file_list.sort!
#puts "files: #{file_list}"

file_list.each do |file|
  begin
    infile = open("#{ARGV[0]}/#{file}")
    infile.each_line do |line|
      begin
        pline = JSON.parse(line)
        if file_list.include? pline['user']['screen_name'] # not all tweets are by this user, some are retweets, some mentions
	  if list_in.include? pline['retweeted_status']['user']['screen_name']
	    list_out.push(pline['retweeted_status']['user']['screen_name'])
	  end
	  count += 1
	end
      rescue
        next
      end
    end
  rescue => e
    puts e
  end
end

#puts( "tweets: #{count}, retweets (RT): #{list_out.count}" ) # old output
# tweets, retweets (RT)
File.open("#{ARGV[2]}", 'a') do |f|
  f.puts("#{count}, #{list_out.count}")
end

