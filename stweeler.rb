require 'rubygems'
require 'bundler/setup'

require 'thor'
require 'yaml'
require 'uri'
require_relative 'lib/collector'
require_relative 'lib/urlscanner'
require_relative 'lib/bot'

class MyCLI < Thor

	desc "collect", "Collect and store tweets using Twitter Sample"
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
		scanner.check_malware(url)
	end

	desc "get_urls_from_twitter content","Gets urls from text"
	def get_urls_from_twitter(content)
		Scanner.get_urls_from_twitter(content)
	end

	desc "get_tree_from_page content","Builds a tree of referenced URLs from the specified URL"
	option :depth, :type => :numeric, :default => 3
	def get_tree_from_page(url)
		Scanner.get_urls_from_page(URI(url), max_depth:options[:depth])
	end

	desc "launch_bot", "Launches a bot OMG OMG OMG"
	def launch_bot
		conf = YAML.load_file('config.yml')

		collector = Collector.new(
			conf['consumer_key'], 
			conf['consumer_secret'], 
			conf['oauth_token'], 
			conf['oauth_token_secret'])

		bob = BobTheBot.new(
			conf['consumer_key'], 
			conf['consumer_secret'], 
			conf['oauth_token'], 
			conf['oauth_token_secret'], 
			collector:collector,
			follow_number:conf['follow_number'],
			follow_frequency:conf['follow_frequency'],
			unfollow_frequency:conf['unfollow_frequency'],
			follower_ratio:conf['follower_ratio']
			)

		bob.prepare
		bob.start

		tries = 5
		rescue EOFError =>
		  if (tries -= 1) > 0
		    sleep 60
		    retry
		  else
		    raise e
		  end
		end
	end

	desc "botornot @username", "Checks whether a Twitter acct is a bot or not"
 	def botornot
		argv = ARGV[1].dup
		response = %x(/usr/bin/python botornot-python/botornot.py #{argv.chomp})
		puts response
	end

end

MyCLI.start(ARGV)
