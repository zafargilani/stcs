# usage: ruby urihostsredirected.rb /fully/qualified/path/to/directory[accts] /fully/qualified/path/to/file[.csv]
require 'zlib'
require 'json'
require 'uri'
require 'csv'

# read accounts from a file
# read accts/files from a directory
acct_list = Dir.entries(ARGV[0])
acct_list.delete(".") # remove . from the list
acct_list.delete("..") # remove .. from the list
acct_list.sort!

# measure different redirected URL types

pline = ""
text = ""
textp1 = ""
textp2 = ""
ctext = ""
uri = ""

urihosts = Hash.new

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
	if urihosts.key? "#{uri.host.downcase}"
	  urihosts["#{uri.host.downcase}"] = urihosts["#{uri.host.downcase}"] + 1
	else
	  urihosts["#{uri.host.downcase}"] = 1
	end
      rescue
        next
      end
    end
    # reset vars
    text = ""
    textp1 = ""
    textp2 = ""
    ctext = ""
    uri = ""
  rescue => e
    puts e
  end
end

# write output, auto file close
CSV.open("#{ARGV[1]}", 'a') { |csv| urihosts.to_a.each {|elem| csv << elem} }

