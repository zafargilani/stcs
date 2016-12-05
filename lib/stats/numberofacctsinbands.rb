# usage: ruby numberofacctsinbands.rb /fully/qualified/path/to/directory[.gz] /fully/qualified/path/to/file[.txt]
require 'zlib'
require 'json'
require 'time'

# parse through all .gz json files and output number of unique accts
# per popularity band (group)
# after each file (.gz) the counts will be more robust (see below)

accts_10M = []
accts_1M = []
accts_100K = []
accts_1K = []

pline = ""
out = ""

file_list = Dir.entries(ARGV[0])
file_list.delete(".") # remove . from the list
file_list.delete("..") # remove .. from the list
file_list.sort!

file_list.each do |file|
  begin
    puts "currently processing .. #{file}"
    infile = open("#{ARGV[0]}/#{file}")
    gzi = Zlib::GzipReader.new(infile)
    gzi.each_line do |line|
      begin
        pline = JSON.parse(line)
	# divide sums in popularity bands
	if pline['user']['followers_count'].to_i >= 9000000 # 10M (9M+)
          # check each line against all entries in accts list
          if accts_10M.include? pline['user']['screen_name']
	    # do nothing
	  # add if not found
	  else
	    accts_10M.push( pline['user']['screen_name'] )
          end
	elsif pline['user']['followers_count'].to_i >= 900000 and pline['user']['followers_count'].to_i <= 1100000 # 1M (900K - 1.1M)
	  if accts_1M.include? pline['user']['screen_name']
	    # do nothing
	  else
	    accts_1M.push( pline['user']['screen_name'] )
	  end
	elsif pline['user']['followers_count'].to_i >= 90000 and pline['user']['followers_count'].to_i <= 110000 # 100K (90K - 110K)
	  if accts_100K.include? pline['user']['screen_name']
	    # do nothing
	  else
	    accts_100K.push( pline['user']['screen_name'] )
	  end
	elsif pline['user']['followers_count'].to_i >= 900 and pline['user']['followers_count'].to_i <= 1100 # 1K (0.9K - 1.1K)
	  if accts_1K.include? pline['user']['screen_name']
	    # do nothing
	  else
	    accts_1K.push( pline['user']['screen_name'] )
	  end
	end
      rescue
        next
      end
    end
  rescue => e
    puts e
  end
  # write output before next file, .count or .length
  File.open("#{ARGV[1]}", 'a') do |f|
    f.puts( "10M,#{accts_10M.uniq.count}" )
    f.puts( "1M,#{accts_1M.uniq.count}" )
    f.puts( "100K,#{accts_100K.uniq.count}" )
    f.puts( "1K,#{accts_1K.uniq.count}" )
  end # auto file close
  # do not need to .clear these lists as .uniq makes sure these are always unique,
  # so after each file the counts will be more robust :) no need to average
end

