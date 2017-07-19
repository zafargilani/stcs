"""
Normalise the multivariate dataset

libr: http://scikit-learn.org/stable/modules/preprocessing.html#normalization

exec: python normalise.py /path/to/data.csv /path/to/normalised.csv
"""

import sys
import csv

import numpy as np
from sklearn import preprocessing

# inputs
X = np.genfromtxt(sys.argv[1], delimiter=',', skip_header=1, 
	#usecols=range(1,23)) # range(start,stop) - stop not inclusive, 1-16 or 1-23, 0 is screen_name
	usecols=range(1,16)) # range(start,stop) - stop not inclusive, 1-16 or 1-23, 0 is screen_name

# Tranpose (to normalise per col), Normalise, Tranpose (back to correct matrix arrangement)
X_tran = X.transpose()
X_norm = preprocessing.normalize(X_tran, norm='l1') # L1 for least absolute deviations
X = X_norm.transpose()

# outputs
f = open(sys.argv[2], "w")
writer = csv.writer(f, delimiter=',')
for item in X:
	writer.writerow(item)

