# usage: ruby botornot.rb /full/path/input/list.txt > /full/path/output/file.txt
require 'zlib'
require 'json'

acct_list = []

f = open(ARGV[0])
f.each_line do |line|
  acct_list.push("#{line.strip!}")
end

acct_list.each do |acct|
  begin
    response = %x(/usr/bin/python /local/scratch/szuhg2/stcs/botornot-python/botornot.py #{acct})
    parsed_response = JSON.parse(response)
    if parsed_response["score"].to_f >= 0.45 #bot = 1, notbot/human = 0
      puts "#{acct}, bot"
    else
      puts "#{acct}, human"
    end
  rescue
    next
  end
end

