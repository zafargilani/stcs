# usage: ruby icesocialnetwork.rb /fully/qualified/path/to/directory[accts] /fully/qualified/path/to/file[.txt]
require 'zlib'
require 'json'
require 'time'

# read accounts from a file
# read accts/files from a directory
acct_list = Dir.entries(ARGV[0])
acct_list.delete(".") # remove . from the list
acct_list.delete("..") # remove .. from the list
acct_list.sort!

# build a graph network as:
# NodeA  NodeB
# where the arc is directed from A to B
# showing influence propagation from A to B

pline = ""
out = ""

target = ""

list_rtqs = []

# write out social network structure
acct_list.each do |acct|
  begin
    infile = open("#{ARGV[0]}/#{acct}")
    #gzi = Zlib::GzipReader.new(infile)
    #gzi.each_line do |line|
    infile.each_line do |line|
      begin
        pline = JSON.parse(line)
	# if target "influenced" acct
	if (pline.key?('retweeted_status') or pline.key?('quoted_status')) and pline['user']['screen_name'].include? acct
	  if pline.key?('retweeted_status')
            target = pline['retweeted_status']['user']['screen_name']
	  elsif pline.key?('quoted_status')
	    target = pline['quoted_status']['user']['screen_name']
	  end
	  list_rtqs.push("#{target}\t#{acct}")
	# if acct "influenced" target
        elsif pline.key?('retweeted_status') and pline['retweeted_status']['user']['screen_name'].include? acct
	  target = pline['user']['screen_name']
	  list_rtqs.push("#{acct}\t#{target}")
	# if acct "influenced" target
	elsif pline.key?('quoted_status') and pline['quoted_status']['user']['screen_name'].include? acct
	  target = pline['user']['screen_name']
	  list_rtqs.push("#{acct}\t#{target}")
	end
      rescue
        next
      end
    end
    File.open("#{ARGV[1]}", 'a') do |f|
      f.puts(list_rtqs)
    end # auto file close
    list_rtqs.clear
  rescue => e
    puts e
  end
end

# write out omega structure
list_rtqs.clear
acct_list.each do |acct|
  list_rtqs.push("omega\t#{acct}")
end
File.open("#{ARGV[1]}", 'a') do |f|
  f.puts(list_rtqs)
end
list_rtqs.clear

