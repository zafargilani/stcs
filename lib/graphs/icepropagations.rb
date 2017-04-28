# usage: ruby icepropagations.rb /fully/qualified/path/to/directory[accts] /fully/qualified/path/to/file[.txt]
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
target = ""
utc_time = 0
list_rtqs = []

# write out entire propagations, acct by acct
acct_list.each do |acct|
  begin
    infile = open("#{ARGV[0]}/#{acct}")
    #gzi = Zlib::GzipReader.new(infile)
    #gzi.each_line do |line|
    infile.each_line do |line|
      begin
        pline = JSON.parse(line)
	# tweet: if this acct is tweeting, then target might have retweeted or quoted
	# therefore: acct "influenced" target
	if pline.key?('retweeted_status') and pline['retweeted_status']['user']['screen_name'].include? acct
	  target = pline['user']['screen_name']
	  utc_time = Time.parse( pline['created_at'] ).to_i
	elsif pline.key?('quoted_status') and pline['quoted_status']['user']['screen_name'].include? acct
	  target = pline['user']['screen_name']
	  utc_time = Time.parse( pline['created_at'] ).to_i
	end
      rescue
        next
      end
      list_rtqs.push("omega\t#{target}\t#{utc_time}")
    end
    if !list_rtqs.empty?
      list_rtqs.unshift("\tomega\t0") # prepend each propagation!
      File.open("#{ARGV[1]}", 'a') do |f|
        f.puts(list_rtqs.uniq) # each link appears only once!
      end # auto file close
    end
    list_rtqs.clear
  rescue => e
    puts e
  end
end

