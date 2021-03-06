#!/usr/bin/env/ python -W ignore
# -*- coding: utf-8 -*-
"""
Gaussian Mixture Model for clustering types of Twitter accts by
using python scikit-learn (sklearn) GaussianMixture class.

(gmm)
refr: https://brilliant.org/wiki/gaussian-mixture-model/
libr: http://scikit-learn.org/stable/modules/generated/sklearn.mixture.GaussianMixture.html
code: https://github.com/scikit-learn/scikit-learn/blob/master/examples/mixture

(preprocessing)
libr: http://scikit-learn.org/stable/modules/generated/sklearn.preprocessing.normalize.html
libr: http://scikit-learn.org/stable/modules/preprocessing.html#normalization

(dependencies)
numpy sklearn

(execute)
python gmm.py K /input/to/userengagements.csv /output/to/
"""

import sys

import csv
import numpy as np
from sklearn import preprocessing
from sklearn import mixture


###############################################

'''
Apply Gaussian Mixture Models to the tweet feature-set
for clustering entities
'''
def process_gmm(): 
	K = int(sys.argv[1])

	# load all cols except screen_names (0)
	#X = np.loadtxt(sys.argv[2], delimiter=',', skiprows=1,
	X = np.loadtxt(sys.argv[2], delimiter=',', skiprows=0,
			#usecols=range(1,23)) # range(start,stop) - stop not inclusive, 1-16 or 1-23, 0 is screen_name
			usecols=range(1,16)) # range(start,stop) - stop not inclusive, 1-16 or 1-23, 0 is screen_name
	#X = np.genfromtxt(sys.argv[2], delimiter=',', skip_header=1,
	#		#usecols=range(1,23)) # range(start,stop) - stop not inclusive, 1-16 or 1-23, 0 is screen_name
	#		usecols=range(1,16)) # range(start,stop) - stop not inclusive, 1-16 or 1-23, 0 is screen_name

	## Tranpose (to normalise per col), Normalise, Tranpose (back to correct matrix arrangement)
	#X_tran = X.transpose()
	#X_norm = preprocessing.normalize(X_tran, norm='l1') # L1 for least absolute deviations
	#X = X_norm.transpose()

	#print("K: {}, data shape: [{}][{}]".format(K, len(X), len(X[0])))

	# Fit a Gaussian mixture with EM using K components
	gmm = mixture.GaussianMixture(n_components=K, covariance_type='full',
			tol=1e-4, max_iter=500, n_init=3, init_params='kmeans',
			warm_start=True, verbose=1).fit(X)

	## generate random samples from the fitted Gaussian distribution
	#sample = gmm.sample(1000)

	# load screen_names
	with open(sys.argv[2]) as csvfile:
		read_csv = csv.reader(csvfile, delimiter=',')
		screen_names = []
		for row in read_csv:
			screen_names.append(row[0])

	# label clusters
	labels = gmm.predict(X)
	clusters = {}
	i = 0
	for label in labels:
		if label in clusters:
			clusters[label].append(screen_names[i])
		else:
			clusters[label] = [screen_names[i]]
		i += 1

	# outputs
	for cluster in clusters:
		f = open(sys.argv[3]+"/gmm."+sys.argv[2].split("/")[-1:].pop()+".K"+sys.argv[1]+".cluster"+str(cluster)+".out", "w+")
		for c in clusters[cluster]:
			f.write("{}\n".format(c))
		f.close()


###############################################

if __name__ == "__main__":
	try:
		process_gmm()
	except:
		raise

