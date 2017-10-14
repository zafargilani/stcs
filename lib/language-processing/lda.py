"""
Latent Dirichlet Allocation model (online variation Bayes method or batch)
for extracting topic structure of the supplied corpus of tweet documents
using python scikit-learn (sklearn) LatentDirichletAllocation class.

(lda)
refr: https://en.wikipedia.org/wiki/Latent_Dirichlet_allocation
libr: http://scikit-learn.org/stable/modules/generated/sklearn.decomposition.LatentDirichletAllocation.html
code: http://scikit-learn.org/stable/auto_examples/applications/plot_topics_extraction_with_nmf_lda.html

(execute)
python lda.py /input/to/tweets.txt /output/to/
"""
import sys
import codecs

import numpy as np
from sklearn.feature_extraction import text
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
Apply Latent Dirichlet Allocation (LDA) for textual analysis
of tweet text corpus
'''
def process_lda():
	# inputs
	lines = []
	with codecs.open(sys.argv[1], encoding='UTF-8') as f:
		lines = f.read().splitlines()
	# clean-up: rm empty string
	while '' in lines:
		lines.remove('')
	#print(lines)

	# params for LDA
	n_feats = 1000
	n_topics = 10
	n_top_words = 10

	# use tf (raw term count) features for LDA
	tf_vectorizer = text.CountVectorizer(max_df=0.95, min_df=2,
			max_features=n_feats, stop_words='english')
	tf = tf_vectorizer.fit_transform(lines)
	tf_feature_names = tf_vectorizer.get_feature_names()

	# fit an LDA model to the tf feats of the textual data
	lda = decomposition.LatentDirichletAllocation(max_iter=10,
			learning_method='online', learning_offset=50.,
			random_state=0, verbose=1).fit(tf)

	# outputs
	with open(sys.argv[2]+"/lda."+sys.argv[1].split("/")[-1:].pop()+".out", "w") as f:
		#f.write("=== DATASET DETAILS ===\n")
		#f.write("Input dataset: {}\n".format(sys.argv[1]))
		#f.write("Fitting LDA with term freq (tf): n_samples {}, n_features {}\n"
		#		.format(len(lines), n_feats))
		#f.write("=== INPUT PARAMS ===\n")
		#f.write("Estimator parameters: {}\n".format(lda.get_params()))
		#f.write("=== TOPIC STATS ===\n")
		#f.write("Number of iterations of the EM step: {}\n".format(lda.n_batch_iter_))
		#f.write("Number of passes over the dataset: {}\n".format(lda.n_iter_))
		#f.write("Log-likelihood of best-fit of EM: {}\n".format(lda.score(tf)))
		#f.write("=== TOP WORDS ===\n")
		messages = print_top_words(lda, tf_feature_names, n_top_words)
		for m in messages:
			f.write("{}\n".format(m.encode('utf-8')))


###############################################

if __name__ == "__main__":
	process_lda()

