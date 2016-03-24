#!/usr/bin/python
import botornot
import json
import configparser
import sys

try:
	config = configparser.ConfigParser()
	config.sections()

	config.read('/home/cloud-user/stcs/config.ini')

	twitter_app_auth = {
        	'consumer_key': config['DEFAULT']['bon_consumer_key'],
        	'consumer_secret': config['DEFAULT']['bon_consumer_secret'],
        	'access_token': config['DEFAULT']['bon_oauth_token'],
        	'access_token_secret': config['DEFAULT']['bon_oauth_secret']
        	}

	#print(twitter_app_auth['consumer_key'])

	bon = botornot.BotOrNot(**twitter_app_auth)

	#json_response = json.dumps(bon.check_account('@clayadavis'), sort_keys=True, indent=4, separators=(',', ': '))
	print(json.dumps(bon.check_account(sys.argv[1]), sort_keys=True, indent=4, separators=(',', ': ')))
	#print(json.dumps(bon.check_account('@clayadavis'), sort_keys=True, indent=4, separators=(',', ': ')))
except:
	pass

