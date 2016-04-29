require 'zlib'
require 'json'
#dates: Sun 2015-10-18 to Sat 2015-10-24

parsed_line = ""
response = ""
parsed_response = ""
out = ""
begin
  infile = open('/data/zf-twitter-data/2016-4-1.uk.txt.gz')
  gzi = Zlib::GzipReader.new(infile)
  gzi.each_line do |line|
    begin
      parsed_line = JSON.parse(line)
      if parsed_line["user"]["followers_count"].to_i >= 1000000 or parsed_line["user"]["friends_count"] >= 1000000
        response = %x(/usr/bin/python /home/cloud-user/stcs/botornot-python/botornot.py @#{parsed_line["user"]["screen_name"]})
        parsed_response = JSON.parse(response)
        if parsed_response["score"].to_f >= 0.5 #bot = 1, notbot/human = 0
          #output: tweet_id, user, botornot, followers, friends, retweets
          out = out + "#{parsed_line['id']}, @#{parsed_line['user']['screen_name']}, bot, #{parsed_line['user']['followers_count']}, "
          out = out + "#{parsed_line['user']['friends_count']}, #{parsed_line['retweet_count']}\n"
        else
          out = out + "#{parsed_line['id']}, @#{parsed_line['user']['screen_name']}, human, #{parsed_line['user']['followers_count']}, "
          out = out + "#{parsed_line['user']['friends_count']}, #{parsed_line['retweet_count']}\n"
        end
        #puts out
        open('/data2/zf-twitter-data/2016-4-1.uk.botornot.txt', 'a') { |outfile|
          outfile.puts out
        }
        out = "" #reset out
      end
    rescue
      next
    end
  end
rescue => e
  puts e
end
#gzi.close
#gzo.close

