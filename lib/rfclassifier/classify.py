#!/usr/bin/env/ python -W ignore
# -*- coding: utf-8 -*-
# input:      train and test splits
# output:     training Random Forest classifier with subsets of given features (e.g. 22 here),
#             each iteration represents an ablation test (remove a feature, train and test),
#             GLOBAL represents globally optimum set of features
# to execute: python classify.py /input/userengagements[.csv] /output/rfclassifier[.csv]

# dependencies:
# python -m pip install --upgrade pip
# (sudo) pip install --user numpy scipy
# (sudo) apt-get install python python-tk
# (sudo) pip install -U scikit-learn

#

import os
import scipy
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

import sys

from sklearn import preprocessing
from sklearn.ensemble import RandomForestClassifier


###############################################

def initialise_all_data(in_file, fts):
    # Import the data and explore the first few rows
    data  = pd.read_csv(in_file, sep=",")
    #print(data.describe())
    header = []
    for item in fts:
        header.append(data.columns.values[item])
    data.head()
    #data.iloc[np.random.permutation(len(data))]
    # Convert to numpy array and check the dimensionality
    npArray = np.array(data)
    #np.random.shuffle(npArray)
    #print(npArray.shape)

    ###Split the data into input features, X, and outputs, y
    # Split to input matrix X and class vector y
    c = npArray[:,0]
    #X = npArray[:,1:-1]
    #take different features into account
    #X = npArray[:,ft:ft+1]
    X = np.empty([len(npArray), len(fts)])
    for index in range(0,len(npArray)):
        for item in range(0, len(fts)):
            X[index, item] = npArray[index, fts[item]]
    y = npArray[:,-1].astype(int)
    # Print the dimensions of X and y
    #print("X dimensions:", X.shape)
    #print("y dimensions:", y.shape)

    # Print the y frequencies
    yFreq = scipy.stats.itemfreq(y)
    #print(yFreq)
    # Convert to numeric and print the y frequencies
    le = preprocessing.LabelEncoder()
    y = le.fit_transform(y)
    yFreq = scipy.stats.itemfreq(y)
    #print(yFreq)
    #corr_class = float(yFreq[0,1])
    #err_class = float(yFreq[1,1])
    #baseline = (corr_class/(corr_class + err_class))
    #print("Baseline (correct instances) = " + str(round(baseline, 4)))
         
    # Auto-scale the data
    #X = preprocessing.scale(X)
    #X = preprocessing.normalize(X)    
    return X, y, header, c


###############################################
'''
The method to classify a particular instance:
INSTANCE should be represented as a string
with the feature values corresponding to
the training set feature indices and
separated by comma
FEATURES is a list of feature indices
'''
def classify_instance(instance, features):
    #XTrain, yTrain, header, cTrain = initialise_all_data("/local/scratch/szuhg2/stcs/data/training/train_1k.csv", features) 
    XTrain, yTrain, header, cTrain = initialise_all_data("../../data/training/train_all.csv", features) 
    fts = []
    voc = instance.split(",")
    #index starts off from 1 if the account name is included
    # 0 otherwise
    for index in range(1,len(voc)):
        if index in features:
            fts.append(voc[index].strip())
    XTest = np.empty([1, len(fts)])
    for item in range(0, len(fts)):
        XTest[0, item] = fts[item]
    rf = RandomForestClassifier(n_estimators=100, random_state=0)
    rf.fit(XTrain, yTrain)
    predRF = rf.predict(XTest)
    #print(predRF)
    if predRF[0]==0: 
	#print(voc[0], "bot", predRF)
	return voc[0], "bot", predRF
    elif predRF[0]==1:
	#print(voc[0], "human", predRF)
	return voc[0], "human", predRF
    

###############################################
        
if __name__ == "__main__":
    feats_10M = [6,7,12,13,18,20]
    feats_1M = [3,8,10,13,16,18,19,20]
    feats_100k = [2,3,4,10,13,14,15,16,18,20,21]
    feats_1k = [2,3,8,9,10,11,12,13,14,15,16,18,20,21]
    feats_all = [4,6,7,9,10,11,13,16,17,18] #best-fit

    examples = []
    name = [None]*4
    category = [None]*4
    pred = [None]*4

    if len(sys.argv) == 1:
	print("to execute examples: python classify.py examples")
	print("to execute program with data: python classify.py /path/input[.csv] /path/output[.csv]")
    elif len(sys.argv) == 2 and sys.argv[1] == "examples":
	examples.append("BridgetteWest,4,1,2193.25,0,0,0,84.25,670.1724788,2.750925315,0.362052495,2188.81963,2,3,88.58789063,0,0,1,0,0,0,0")
	examples.append("CardiffBiz,6,1,0,0,0,0,660.5,1.052280296,6.00344363,0,2290.981181,2,5,0,0,1,0,0,0,0,0")
	examples.append("04LS_nagoya,2,2,202,0,0,0,1850,30.89231307,5.207585203,0.02506832,1550.77037,1,1,53.85449219,0,0,1,0,0,0,0")
	examples.append("caperucitazorra,11,1,1,0,0,0,72.18181818,1460.107632,20.85708145,3.25E-05,1473.912963,2,10,655.8378906,0,0,0,1,0,0,0,0")
        name[0], category[0], pred[0] = classify_instance(examples[0], feats_all)
        name[1], category[1], pred[1] = classify_instance(examples[1], feats_all)
        name[2], category[2], pred[2] = classify_instance(examples[2], feats_all)
        name[3], category[3], pred[3] = classify_instance(examples[3], feats_all)
	for i in range(len(examples)):
	    print(name[i] + ", " + category[i] + ", " + str(pred[i]))
    elif len(sys.argv) == 3:
        with open(sys.argv[1], 'r') as fr:
    	    fcontent = fr.readlines()
    	    flines = [x.strip() for x in fcontent]
    	    #flines = f.readlines()
    	    for fline in flines:
                name, category, pred = classify_instance(fline, feats_all)
	        st = name + ", " + category + ", " + str(pred) + "\n"
	        #print(name, category, pred)
	        with open(sys.argv[2], 'a') as fw:
	            fw.write(st)
		#time.sleep(1)
    else:
	print("to execute examples: python classify.py examples")
	print("to execute program with data: python classify.py /path/input[.csv] /path/output[.csv]")

