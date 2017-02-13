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
    if parsed_response["score"].to_f >= 0.50 # observation shows >45% of OSN traffic comes from bots
      out = "\"#{acct}\",\"bot\""
    elsif parsed_response["score"].to_f < 0.50
      out = "\"#{acct}\",\"human\""
    elsif parsed_response.include? "Sorry, that page does not exist"
      out = "\"#{acct}\",\"NA\""
    else
      out = "\"#{acct}\",\"NA\""
    end
  rescue => e
    puts e
  end
  File.open("#{ARGV[1]}", 'a') do |f|
    f.puts(out)
  end # auto file close
end

# post-processing:
# remove empty lines via vim :%g/^$/d
# sort -k1 for both files
# (header needs updating) awk -F"," 'FNR==NR{a[$1]=$2;next}{ print $1","$2","$3","$4","$5","$6","$7","$8","$9","$10","a[$1]}' botornot.100k Final100k_standardised.csv > Final100k_standardised.csv.appended
# vim :%s/[press CTRL+V and CTRL+M]//g to remove ^M for Final100k_standardised.csv.appended
# mv and add header ["username","review1","comment1","review2","comment2","review3","comment3","review4","comment4","finalreview","botornot"] to Final100k_standardised.csv

