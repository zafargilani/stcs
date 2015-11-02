require 'rest-client'
require 'mechanize'

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

		#Just add scanners to this lines: "name","url_format"
		@toscanner = [
			["avgthreatlabs","http://www.avgthreatlabs.com/ww-en/website-safety-reports/domain/%s/"], #false negatives, report based?
			["cisco_senderbase", "http://www.senderbase.org/lookup/?search_string=%s"],
			["fortiguard","http://www.fortiguard.com/iprep/index.php?data=%s&lookup=Lookup"],
			["is_it_hacked","http://www.isithacked.com/check/%s"],
			["norton_safeweb","https://safeweb.norton.com/report/show?url=%s"],
			["mcafee_threat_intelligence","http://www.mcafee.com/threat-intelligence/domain/default.aspx?domain=%s"],
			["malware_domain_list","http://www.malwaredomainlist.com/mdl.php?search=%s&colsearch=All&quantity=50"],
			["mxtoolbox","http://mxtoolbox.com/SuperTool.aspx?action=blacklist%3a%s&run=toolpage"],
			["watchguard_reputation _authority","http://www.reputationauthority.org/domain_lookup.php?ip=%s&Submit.x=0&Submit.y=0"],
			["sucuri","https://sitecheck.sucuri.net/results/%s"],
			["url _void","http://www.urlvoid.com/scan/%s/"],
		]
	end

	def scan_site(url)
		@toscanner.each { |toscan|
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
end