'''
Sentiment Analysis using textblob API

(textblob sentiment analyser using Naive Bayes Classification)
http://textblob.readthedocs.io/en/dev/advanced_usage.html#sentiment-analyzers

(execute)
python sentiments.py /input/to/tweets.txt /output/to/
'''

import sys
import codecs

from textblob import TextBlob

#import nltk
#nltk.download('movie_reviews')
#nltk.download('punkt')


lines = ""
with codecs.open(sys.argv[1], encoding='UTF-8') as f:
	lines += f.read()

polarity = 0
subjectivity = 0

try:
	blob = TextBlob(lines)
	polarity = blob.sentiment.polarity
	subjectivity = blob.sentiment.subjectivity
except:
	pass

with open(sys.argv[2]+"/sentiments."+sys.argv[1].split("/")[-1:].pop()+".out", "w") as f:
	f.write("polarity: {}\n".format(polarity))
	f.write("subjectivity: {}\n".format(subjectivity))

