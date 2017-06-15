"""
Gaussian Mixture Model for clustering types of Twitter accts by
using python scikit-learn (sklearn) GaussianMixture class

refr: https://brilliant.org/wiki/gaussian-mixture-model/
libr: http://scikit-learn.org/stable/modules/generated/sklearn.mixture.GaussianMixture.html
code: https://github.com/scikit-learn/scikit-learn/blob/master/examples/mixture

exec: python gmm.py K /path/to/data.csv
"""

import sys

import numpy as np
from sklearn import mixture

# inputs
K = int(sys.argv[1])
X = np.genfromtxt(sys.argv[2], delimiter=',', skip_header=1, 
	usecols=range(1,16)) # range(start,stop) - stop not inclusive, 1-16 or 1-23

print("K: {}, data shape: [{}][{}]".format(K, len(X), len(X[0])))

# Fit a Gaussian mixture with EM using K components
gmm = mixture.GaussianMixture(n_components=K, covariance_type='full',
	tol=1e-4, max_iter=100, init_params='kmeans', warm_start=True,
	verbose=1).fit(X)

# outputs
f = open("data/gmm.out", "w")
f.write("=== component stats ===\n")
f.write("weights: {}i\n".format(gmm.weights_))
f.write("means: {}\n".format(gmm.means_))
f.write("covariances: {}\n".format(gmm.covariances_))
f.write("precisions: {}\n".format(gmm.precisions_))
f.write("converged? {}\n".format(gmm.converged_))
f.write("iterations to converge: {}\n".format(gmm.n_iter_))
f.write("log-likelihood of best-fit of EM: {}\n".format(gmm.lower_bound_))

