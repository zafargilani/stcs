# usage: ruby popularitydistribution.rb /fully/qualified/path/to/directory[gz files] /fully/qualified/path/to/file[.txt]
require 'zlib'
require 'json'
# This script writes out most popular Twitter accounts from data collected via Streaming API
# Criteria is either large number of followers/friends or large number of favourite tweets

# read files from a directory
file_list = Dir.entries(ARGV[0])
file_list.delete(".") # remove . from the list
file_list.delete("..") # remove .. from the list
file_list.sort!

c_1K, c_10K, c_25K, c_50K, c_100K, c_250K, c_500K, c_1M, c_5M, c_10M = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
out = ""

parsed_line = ""
out = ""

file_list.each do |file|
  begin
    infile = open("#{ARGV[0]}/#{file}")
    gzi = Zlib::GzipReader.new(infile)
    gzi.each_line do |line|
      begin
        parsed_line = JSON.parse(line)
        # 1K = 0 to 1000
        if parsed_line["user"]["followers_count"].to_i >= 0 and parsed_line["user"]["followers_count"] <= 1000
          c_1K += 1
        # 10K = 1001 to 10000
        elsif parsed_line["user"]["followers_count"].to_i >= 1001 and parsed_line["user"]["followers_count"] <= 10000
          c_10K += 1
        # 25K = 10001 to 25000
        elsif parsed_line["user"]["followers_count"].to_i >= 10001 and parsed_line["user"]["followers_count"] <= 25000
          c_25K += 1
        # 50K = 25001 to 50000
        elsif parsed_line["user"]["followers_count"].to_i >= 25001 and parsed_line["user"]["followers_count"] <= 50000
          c_50K += 1
        # 100K = 50001 to 100000
        elsif parsed_line["user"]["followers_count"].to_i >= 50001 and parsed_line["user"]["followers_count"] <= 100000
          c_100K += 1
        # 250K = 100001 to 250000
        elsif parsed_line["user"]["followers_count"].to_i >= 100001 and parsed_line["user"]["followers_count"] <= 250000
          c_250K += 1
        # 500K = 250001 to 500000
        elsif parsed_line["user"]["followers_count"].to_i >= 250001 and parsed_line["user"]["followers_count"] <= 500000
          c_500K += 1
        # 1M = 500001 to 1000000
        elsif parsed_line["user"]["followers_count"].to_i >= 500001 and parsed_line["user"]["followers_count"] <= 1000000
          c_1M += 1
        # 5M = 1000001 to 5000000
        elsif parsed_line["user"]["followers_count"].to_i >= 1000001 and parsed_line["user"]["followers_count"] <= 5000000
          c_5M += 1
        # 10M = 5000001 to max
        elsif parsed_line["user"]["followers_count"].to_i >= 5000001
          c_10M += 1
        end
      rescue
        next
      end
    end
  rescue => e
    puts e
  end
end
File.open("#{ARGV[1]}", 'a') do |f|
  out = "1K,#{c_1K}\n"
  out = out + "10K,#{c_10K}\n"
  out = out + "25K,#{c_25K}\n"
  out = out + "50K,#{c_50K}\n"
  out = out + "100K,#{c_100K}\n"
  out = out + "250K,#{c_250K}\n"
  out = out + "500K,#{c_500K}\n"
  out = out + "1M,#{c_1M}\n"
  out = out + "5M,#{c_5M}\n"
  out = out + "10M,#{c_10M}\n"
  f.puts(out)
end # auto file close
#gzi.close
#gzo.close

