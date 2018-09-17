import requests

class DeBot(object):
	
	
	def __init__(self, api_key):
		self.api_key = api_key	
		self._api_endpoint = 'http://cs.unm.edu/~chavoshi/debot/api.php'

	def daily_debot(self, limit=5000):
		r = requests.post(self._api_endpoint, data={'api_key':self.api_key, 'srv_type':'1', 'limit':limit})
		return r.text
		
	def check_user(self, screen_name):
		r = requests.post(self._api_endpoint, data={'api_key':self.api_key, 'srv_type':'2', 'user_name':screen_name})
		return r.text
		
	def get_bots_date_range(self, from_date, to_date):
		r = requests.post(self._api_endpoint, data={'api_key':self.api_key, 'srv_type':'3', 'date_1':from_date, 'date_2':to_date})
		return r.text
	
	def get_bots_list(self, _date):
		r = requests.post(self._api_endpoint, data={'api_key':self.api_key, 'srv_type':'3', 'date_1':_date, 'date_2':_date})
		return r.text
		
	def get_frequent_bots(self, freq):
		r = requests.post(self._api_endpoint, data={'api_key':self.api_key, 'srv_type':'4', 'freq':freq})
		return r.text
	
	def get_related_bots(self, topic):
		r = requests.post(self._api_endpoint, data={'api_key':self.api_key, 'srv_type':'5', 'topic':topic})
		return r.text
		
	
			
		
