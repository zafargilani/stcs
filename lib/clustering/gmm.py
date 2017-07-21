"""
Gaussian Mixture Model for clustering types of Twitter accts by
using python scikit-learn (sklearn) GaussianMixture class

(gmm)
refr: https://brilliant.org/wiki/gaussian-mixture-model/
libr: http://scikit-learn.org/stable/modules/generated/sklearn.mixture.GaussianMixture.html
code: https://github.com/scikit-learn/scikit-learn/blob/master/examples/mixture

(preprocessing)
libr: http://scikit-learn.org/stable/modules/preprocessing.html#normalization

exec: python gmm.py K /path/to/data.csv
"""

import sys

import numpy as np
from sklearn import preprocessing
from sklearn import mixture

# inputs
K = int(sys.argv[1])
X = np.genfromtxt(sys.argv[2], delimiter=',', skip_header=1, 
	usecols=range(1,23)) # range(start,stop) - stop not inclusive, 1-16 or 1-23, 0 is screen_name
	#usecols=range(1,16)) # range(start,stop) - stop not inclusive, 1-16 or 1-23, 0 is screen_name

## Tranpose (to normalise per col), Normalise, Tranpose (back to correct matrix arrangement)
#X_tran = X.transpose()
#X_norm = preprocessing.normalize(X_tran, norm='l1') # L1 for least absolute deviations
#X = X_norm.transpose()

print("K: {}, data shape: [{}][{}]".format(K, len(X), len(X[0])))

# Fit a Gaussian mixture with EM using K components
gmm = mixture.GaussianMixture(n_components=K, covariance_type='full',
	tol=1e-4, max_iter=100, init_params='kmeans', warm_start=True,
	verbose=1).fit(X)

## generate random samples from the fitted Gaussian distribution
#sample = gmm.sample(1000)

## compute avg log-likelihood and weighted log probabilities of each data point in X
#score = gmm.score(X)
#score_weighted = gmm.score_samples(X)

# compute IC scores
bic = gmm.bic(X)
aic = gmm.aic(X)

# predict the component labels for the data in X using trained model
predict = gmm.predict(X)

# posterior probability of data points in X belonging to each Gaussian in the model
predict_proba = gmm.predict_proba(X)

# outputs
f = open("data/gmm.out", "w")
f.write("=== dataset details ===\n")
f.write("input dataset: {}\n".format(sys.argv[2]))
f.write("K: {}, data shape: [{}][{}]\n".format(K, len(X), len(X[0])))
f.write("=== component stats ===\n")
f.write("weights: {}i\n".format(gmm.weights_))
f.write("means: {}\n".format(gmm.means_))
f.write("covariances: {}\n".format(gmm.covariances_))
f.write("precisions: {}\n".format(gmm.precisions_))
f.write("converged? {}\n".format(gmm.converged_))
f.write("iterations to converge: {}\n".format(gmm.n_iter_))
f.write("log-likelihood of best-fit of EM: {}\n".format(gmm.lower_bound_))
f.write("Bayesian information criterion (bic): {}\n".format(bic))
f.write("Akaike information criterion (aic): {}\n".format(aic))
f.write("component labels of x from X: {}\n".format(predict))
f.write("posterior prob. of each x from X belonging to each Gaussian (component): {}\n".format(predict_proba))

