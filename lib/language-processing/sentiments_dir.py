'''
Sentiment Analysis of files in a dir using textblob API,
output is stored as a CSV, each file/doc per line:
file/doc, polarity, subjectivity

(textblob sentiment analyser using Naive Bayes Classification)
http://textblob.readthedocs.io/en/dev/advanced_usage.html#sentiment-analyzers

(execute)
python sentiments_dir.py /input/to/ /output/to/ topic
'''

import sys
import codecs
from os import listdir
from os.path import isfile, join

from textblob import TextBlob

#import nltk
#nltk.download('movie_reviews')
#nltk.download('punkt')

files = [f for f in listdir(sys.argv[1]) if isfile(join(sys.argv[1], f))]
#print(files)

for fl in files:
	lines = ""
	with codecs.open(sys.argv[1]+fl, encoding='UTF-8') as f:
		lines += f.read()

	polarity = 0
	subjectivity = 0

	if len(sys.argv) == 4: # sys.argv[0] is script name
		topic_lines = ""
		lines_array = lines.split('\n') # remember lines isn't an array
		for line in lines_array:
			if sys.argv[3].lower() in line.lower():
				topic_lines += line
		lines = topic_lines

	try:
		blob = TextBlob(lines)
		polarity = blob.sentiment.polarity
		subjectivity = blob.sentiment.subjectivity
	except:
		pass

	with open(sys.argv[2]+"sentiments."+sys.argv[1].split("/")[-2]+".csv", "a") as f:
		f.write("{}, {}, {}\n".format(fl, polarity, subjectivity))

