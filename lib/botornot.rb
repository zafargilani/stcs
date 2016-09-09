# usage: ruby botornot.rb /full/path/input/list.txt /full/path/output/file.txt
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
    if parsed_response["score"].to_f >= 0.45 # observation shows >45% of OSN traffic comes from bots
      out = "#{acct}, bot"
    elsif parsed_response["score"].to_f < 0.45
      out = "#{acct}, human"
    elsif parsed_response.include? "Sorry, that page does not exist"
      out = "#{acct}, NA"
    else
      out = "#{acct}, NA"
    end
  rescue => e
    puts e
  end
  File.open("#{ARGV[1]}", 'a') do |f|
    f.puts(out)
  end # auto file close
end

