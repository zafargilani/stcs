"""
Principal Component Analysis for finding principle components
from a given feature-set of Twitter accts using eigen vectors

(pca)
refr: https://brilliant.org/wiki/principal-component-analysis/
libr: http://scikit-learn.org/stable/modules/generated/sklearn.decomposition.PCA.html

exec: python pca.py /path/to/data.csv
"""

import sys

import numpy as np
import pandas as pd
from sklearn import decomposition

import matplotlib.pylab as plt
import seaborn as sns

customers = pd.read_csv(sys.argv[1],
	index_col = "screen_name")
customers.head()

continuous_features = ['user_statuses', 'user_tweets',
	'user_retweets', 'user_favourites', 'user_replies_and_mentions',
	'likes_per_tweet', 'retweets_per_tweet', 'lists_account_age_ratio',
	'follower_friend_ratio', 'lifetime_statuses_freq',
	'favourite_tweet_ratio', 'age_of_account_in_days',
	'sources_count', 'urls_count', 'daily_favouriting_frequency']

#daily_favouriting_frequency = customers['daily_favouriting_frequency']
#customers = customers[continuous_features]
#customers.head()

pca = decomposition.PCA()
ind = ['PC'+str(i+1) for i in range(customers.shape[1])]

# Create the PCA scores matrix and check the dimensionality
# scores is data in eigen vectors
scores = pca.fit_transform(customers)
scores = pd.DataFrame(scores, columns = ind,
	index = customers.index)
print("shape of data in eigen vectors (scores): {}".format(scores.shape))

# Create the PCA loadings matrix and check the dimensionality
# loadings is coefficients for eigen vectors
loadings = pca.components_
loadings = pd.DataFrame(loadings, columns = customers.columns,
	index = ind)
print("shape of coefficients for eigen vectors (loadings): {}".format(loadings.shape))

# Plot heatmap
#fig = plt.figure(figsize=(10,7))
#hm = sns.heatmap(data=loadings)

# Calculate the explained variance
exp_var = [i*100 for i in pca.explained_variance_ratio_]

# Calculate the cumulative variance
cum_var = np.cumsum(pca.explained_variance_ratio_*100)

# Combine both in a data frame
pca_var = pd.DataFrame(data={'exp_var': exp_var,
	'cum_var': cum_var},
	index=ind)
pca_var.head(10)
print(pca_var)

# Plot the explained variance per PC using a barplot
#fig = plt.figure(figsize=(10,7))
#ax = sns.barplot(x=pca_var.index, y='exp_var', data=pca_var)
#ax.set(xlabel='Principal Components',
#		ylabel='Explained Variance')

# Help to find cutoff points
exp_var = [i*100 for i in pca.explained_variance_ratio_]
cum_var = np.cumsum(pca.explained_variance_ratio_*100)
pca_var = pd.DataFrame(data={'cum_var': cum_var}, index=ind)
print(pca_var)

# Plot the cumulative variance
#fig = plt.figure(figsize=(10,7))
#ax = sns.barplot(x=pca_var.index, y='cum_var', data=pca_var)
#ax.set(xlabel='Principal Components',
#		ylabel='Explained Variance')

# Show all the plots
#sns.plt.show()

scores.to_csv('data/pca.out')

