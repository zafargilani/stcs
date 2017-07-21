"""
=================================
Gaussian Mixture Model Ellipsoids
=================================

Plot the confidence ellipsoids of a mixture of two Gaussians
obtained with Expectation Maximisation (``GaussianMixture`` class) and
Variational Inference (``BayesianGaussianMixture`` class models with
a Dirichlet process prior).

Both models have access to five components with which to fit the data. Note
that the Expectation Maximisation model will necessarily use all five
components while the Variational Inference model will effectively only use as
many as are needed for a good fit. Here we can see that the Expectation
Maximisation model splits some components arbitrarily, because it is trying to
fit too many components, while the Dirichlet Process model adapts it number of
state automatically.

This example doesn't show it, as we're in a low-dimensional space, but
another advantage of the Dirichlet process model is that it can fit
full covariance matrices effectively even when there are less examples
per cluster than there are dimensions in the data, due to
regularization properties of the inference algorithm.

(gmm)
refr: http://scikit-learn.org/stable/modules/generated/sklearn.mixture.GaussianMixture.html
code: https://github.com/scikit-learn/scikit-learn/blob/master/examples/mixture/plot_gmm.py

(preprocessing)
refr: http://scikit-learn.org/stable/modules/preprocessing.html#normalization

exec: python plot_gmm.py K /path/to/data.csv
"""

import itertools

import numpy as np

from scipy import linalg

import matplotlib.pyplot as plt
import matplotlib as mpl

from sklearn import preprocessing
from sklearn import mixture

import sys

color_iter = itertools.cycle(['navy', 'c', 'cornflowerblue', 'gold',
                              'darkorange'])


def plot_results(X, Y_, means, covariances, index, title):
    splot = plt.subplot(2, 1, 1 + index)
    for i, (mean, covar, color) in enumerate(zip(
            means, covariances, color_iter)):
        v, w = linalg.eigh(covar)
        v = 2. * np.sqrt(2.) * np.sqrt(v)
        u = w[0] / linalg.norm(w[0])
        # as the DP will not use every component it has access to
        # unless it needs it, we shouldn't plot the redundant
        # components.
        if not np.any(Y_ == i):
            continue
        plt.scatter(X[Y_ == i, 0], X[Y_ == i, 1], .8, color=color)

        # Plot an ellipse to show the Gaussian component
        angle = np.arctan(u[1] / u[0])
        angle = 180. * angle / np.pi  # convert to degrees
        ell = mpl.patches.Ellipse(mean, v[0], v[1], 180. + angle, color=color)
        ell.set_clip_box(splot.bbox)
        ell.set_alpha(0.5)
        splot.add_artist(ell)

    plt.xlim(-9., 5.)
    plt.ylim(-3., 6.)
    plt.xticks(())
    plt.yticks(())
    plt.title(title)


## Number of samples per component
#n_samples = 500
#K = 2
#
## Generate random sample, two components
#np.random.seed(0)
#C = np.array([[0., -0.1], [1.7, .4]])
#X = np.r_[np.dot(np.random.randn(n_samples, 2), C),
#          .7 * np.random.randn(n_samples, 2) + np.array([-6, 3])]
#print(X)

#X = np.array([[4,1,2193.25,0,0,0,84.25,670.1724788,2.750925315,0.362052495,2188.81963,2,3,88.58789063,0,0,1,0,0,0,0],
#	[6,1,0,0,0,0,660.5,1.052280296,6.00344363,0,2290.981181,2,5,0,0,1,0,0,0,0,0],
#	[2,2,202,0,0,0,1850,30.89231307,5.207585203,0.02506832,1550.77037,1,1,53.85449219,0,0,1,0,0,0,0],
#	[11,1,1,0,0,0,72.18181818,1460.107632,20.85708145,3.25E-05,1473.912963,2,10,655.8378906,0,0,0,1,0,0,0]])
#print(X)

K = int(sys.argv[1])
X = np.genfromtxt(sys.argv[2], delimiter=',', skip_header=1,
	usecols=range(1,23)) # range(start,stop) - stop not inclusive, 1-16 or 1-23, 0 is screen_name
	#usecols=range(1,16)) # range(start,stop) - stop not inclusive, 1-16 or 1-23, 0 is screen_name

# Tranpose (to normalise per col), Normalise, Tranpose (back to correct matrix arrangement)
X_tran = X.transpose()
X_norm = preprocessing.normalize(X_tran, norm='l1') # L1 for least absolute deviations
X = X_norm.transpose()

print("K: {}, data shape: [{}][{}]".format(K, len(X), len(X[0])))

# Fit a Gaussian mixture with EM using five components
gmm = mixture.GaussianMixture(n_components=K, covariance_type='full', 
	tol=1e-4, max_iter=100, init_params='kmeans', warm_start=True,
	verbose=1).fit(X)
plot_results(X, gmm.predict(X), gmm.means_, gmm.covariances_, 0,
	'Gaussian Mixture')

# Fit a Dirichlet process Gaussian mixture using five components
dpgmm = mixture.BayesianGaussianMixture(n_components=K,
                                        covariance_type='full').fit(X)
plot_results(X, dpgmm.predict(X), dpgmm.means_, dpgmm.covariances_, 1,
	'Bayesian Gaussian Mixture with a Dirichlet process prior')

plt.show()

