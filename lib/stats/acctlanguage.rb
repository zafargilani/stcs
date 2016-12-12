# usage: ruby entitiesRTentities.rb /fully/qualified/path/to/directory[accts] /fully/qualified/path/to/list
require 'json'
require 'time'

# parse through a directory of accounts and print out their account language

pline = ""
lang = ""

acct_list = Dir.entries(ARGV[0])
acct_list.delete(".") # remove . from the list
acct_list.delete("..") # remove .. from the list
acct_list.sort!

acct_list.each do |acct|
  begin
    infile = open("#{ARGV[0]}/#{acct}")
    infile.each_line do |line|
      begin
        pline = JSON.parse(line)
        if acct_list.include? pline['user']['screen_name']
	  lang = pline['user']['lang']
	elsif acct_list.include? pline['retweeted_status']['user']['screen_name']
	  lang = pline['retweeted_status']['user']['lang']
	elsif acct_list.include? pline['quoted_status']['user']['screen_name']
	  lang = pline['quoted_status']['user']['lang']
	end
      rescue
        next
      end
    end
  rescue => e
    puts e
  end
  File.open("#{ARGV[1]}", 'a') do |f|
    f.puts("#{acct},#{lang}")
  end # auto file close
end

