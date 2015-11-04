require 'thor'
require 'yaml'
require 'uri'
require_relative 'lib/collector'
require_relative 'lib/urlscanner'

class MyCLI < Thor

	desc "collect","Collect and store tweets using Twitter Sample"
	def collect()
		conf = YAML.load_file('config.yml')

		collector = Collector.new(
			conf['consumer_key'], 
			conf['consumer_secret'], 
			conf['oauth_token'], 
			conf['oauth_token_secret'])

		collector.collect(conf["storage_folder"])
	end

	desc "check_malware url", "Scan an URL for malware"
	option :folder, :type => :string, :default => '.'
	def check_malware(url)
		scanner = Scanner.new(options[:folder])
		scanner.scan_site(url)
	end

	desc "get_urls_from_twitter content","Gets urls from text"
	def get_urls_from_twitter(content)
		Scanner.get_urls_from_twitter(content)
	end

	desc "get_urls_from_page content","Builds a tree of referenced URLs from the specified URL"
	def get_urls_from_page(url)
		Scanner.get_urls_from_page(URI(url))
	end
end

MyCLI.start(ARGV)