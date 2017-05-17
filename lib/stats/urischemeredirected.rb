# usage: ruby urischemeredirected.rb /fully/qualified/path/to/directory[accts] /fully/qualified/path/to/file[.csv]
require 'zlib'
require 'json'
require 'uri'

# read accounts from a file
# read accts/files from a directory
acct_list = Dir.entries(ARGV[0])
acct_list.delete(".") # remove . from the list
acct_list.delete("..") # remove .. from the list
acct_list.sort!

# measure different redirected URL schemes 

pline = ""
text = ""
textp1 = ""
textp2 = ""
ctext = ""
uri = ""
out = ""

http = 0
https = 0

acct_list.each do |acct|
  begin
    infile = open("#{ARGV[0]}/#{acct}")
    #gzi = Zlib::GzipReader.new(infile)
    #gzi.each_line do |line|
    infile.each_line do |line|
      begin
        pline = JSON.parse(line)
	text = pline['text']
	if pline['text'].include? "http" or pline['text'].match(/[a-z]*:\/\//) # captures all URLs
	  textp1 = text[text.index("http"), text.length] # captures http or https
	  if textp1.include? ")"
	    textp2 = textp1[textp1.index("http"), textp1.index(")")]
	  else
	    textp2 = textp1[textp1.index("http"), textp1.index(" ")]
	  end
	end
	ctext = `curl -sI #{textp2} 2> /dev/null | grep location | awk -F": " '{print $2}'`
	uri = URI.parse(ctext)
	if uri.scheme.downcase == "http"
	  http += 1
	elsif uri.scheme.downcase == "https"
	  https += 1
	end
      rescue
        next
      end
    end
    out = "#{acct}, #{http}, #{https}"
    File.open("#{ARGV[1]}", 'a') do |f|
      f.puts(out)
    end # auto file close
    # reser vars
    out = ""
    text = ""
    textp1 = ""
    textp2 = ""
    ctext = ""
    uri = ""
    http = 0
    https = 0
  rescue => e
    puts e
  end
end

