require 'rest-client'
require 'mechanize'
require 'uri'
require 'tree'

class LinkScanResult
	def initialize(urlformat, link)
		@format = urlformat
		@link = link
		puts @format % [@link] 
	end

	def get
		@content = RestClient.get @format % [@link] 
	end

	def content
		@content
	end

	def to_s
	 	"---------------------\n -->Url :\n #{@format % [@link] }\n -->Link :\n #{link}\n -->Content :\n #{content}---------------------\n"
	end
end

class Scanner
	#Catchas:
	#brightcloud.com -> has captchas
	#malwareurl.com


	#http://quttera.com/ -> complex but no captchas
	#http://reclassify.wrs.trendmicro.com/
	#http://www.unmaskparasites.com/security-report/
	#http://urlquery.net/
	#https://www.virustotal.com
	#http://zulu.zscaler.com/
	#http://wepawet.iseclab.org
	#http://vurl.mysteryfcm.co.uk/

	#https://developers.google.com/safe-browsing/ <--- needs key

	
	
	def initialize(folder)
		@results_folder = folder

		#Just add scanners to this lines: "name","url_format",on_state
		@toscanner = [
			["avgthreatlabs","http://www.avgthreatlabs.com/ww-en/website-safety-reports/domain/%s/",true], #false negatives, report based?
			["cisco_senderbase", "http://www.senderbase.org/lookup/?search_string=%s",true],
			["fortiguard","http://www.fortiguard.com/iprep/index.php?data=%s&lookup=Lookup",true],
			["is_it_hacked","http://www.isithacked.com/check/%s",true],
			["norton_safeweb","https://safeweb.norton.com/report/show?url=%s",true],
			["mcafee_threat_intelligence","http://www.mcafee.com/threat-intelligence/domain/default.aspx?domain=%s",true],
			["malware_domain_list","http://www.malwaredomainlist.com/mdl.php?search=%s&colsearch=All&quantity=50",false],
			["mxtoolbox","http://mxtoolbox.com/SuperTool.aspx?action=blacklist:%s&run=toolpage",true],
			["watchguard_reputation _authority","http://www.reputationauthority.org/domain_lookup.php?ip=%s&Submit.x=0&Submit.y=0",true],
			["sucuri","https://sitecheck.sucuri.net/results/%s",true],
			["url _void","http://www.urlvoid.com/scan/%s/",true],
		]
	end

	def check_malware(url)
		@toscanner.each { |toscan|
			next unless toscan[2]
			file = File.new("#{@results_folder}/#{url}-#{toscan[0]}.html", "w")
			begin
				
				result = LinkScanResult.new(toscan[1],url)
				result.get
				#puts result.inspect
				file.write(result.content)

				doc = Nokogiri::HTML(result.content)

				#Process doc here
			rescue => e
				puts "Failed : #{toscan[0]}"
				puts e
			end
		}
	end

	def self.get_urls_from_twitter(content)
		urls = []
		# You should not rely on the number of parentheses
		content.scan(URI.regexp(['http','https'])) do |*matches|
			urls << $&
			#p $&
		end
		urls
	end

	def self.get_urls_from_page(url, current_url:nil, tree:nil, depth:0, levels:nil, max_depth:2, mechanize:nil)

		if(depth >= max_depth)
			#tree.print_tree
			p "Reached depth!!"
			return
		end

		if levels == nil
			levels = []
			for i in 0..max_depth-1
				levels[i] = 0
			end
		end

		mechanize = Mechanize.new if mechanize == nil
		current_url = url if current_url == nil

		current_url = URI("#{url.to_s}#{current_url.to_s}") if current_url.scheme == nil
		p "---->#{current_url}"

		link_node = Tree::TreeNode.new(current_url, current_url)
		

		if tree == nil
			tree= link_node
		else
			begin
				tree << link_node

			rescue RuntimeError
				p "Already had :  #{current_url}?"
				#p e
				return
			end
		end

		levels[depth] += 1
		p "#{levels} - #{current_url}"

		begin
			mechanize.get(current_url) do |page|
				page.links.each do |link|
					get_urls_from_page(url,current_url:link.uri,tree:link_node,depth:depth+1,levels:levels) unless depth +1 >= max_depth					
				end
			end
		rescue Mechanize::ResponseCodeError
			p "ERROR: ResponseCodeError"
		rescue NoMethodError
			p "ERROR: Page was not html?"
		rescue Mechanize::*
		end

		if depth == 0
			previous_stdout = $stdout.dup
			#This stdout redirection is dangerous :)
			$stdout.reopen("tree.txt", "w")
			$stdout.sync = true
			tree.print_tree
			$stdout.reopen previous_stdout
			p "done!"
		end
	end
end

