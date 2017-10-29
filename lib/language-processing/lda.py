"""
Latent Dirichlet Allocation model (online variation Bayes method or batch)
for extracting topic structure of the supplied corpus of tweet documents
using python scikit-learn (sklearn) LatentDirichletAllocation class.

(lda)
refr: https://en.wikipedia.org/wiki/Latent_Dirichlet_allocation
libr: http://scikit-learn.org/stable/modules/generated/sklearn.decomposition.LatentDirichletAllocation.html
code: http://scikit-learn.org/stable/auto_examples/applications/plot_topics_extraction_with_nmf_lda.html

(count vectoriser, stop-words)
libr: http://scikit-learn.org/stable/modules/generated/sklearn.feature_extraction.text.CountVectorizer.html
code: https://github.com/scikit-learn/scikit-learn/blob/master/sklearn/feature_extraction/stop_words.py

(dependencies)
textblob numpy sklearn

(execute)
python lda.py /input/to/tweets.txt /output/to/
"""
import sys
import codecs
from langdetect import detect
from textblob import TextBlob

import numpy as np
from sklearn.feature_extraction import text
from sklearn.feature_extraction.text import ENGLISH_STOP_WORDS
from sklearn import decomposition


###############################################

'''
Pretty print top words
'''
def print_top_words(model, feature_names, n_top_words):
	messages = []
	for topic_idx, topic in enumerate(model.components_):
		#message = "Topic #{}: ".format(topic_idx)
		#message += " ".join([feature_names[i]
		message = " ".join([feature_names[i]
			for i in topic.argsort()[:-n_top_words - 1:-1]])
		#print(message)
		messages.append(message)
	#print()
	return messages


###############################################

'''
Remove empty lines and return English phrases only
'''
def cleanup(lines):
	while '' in lines:
		lines.remove('')

	newlines = []
	for l in lines:
		try:
			if detect(l) == 'en':
				newlines.append(l)
			else:
				blob = TextBlob(l)
				en_blob = blob.translate(to='en')
				newlines.append(str(en_blob))
		except:
			pass

	#print newlines
	return newlines

###############################################

'''
A custom stop_words list by augmenting the already available
stop-words list
'''
def stop_words():
	en_stop_words = []
	for w in ENGLISH_STOP_WORDS: # frozenset, so append
		en_stop_words.append(w)
	# custom stop-words
	en_stop_words.append("rt")
	en_stop_words.append("http")
	en_stop_words.append("https")

	return en_stop_words

###############################################

'''
Apply Latent Dirichlet Allocation (LDA) for textual analysis
of tweet text corpus
'''
def process_lda():
	# inputs
	file_lines = []
	lines = []
	with codecs.open(sys.argv[1], encoding='UTF-8') as f:
		file_lines = f.read().splitlines()
	
	lines = cleanup(file_lines)

	# params for LDA
	n_feats = 1000
	n_topics = 10
	n_top_words = 10

	# getting a custom stop-words list
	en_stop_words = []
	en_stop_words = stop_words()

	# use tf (raw term count) features for LDA
	tf_vectorizer = text.CountVectorizer(max_df=0.95, min_df=2,
			#max_features=n_feats, stop_words='english')
			max_features=n_feats, stop_words=en_stop_words)
	tf = tf_vectorizer.fit_transform(lines)
	tf_feature_names = tf_vectorizer.get_feature_names()

	# fit an LDA model to the tf feats of the textual data
	lda = decomposition.LatentDirichletAllocation(max_iter=10,
			learning_method='online', learning_offset=50.,
			random_state=0, verbose=1).fit(tf)

	# outputs
	with open(sys.argv[2]+"/lda."+sys.argv[1].split("/")[-1:].pop()+".out", "w") as f:
		messages = print_top_words(lda, tf_feature_names, n_top_words)
		for m in messages:
			f.write("{}\n".format(m.encode('utf-8')))


###############################################

if __name__ == "__main__":
	try:
		process_lda()
	except:
		raise

