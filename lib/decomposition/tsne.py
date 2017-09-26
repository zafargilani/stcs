#!/usr/bin/env/ python -W ignore
# -*- coding: utf-8 -*-
"""
t-distributed Stochastic Neighbour Embedding is a tool for nonlinear
dimensionality reduction for embedding high-dimensional data into 2D/3D
space. tSNE is used to extract features by exploring joint probabilities
using python scikit-learn (sklearn) TSNE class.

(tsne)
refr: https://en.wikipedia.org/wiki/T-distributed_stochastic_neighbor_embedding
libr: http://scikit-learn.org/stable/modules/generated/sklearn.manifold.TSNE.html
code: 

(execute)
python tsne.py N /path/to/data.csv
"""

import sys

import numpy as np
from sklearn import preprocessing
from sklearn import manifold


###############################################

'''
Apply tSNE to the tweet feature-set
for dimensionality reduction
'''
def process_tsne(): 
	# inputs
	N = int(sys.argv[1])
	X = np.genfromtxt(sys.argv[2], delimiter=',', skip_header=1,
			#usecols=range(1,23)) # range(start,stop) - stop not inclusive, 1-16 or 1-23, 0 is screen_name
			usecols=range(1,16)) # range(start,stop) - stop not inclusive, 1-16 or 1-23, 0 is screen_name

	## Tranpose (to normalise per col), Normalise, Tranpose (back to correct matrix arrangement)
	#X_tran = X.transpose()
	#X_norm = preprocessing.normalize(X_tran, norm='l1') # L1 for least absolute deviations
	#X = X_norm.transpose()

	#print("N: {}, data shape: [{}][{}]".format(N, len(X), len(X[0])))

	# dimensionality reduction to N using TSNE
	tsne = manifold.TSNE(n_components=N, n_iter=1000,
			n_iter_without_progress=500, init="pca",
			method="exact").fit(X) # barnes_hut

	# outputs
	with open("data/tsne."+sys.argv[2].split("/")[-1:].pop()+".N"+sys.argv[1]+".out", "w") as f:
		f.write("=== DATASET DETAILS ===\n")
		f.write("Input dataset: {}\n".format(sys.argv[2]))
		f.write("N: {}, data shape: [{}][{}]\n".format(N, len(X), len(X[0])))
		f.write("=== INPUT PARAMS ===\n")
		f.write("Estimator parameters: {}\n".format(tsne.get_params()))
		f.write("=== COMPONENT STATS ===\n")
		f.write("Embedding vectors: {}\n".format(tsne.embedding_))
		f.write("Kullback-Liebler divergence after optimisation: {}\n".format(tsne.kl_divergence_))


###############################################

if __name__ == "__main__":
	process_tsne()

