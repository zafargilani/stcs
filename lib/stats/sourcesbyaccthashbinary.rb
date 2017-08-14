# usage: ruby sourcesbyaccthashbinary.rb /fully/qualified/path/to/sources[.csv] /fully/qualified/path/to/directory[accts] /fully/qualified/path/to/file[.txt]
require 'csv'
require 'zlib'
require 'json'

# hash: source generalisation for ML classification task (Random Forest classifier)
# read known_sources hash from a csv file (rfclassifier/sources.csv)
known_sources = {}
CSV.foreach(ARGV[0], :headers => true) do |row|
  known_sources[row.fields[0]] = row.fields[1].to_i
end

# read accounts from a file
# read accts/files from a directory
acct_list = Dir.entries(ARGV[1])
acct_list.delete(".") # remove . from the list
acct_list.delete("..") # remove .. from the list
acct_list.sort!

# get user sources from raw tweets/json
# dump this in an output file from time to time

pline = ""
out = ""
source_sl = ""
source_code = ""
source_list = []
max_depth = 0

acct_list.each do |acct|
  begin
    infile = open("#{ARGV[1]}/#{acct}")
    #gzi = Zlib::GzipReader.new(infile)
    #gzi.each_line do |line|
    infile.each_line do |line|
      begin
        pline = JSON.parse(line)

	if pline['user']['screen_name'].include? acct # == acct
	  source = pline['source']
	  source_sl = source.slice(source.index('>')+1, source.length)
	  source_sl = source_sl.slice(0, source_sl.index('<'))

	  if source_list.include? known_sources[source_sl] # match found
	    # do nothing
	  else
            source_list.push(known_sources[source_sl].to_i)
	  end
	elsif pline['retweeted_status']['user']['screen_name'].include? acct
	  source = pline['retweeted_status']['source']
	  source_sl = source.slice(source.index('>')+1, source.length)
	  source_sl = source_sl.slice(0, source_sl.index('<'))
	  
	  if source_list.include? known_sources[source_sl] # match found
	    # do nothing
	  else
            source_list.push(known_sources[source_sl].to_i)
	  end
	elsif pline['quoted_status']['user']['screen_name'].include? acct
	  source = pline['quoted_status']['source']
	  source_sl = source.slice(source.index('>')+1, source.length)
	  source_sl = source_sl.slice(0, source_sl.index('<'))
	  
	  if source_list.include? known_sources[source_sl] # match found
	    # do nothing
	  else
            source_list.push(known_sources[source_sl].to_i)
	  end
	end
      rescue
        next
      end
    end
    
    # make it binary representative
    source_list_u_s = source_list.uniq.sort
    source_list.clear
    for i in 0..6
      if source_list_u_s.include?(i)
        source_list.push(1)
      else
	source_list.push(0)
      end
    end

    # if you don't like JSON
    out = "#{acct},#{source_list}" # do not .uniq .. binary!!
    File.open("#{ARGV[2]}", 'a') do |f|
      f.puts(out)
    end # auto file close
    #out_json = {
    #  "screen_name" => "#{acct}",
    #  "tree" => "#{source_list}"
    #}
    #puts out_json
    # reset vars
    source_list_u_s.clear
    source_list.clear
  rescue => e
    puts e
  end
end

# post-process (to create concantenated file for classification):
# vim :%s/, /;/g to replace list , with ;
# awk -F"," 'FNR==NR{a[$1]=$2;next}{ print $1","$2","$3","$4","$5","$6","$7","$8","$9","$10","$11","$12","$13","$14","$15","a[$1]}' sourcesbyaccthash.2016-4.bots.1k bots.1k.csv > bots.1k.csv.new
# add 'source_identity' to header
# mv bots.1k.csv.new bots.1k.csv

