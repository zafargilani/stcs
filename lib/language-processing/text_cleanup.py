"""
Text cleanup and translation to English using langdetect and textblob

(langdetect)
https://pypi.python.org/pypi/langdetect

(textblob)
https://textblob.readthedocs.io/en/dev/quickstart.html

(language iso codes)
https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes

(most popular languages on Twitter)
https://thenextweb.com/shareables/2013/12/10/61-languages-found-twitter-heres-rank-popularity/

(dependencies)
langdetect textblob numpy sklearn

(execute)
python text_cleanup.py /input/ /cleaned/
"""

import sys
from os import listdir
from os.path import isfile, join
import codecs

from langdetect import detect
from textblob import TextBlob


###############################################

'''
Remove empty lines and return English phrases only
'''
def clean_up(file_name, lines):
	while '' in lines:
		lines.remove('')

	new_lines = []
	for l in lines:
		try:
			if detect(l) == 'en': # English 34%
				new_lines.append(l)
			elif (detect(l) == 'ja' # Japanese 16%
				or detect(l) == 'es' # Spanish 12%
			  	or detect(l) == 'pt' # Portuguese 6%
				or detect(l) == 'ar' # Arabic 6%
				or detect(l) == 'fr' # French 2%
				or detect(l) == 'tr'): # Turkish 2%
				blob = TextBlob(l)
				en_blob = blob.translate(to='en')
				new_lines.append(str(en_blob))
		except:
			pass

	# write to a file as clean and translated text
	with open(sys.argv[2]+"/"+file_name+".out", "w") as f:
		for l in new_lines:
			try:
				f.write("{}\n".format(l.encode('utf-8')))
			except:
				pass

###############################################

'''
Get list of files in a directory path
'''
def get_files(path):
	file_names = [f for f in listdir(path) if isfile(join(path, f))]

	return file_names

###############################################

if __name__ == "__main__":
	try:
		# input files
		file_names = get_files(sys.argv[1])

		# process text per file
		for file_name in file_names:
			file_lines = []
			with codecs.open(sys.argv[1]+"/"+file_name, encoding='UTF-8') as f:
				file_lines = f.read().splitlines()
		
			clean_up(file_name, file_lines)
	except:
		raise

