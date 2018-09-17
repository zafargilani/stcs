# usage: ruby bon.rb @BarackObama

#response = %x(python ../botornot-python/botornot.py @clayadavis)
response = %x(python ../botornot-python/botornot.py #{ARGV[0]})
puts response
