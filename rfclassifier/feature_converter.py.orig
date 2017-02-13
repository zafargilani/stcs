#!/usr/bin/env/ python
# -*- coding: utf-8 -*-
# step:       1 of 3
# input:      feature csv file per popularity band
# output:     train and test splits1 only
# to execute: python feature_converter.py

## do different types of preprocessing on the bigram data
from __future__ import print_function, division
import os
import math
#import nltk
import operator
import sys
import random
from random import shuffle
from math import log


def convert(input_file, output_file, label):
    f = open(input_file)
    out = open(output_file, "w")
    for a_line in f.readlines():
        if a_line.startswith("screen_name"):
            out.write(a_line.strip() + ",label\n")
        else:
            out.write(a_line.strip() + "," + label + "\n")
     
#        verb = round(apply_log(float(verb), 100)/10, 4) #conversion
#        noun = round(apply_log(float(noun), 100)/10, 4) #conversion
    f.close()
    out.close()

def convert_log(input_file, output_file):
    f = open(input_file)
    out = open(output_file, "w")
    for a_line in f.readlines():
        voc0 = a_line.split("\r")
        for l in voc0:
            if l.startswith("screen_name"):
                out.write(l.strip() + "\n")
            else:
                voc = l.split(",")
                out.write(voc[0].strip() + ",")
                for i in range(1, len(voc)-1):
                    print (voc[i])
                    out.write(str(round(apply_log(float(voc[i]), 10)/10, 4)) + ",")
                out.write(voc[len(voc)-1] + "\n")
    f.close()
    out.close()

def apply_log(a_num, scale):
    output = 0
    if a_num>0:
        return log(scale * (float(a_num)))/log(2)
    elif a_num==0: 
        return 0
    else:
        new_num = 0 - a_num
        output = log(scale * (float(new_num)))/log(2)
        return (0-output)

def apply_exp(a_num):
    return (1/(1 + math.exp(-a_num)))

def rewrite(original, remove):
    output = []
    for item in original:
        if not item in set(remove):
            output.append(item)
    return output

def writing_out(a_dict, a_file, out_folder):
    f = open(out_folder + a_file, "w")
    #header = "screen_name,favourite_count,retweet_count,listed_count,follower_friend_ratio,tweet_frequency,favourite_tweet_ratio,tweet_count,age_of_account_in_days,replies_count,sources_count,urls_count,cdn_content_in_kb,label\n"
    header = "screen_name,user_tweeted,user_retweeted,user_favourited,user_replied,likes_per_tweet,retweets_per_tweet,lists_per_user,follower_friend_ratio,tweet_frequency,favourite_tweet_ratio,age_of_account_in_days,sources_count,urls_count,cdn_content_in_kb,label\n"
    f.write(header)
    for item in sorted(set(a_dict)):
        f.write(item.strip() + "\n")
    f.close()
    
#def split(one_file, ten_file, out_folder):
def split(files, out_folder):
    #f1 = open(one_file)
    #f10 = open(ten_file)
    positive = {}
    negative = {}    
    ttrain1 = []
    ttest1 = []
    ttrain2 = []
    ttest2 = []
    ttrain3 = []
    ttest3 = []
    ttrain4 = []
    ttest4 = []
    ttrain5 = []
    ttest5 = []
    pos_index = 0
    neg_index = 0
    for a_file in files:
        f1 = open(a_file)
        for a_line in f1.readlines():
            voc0 = a_line.split("\r")
            for l in voc0:
                if not l.startswith("screen_name"):
                    if l.strip().endswith("0"):
                        negative[neg_index] = l.strip()
                        neg_index += 1
                    else:
                        positive[pos_index] = l.strip()
                        pos_index += 1
        f1.close()
    #for a_line in f10.readlines():
    #    voc0 = a_line.split("\r")
    #    for l in voc0:
    #        if not l.startswith("screen_name"):
    #            if l.strip().endswith("0"):
    #                negative[neg_index] = l.strip()
    #                neg_index += 1
    #            else:
    #                positive[pos_index] = l.strip()
    #                pos_index += 1
    #print(negative)
    #f1.close()
    #f10.close()
    all_positives = []
    all_negatives = []
    remove_positives = []
    remove_negatives = []
    for i in positive.keys():
        all_positives.append(i)
    for i in negative.keys():
        all_negatives.append(i)
    resid_positives = rewrite(all_positives, remove_positives)
    resid_negatives = rewrite(all_negatives, remove_negatives)
    pos_random_ceiling = int(len(all_positives)/5) + 1
    neg_random_ceiling = int(len(all_negatives)/5) + 1

    #round1    
    while len(set(ttest1))!=pos_random_ceiling:
        rand = random.randrange(0, len(resid_positives))
        item = positive.get(resid_positives[rand])
        ttest1.append(item.strip())
        ttrain2.append(item.strip())
        ttrain3.append(item.strip())
        ttrain4.append(item.strip())
        ttrain5.append(item.strip())
        remove_positives.append(resid_positives[rand])
        resid_positives = rewrite(all_positives, remove_positives)
    while len(set(ttest1))!=pos_random_ceiling+neg_random_ceiling:
        rand = random.randrange(0, len(resid_negatives))
        item = negative.get(resid_negatives[rand])
        ttest1.append(item.strip())
        ttrain2.append(item.strip())
        ttrain3.append(item.strip())
        ttrain4.append(item.strip())
        ttrain5.append(item.strip())
        remove_negatives.append(resid_negatives[rand])
        resid_negatives = rewrite(all_negatives, remove_negatives)
    
    #round2   
    while len(set(ttest2))!=pos_random_ceiling:
        rand = random.randrange(0, len(resid_positives))
        item = positive.get(resid_positives[rand])
        ttest2.append(item.strip())
        ttrain1.append(item.strip())
        ttrain3.append(item.strip())
        ttrain4.append(item.strip())
        ttrain5.append(item.strip())
        remove_positives.append(resid_positives[rand])
        resid_positives = rewrite(all_positives, remove_positives)
    while len(set(ttest2))!=pos_random_ceiling+neg_random_ceiling:
        rand = random.randrange(0, len(resid_negatives))
        item = negative.get(resid_negatives[rand])
        ttest2.append(item.strip())
        ttrain1.append(item.strip())
        ttrain3.append(item.strip())
        ttrain4.append(item.strip())
        ttrain5.append(item.strip())
        remove_negatives.append(resid_negatives[rand])
        resid_negatives = rewrite(all_negatives, remove_negatives)

    #round3   
    while len(set(ttest3))!=pos_random_ceiling:
        rand = random.randrange(0, len(resid_positives))
        item = positive.get(resid_positives[rand])
        ttest3.append(item.strip())
        ttrain1.append(item.strip())
        ttrain2.append(item.strip())
        ttrain4.append(item.strip())
        ttrain5.append(item.strip())
        remove_positives.append(resid_positives[rand])
        resid_positives = rewrite(all_positives, remove_positives)
    while len(set(ttest3))!=pos_random_ceiling+neg_random_ceiling:
        rand = random.randrange(0, len(resid_negatives))
        item = negative.get(resid_negatives[rand])
        ttest3.append(item.strip())
        ttrain1.append(item.strip())
        ttrain2.append(item.strip())
        ttrain4.append(item.strip())
        ttrain5.append(item.strip())
        remove_negatives.append(resid_negatives[rand])
        resid_negatives = rewrite(all_negatives, remove_negatives)

    #round4   
    while len(set(ttest4))!=pos_random_ceiling:
        rand = random.randrange(0, len(resid_positives))
        item = positive.get(resid_positives[rand])
        ttest4.append(item.strip())
        ttrain1.append(item.strip())
        ttrain2.append(item.strip())
        ttrain3.append(item.strip())
        ttrain5.append(item.strip())
        remove_positives.append(resid_positives[rand])
        resid_positives = rewrite(all_positives, remove_positives)
    while len(set(ttest4))!=pos_random_ceiling+neg_random_ceiling:
        rand = random.randrange(0, len(resid_negatives))
        item = negative.get(resid_negatives[rand])
        ttest4.append(item.strip())
        ttrain1.append(item.strip())
        ttrain2.append(item.strip())
        ttrain3.append(item.strip())
        ttrain5.append(item.strip())
        remove_negatives.append(resid_negatives[rand])
        resid_negatives = rewrite(all_negatives, remove_negatives)

    for i in resid_positives:
        item = positive.get(i)
        ttest5.append(item.strip())
        ttrain1.append(item.strip())
        ttrain2.append(item.strip())
        ttrain3.append(item.strip())
        ttrain4.append(item.strip())
    for i in resid_negatives:
        item = negative.get(i)
        ttest5.append(item.strip())
        ttrain1.append(item.strip())
        ttrain2.append(item.strip())
        ttrain3.append(item.strip())
        ttrain4.append(item.strip())
    
    writing_out(ttrain1, "train1.csv", out_folder)
    writing_out(ttest1, "test1.csv", out_folder)
    writing_out(ttrain2, "train2.csv", out_folder)
    writing_out(ttest2, "test2.csv", out_folder)
    writing_out(ttrain3, "train3.csv", out_folder)
    writing_out(ttest3, "test3.csv", out_folder)
    writing_out(ttrain4, "train4.csv", out_folder)
    writing_out(ttest4, "test4.csv", out_folder)
    writing_out(ttrain5, "train5.csv", out_folder)
    writing_out(ttest5, "test5.csv", out_folder)

               
if __name__ == "__main__":
    #convert("new/humans-1k.csv", "new/humans-1k_1.csv", "1")
    #convert_log("humans-1M-userengagements.csv", "humans-1M-userengagements_log.csv")
    #convert_log("humans-10M-userengagements.csv", "humans-10M-userengagements_log.csv")
    split(["new/humans-1k.csv", "new/humans-100k.csv", "new/humans-10M.csv", "new/humans-1M.csv"], "splits1/")

