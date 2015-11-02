require 'thor'
require 'yaml'
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

	desc "scan url", "Scan an URL for malware"
	def scan(url)
		scanner = Scanner.new(".")
		scanner.scan_site(url)
	end
end

MyCLI.start(ARGV)