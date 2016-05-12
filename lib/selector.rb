require 'zlib'
require 'json'
# This script writes out most popular Twitter accounts from data collected via Streaming API
# Criteria is either large number of followers/friends or large number of favourite tweets

parsed_line = ""
out = ""
begin
  infile = open('/data/zf-twitter-data/2016-4-1.uk.txt.gz')
  gzi = Zlib::GzipReader.new(infile)
  gzi.each_line do |line|
    begin
      parsed_line = JSON.parse(line)
      # output: screen_name, followers_count, friends_count, favourites_count, statuses_count
      # perspective 1: user following and friends
      if parsed_line["user"]["followers_count"].to_i >= 1000000 or parsed_line["user"]["friends_count"] >= 1000000
        out = out + "@#{parsed_line['user']['screen_name']}, #{parsed_line['user']['followers_count']}, #{parsed_line['user']['friends_count']}, "
        out = out + "#{parsed_line["user"]["favourites_count"]}, #{parsed_line["user"]["statuses_count"]}\n"
        open('/data2/zf-twitter-classifier/2016-4-1.fnf', 'a') { |outfile| # followers and friends
          outfile.puts out
        }
      # perspective 2: favourties = 25% or more of tweets
      elsif parsed_line["user"]["followers_count"].to_i >= 1000000 and parsed_line["user"]["favourites_count"].to_i >= (0.25*parsed_line["user"]["statuses_count"].to_f).to_i
        out = out + "@#{parsed_line['user']['screen_name']}, #{parsed_line['user']['followers_count']}, #{parsed_line['user']['friends_count']}, "
        out = out + "#{parsed_line["user"]["favourites_count"]}, #{parsed_line["user"]["statuses_count"]}\n"
        open('/data2/zf-twitter-classifier/2016-4-1.fav', 'a') { |outfile| # favourites = 25% of all tweets
          outfile.puts out
        }
      end
      #puts out
      #open('/data2/zf-twitter-data/2016-4-1.selected', 'a') { |outfile|
      #  outfile.puts out
      #}
      out = "" #reset out
    rescue
      next
    end
  end
rescue => e
  puts e
end
#gzi.close
#gzo.close

