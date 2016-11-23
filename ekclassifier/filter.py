#!/usr/bin/env/ python
# -*- coding: utf-8 -*-
# step:       2
# input:      train splits1, feature csvs
# output:     train and test splits2 (to cover all 3 experiments - see paper)
# to execute: python filter.py

#
from __future__ import print_function, division

import os
import scipy
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt



def split(input1, input2, output):
    f1 = open(input1)
    f2 = open(input2)
    out = open(output, "w")
    a_dict = []
    for a_line in f2.readlines():
        if not a_line.startswith("username"):
            voc = a_line.split(",")
            a_dict.append(voc[0].strip())
    f2.close()
    voc1 = []
    #for a_line in f1.readlines():
    #    voc1 = a_line.split("\r")
    for a_line in f1.readlines():
        voc = a_line.split(",")
        user_name = voc[0].strip()
        if user_name in a_dict:
            out.write(a_line.strip() + "\n")
    f1.close()
    out.close()  


def split2(input1, input2, output):
    f1 = open(input1)
    f2 = open(input2)
    out = open(output, "w")
    out.write("u,1,2,3,4,5,6,7,8,9,10,11,12,13,14,l\n")
    a_dict = []
    for a_line in f1.readlines():
        if not a_line.startswith("username"):
            voc = a_line.split(",")
            a_dict.append(voc[0].strip())
    f1.close()
    print (a_dict)
    voc1 = []
    for a_line in f2.readlines():
        voc1 = a_line.split("\r")
    for a_line in voc1:
        voc = a_line.split(",")
        user_name = voc[0].strip()
        if not user_name in a_dict:
            out.write(a_line.strip() + "\n")
    f2.close()
    out.close()  

    
if __name__ == "__main__":
    a_list = ["1k", "100k", "1M", "10M"]
    b_list = ["1", "2", "3", "4", "5"]
    for item in a_list:
        for jtem in b_list:
            split2("splits1/train" + jtem + ".csv", "new/humans-" + item + ".csv", "splits2/test" + jtem + "_" + item + ".csv")
            
