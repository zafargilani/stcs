# usage: ruby numberofaccts.rb /fully/qualified/path/to/directory[.gz] /fully/qualified/path/to/file[.txt]
require 'zlib'
require 'json'
require 'time'

# parse through all .gz json files and output number of unique accts

accts = []

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
        accts.push( pline['user']['screen_name'] )
	## check each line against all entries in accts list
        #if accts.include? pline['user']['screen_name']
	#  # do nothing
	## add if not found
	#else
	#  accts.push( pline['user']['screen_name'] )
        #end
      rescue
        next
      end
    end
  rescue => e
    puts e
  end
  # write output before next file, .count or .length
  File.open("#{ARGV[1]}", 'a') do |f|
    f.puts( "#{file},#{accts.uniq.count}" )
  end # auto file close
  accts.clear
end

