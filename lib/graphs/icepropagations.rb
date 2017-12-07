# usage: ruby icepropagations.rb /fully/qualified/path/to/directory[accts] /fully/qualified/path/to/file[.tsv]
require 'zlib'
require 'json'
require 'time'

# build a retweet propagation network as:
# omega   node   T
# where the arc is directed from omega to node
# showing influence propagation from omega to node

# read accounts from a file
# read accts/files from a directory
acct_list = Dir.entries(ARGV[0])
acct_list.delete(".") # remove . from the list
acct_list.delete("..") # remove .. from the list
acct_list.sort!

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
      # each link in each propagation should only appear once!
      list_rtqs.push("omega\t#{target}\t#{utc_time}") unless list_rtqs.index{|s| s.include?("omega\t#{target}")}
    end
    if !list_rtqs.empty?
      list_rtqs.unshift("\tomega\t0") # prepend each propagation!
      File.open("#{ARGV[1]}", 'a') do |f|
        f.puts(list_rtqs.uniq.sort_by {|s| s.split("\t")[2]}) # sort by utc timestamp
      end # auto file close
    end
    list_rtqs.clear
  rescue => e
    puts e
  end
end

