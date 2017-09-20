# usage: ruby text.rb /fully/qualified/path/to/directory[accts] /fully/qualified/path/to/filelist[accts] /fully/qualified/path/to/output/directory
require 'zlib'
require 'json'

# get user tweet text from raw tweets, dump in user file

# read accounts from a file
# read accts/files from a directory
acct_list = Dir.entries(ARGV[0])
acct_list.delete(".") # remove . from the list
acct_list.delete("..") # remove .. from the list
acct_list.sort!

file_list = []
File.open(ARGV[1], 'r') do |f|
  f.each_line do |line|
    file_list.push("#{line.strip!}")
  end
end # auto file close
file_list.uniq!
file_list.sort!
#puts file_list

pline = ""
out = ""

acct_list.each do |acct|
  if file_list.include? acct # only for accts given in the list
    begin
      infile = open("#{ARGV[0]}/#{acct}")
      #gzi = Zlib::GzipReader.new(infile)
      #gzi.each_line do |line|
      infile.each_line do |line|
        begin
          pline = JSON.parse(line)
	  if pline['user']['screen_name'].include? acct # == acct
            out = out + "#{pline['text']}\n"
	  elsif pline['retweeted_status']['user']['screen_name'].include? acct
            out = out + "#{pline['text']}\n"
	  elsif pline['quoted_status']['user']['screen_name'].include? acct
            out = out + "#{pline['text']}\n"
	  end
        rescue
          next
        end
      end
      # if you don't like JSON
      File.open("#{ARGV[2]}/#{acct}", 'w') { |file| file.write(out) }
      # reset vars
      out = ""
    rescue => e
      puts e
    end
  end
end

