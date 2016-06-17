# usage: ruby gzsources.rb /full/path/to/file.txt /full/path/to/file.gz > source.txt
require 'zlib'
require 'json'
require 'time'

# get user source from raw tweets/json
# dump this in an output file from time to time

acct_list = []

f = open(ARGV[0])
f.each_line do |line|
  acct_list.push("#{line.strip!}")
end

pline = ""
out = ""
source_list = {}
sources = []

begin
  infile = open(ARGV[1])
  gzi = Zlib::GzipReader.new(infile)
  gzi.each_line do |line|
    begin
      pline = JSON.parse(line)
      # check each line against the complete list, instead of traversing over the whole .gz repeatedly
      if acct_list.include? "#{pline['user']['screen_name']}"
	# if the source already in the source_list
        if source_list.has_key? "#{pline['user']['screen_name']}"
          sources = source_list["#{pline['user']['screen_name']}"]
          sources.push("#{pline['source']}")
          sources = sources.uniq
          source_list["#{pline['user']['screen_name']}"] = sources
        # if not
	else
          source_list["#{pline['user']['screen_name']}"] = "#{pline['source']}"
        end
      end
      sources.clear # cleanup for next line
    rescue
      next
    end
  end
  puts source_list
  source_list.clear # cleanup, though unnecessary
rescue => e
  puts e
end

