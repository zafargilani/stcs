#!/usr/bin/env/ python -W ignore
# -*- coding: utf-8 -*-
"""
Spectral Clustering for clustering Twitter accts by using
python scikit-learn (sklearn) SpectralClustering class.

(spectral clustering)
refr: https://en.wikipedia.org/wiki/Spectral_clustering
libr: http://scikit-learn.org/stable/modules/generated/sklearn.cluster.SpectralClustering.html

(preprocessing)
libr: http://scikit-learn.org/stable/modules/generated/sklearn.preprocessing.normalize.html
libr: http://scikit-learn.org/stable/modules/preprocessing.html#normalization

(dependencies)
numpy sklearn

(execute)
python spectral.py /input/to/userengagements.csv /output/to/
"""

import sys

import csv
import numpy as np
from sklearn import preprocessing
from sklearn.cluster import SpectralClustering

###############################################

'''
Apply Spectral Clustering to the tweet feature-set
for generating entity clusters dynamically
'''
def process_spectral(): 
	#X = np.loadtxt(sys.argv[1], delimiter=',', skiprows=1,
	X = np.loadtxt(sys.argv[1], delimiter=',', skiprows=0,
			#usecols=range(1,23)) # range(start,stop) - stop not inclusive, 1-16 or 1-23, 0 is screen_name
			usecols=range(1,16)) # range(start,stop) - stop not inclusive, 1-16 or 1-23, 0 is screen_name

	# transpose (to normalise per col) -> normalise -> transpose (back to correct matrix arrangement)
	#X_tran = X.transpose()
	#X_norm = preprocessing.normalize(X_tran, norm='l1') # L1 for least absolute deviations
	#X = X_norm.transpose()

	# Fit Spectral clustering and predict cluster lables
	labels = SpectralClustering(n_neighbors=1000, assign_labels='discretize',
			n_jobs=-1).fit_predict(X)

	# load screen_names
	with open(sys.argv[1]) as csvfile:
		read_csv = csv.reader(csvfile, delimiter=',')
		screen_names = []
		for row in read_csv:
			screen_names.append(row[0])

	# label clusters
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
		f = open(sys.argv[2]+"/spectral."+sys.argv[1].split("/")[-1:].pop()+".cluster"+str(cluster)+".out", "w+")
		for c in clusters[cluster]:
			f.write("{}\n".format(c))
		f.close()


###############################################

if __name__ == "__main__":
	try:
		process_spectral()
	except:
		raise

