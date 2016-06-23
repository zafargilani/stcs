#!/usr/bin/python
import botornot
import json
import sys

twitter_app_auth = {
	'consumer_key': 'key',
	'consumer_secret': 'secret',
	'access_token': 'token',
	'access_token_secret': 'token_secret'
	}

bon = botornot.BotOrNot( **twitter_app_auth )
print( json.dumps( bon.check_account( sys.argv[1] ), sort_keys=True, indent=4, separators=( ',', ': ' ) ) )

