require 'zlib'
require 'json'
#dates: Sun 2015-10-18 to Sat 2015-10-24

out = "{"
begin
  infile = open('/data/zf-twitter-data/2015-10-18.uk.txt.gz')
  gz = Zlib::GzipReader.new(infile)
  gz.each_line do |line|
    parsed_line = JSON.parse(line)
    #puts "@#{parsed_line["user"]["screen_name"]}"
    #puts parsed_line["user"]["screen_name"]
    response = %x(/usr/bin/python /home/cloud-user/stcs/botornot-python/botornot.py @#{parsed_line["user"]["screen_name"]})
    parsed_response = JSON.parse(response)
    if parsed_response["score"].to_f >= 0.5 #bot = 1, notbot/human = 0
      #out = out + "\"@#{parsed_line['user']['screen_name']\"" + " : 1,"
      puts "bot"
    else
      #out = out + "\"@#{parsed_line['user']['screen_name']\"" + " : 0,"
      puts "notbot"
    end
  end
rescue => e
  puts e
end
out = out + "}"
#puts out
#gz.close

