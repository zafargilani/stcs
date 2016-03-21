#!/usr/bin/python
import botornot
import json
import configparser

config = configparser.ConfigParser()
config.sections()

config.read('../config.ini')

twitter_app_auth = {
        'consumer_key': config['DEFAULT']['bon_consumer_key'],
        'consumer_secret': config['DEFAULT']['bon_consumer_secret'],
        'access_token': config['DEFAULT']['bon_oauth_token'],
        'access_token_secret': config['DEFAULT']['bon_oauth_secret']
        }

#print(twitter_app_auth['consumer_key'])

bon = botornot.BotOrNot(**twitter_app_auth)
print(json.dumps(bon.check_account('@clayadavis'), sort_keys=True, indent=4, separators=(',', ': ')))

