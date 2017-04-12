#!/usr/bin/python
import botornot
import json
import sys

twitter_app_auth = {
	#'consumer_key': 'key',
	'consumer_key': 'wAPYPlEpG8RTe4PpyJ0sGau4B',
	#'consumer_secret': 'secret',
	'consumer_secret': 'DfLpnQrRUG2TEZmB3ovvipn7LV9mQQfqvFjDQo6H5iyx1sVqkE',
	#'access_token': 'token',
	'access_token': '774246744133603328-SRXBwOfBlEILqw9pU3UDicNJHqI9Agz',
	#'access_token_secret': 'token_secret'
	'access_token_secret': 'Sy85WcL3hED8O9ocSKbRsy25HdhQMaBeyEJiD1dRG7zsg'
	}

bon = botornot.BotOrNot( **twitter_app_auth )
print( json.dumps( bon.check_account( sys.argv[1] ), sort_keys=True, indent=4, separators=( ',', ': ' ) ) )

