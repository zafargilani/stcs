# usage: ruby selector.rb /full/path/input/data.txt.gz LOWER_LIMIT UPPER_LIMIT /full/path/output/accts.txt
require 'zlib'
require 'json'

# this script writes out most popular Twitter accounts from data collected via Streaming API
# criteria is either large number of followers/friends or large number of favourite tweets

LOWER_LIMIT = ARGV[1].to_i
UPPER_LIMIT = ARGV[2].to_i

parsed_line = ""
out = ""
begin
  infile = open(ARGV[0])
  gzi = Zlib::GzipReader.new(infile)
  gzi.each_line do |line|
    begin
      parsed_line = JSON.parse(line)
      if parsed_line['user']['followers_count'].to_i >= LOWER_LIMIT and parsed_line['user']['followers_count'] <= UPPER_LIMIT
        out = out + "@#{parsed_line['user']['screen_name']}, #{parsed_line['user']['followers_count']}, #{parsed_line['user']['friends_count']}, "
        out = out + "#{parsed_line['user']['favourites_count']}, #{parsed_line['user']['statuses_count']}\n"
	#puts out
	File.open("#{ARGV[3]}", 'a') do |f|
	  f.puts(out)
	end # auto file close
      end
      ## output: screen_name, followers_count, friends_count, favourites_count, statuses_count
      ## perspective 1: user following and friends
      #if parsed_line["user"]["followers_count"].to_i >= 50000000 or parsed_line["user"]["friends_count"] >= 50000000
      #  out = out + "@#{parsed_line['user']['screen_name']}, #{parsed_line['user']['followers_count']}, #{parsed_line['user']['friends_count']}, "
      #  out = out + "#{parsed_line["user"]["favourites_count"]}, #{parsed_line["user"]["statuses_count"]}\n"
      #  open('/local/scratch/szuhg2/classifier_data/2016-4-1.fnf', 'a') { |outfile| # followers and friends
      #    outfile.puts out
      #  }
      ## perspective 2: favourties = 25% or more of tweets
      #elsif parsed_line["user"]["followers_count"].to_i >= 50000000 and parsed_line["user"]["favourites_count"].to_i >= (0.25*parsed_line["user"]["statuses_count"].to_f).to_i
      #  out = out + "@#{parsed_line['user']['screen_name']}, #{parsed_line['user']['followers_count']}, #{parsed_line['user']['friends_count']}, "
      #  out = out + "#{parsed_line["user"]["favourites_count"]}, #{parsed_line["user"]["statuses_count"]}\n"
      #  open('/local/scratch/szuhg2/classifier_data/2016-4-1.fav', 'a') { |outfile| # favourites = 25% of all tweets
      #    outfile.puts out
      #  }
      #end
      ##puts out
      ##open('/data2/zf-twitter-data/2016-4-1.selected', 'a') { |outfile|
      ##  outfile.puts out
      ##}
      out = "" # reset out
    rescue
      next
    end
  end
rescue => e
  puts e
end
#gzi.close
#gzo.close

