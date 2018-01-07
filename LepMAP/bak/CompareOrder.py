#chenqumi@20171026
#! /usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import division
import sys,os,re
import math

if len(sys.argv) ==1:
    print("\nUsage: {} <order1> <order2>".format(sys.argv[0]))
    sys.exit()

order1,order2 = sys.argv[1:3]
#
# =================================================
def GetOrderList(order):
    
    od_lst = []
    
    with open(order) as fd:
        for i in fd:
            i = i.strip()
            od_lst.append(i)

    return od_lst
#
# =================================================
def CalcVariance(od1_common,od2_common):
    
    index = 0
    sum_square = 0

    for i in od2_common:
        
        index_i = od1_common.index(i)
        sum_square +=  (index_i-index)**2

        index += 1

    variance = sum_square/len(od1_common)
    std = math.sqrt(variance)

    return variance,std
#
# =================================================
def ExpectVariance(od_common):

    num = len(od_common)
    order = range(num)
    mean = [sum(order)/num for i in range(num)]

    index = 0
    sum_square = 0
    
    for i in mean:
        sum_square += (i-order[index])**2
        index += 1

    expectvariance = sum_square/num
    expectstd = math.sqrt(expectvariance)

    return expectvariance,expectstd
#
# =================================================
def main():
    
    od_lst1 = GetOrderList(order1)
    od_lst2 = GetOrderList(order2)

    od1_common = [i for i in od_lst1 if i in od_lst2]
    od2_common = [i for i in od_lst2 if i in od_lst1]

    od1_commn_r = od1_common[::-1]
    
    variance,std = CalcVariance(od1_common,od2_common)
    max_variance,max_std = CalcVariance(od1_common,od1_commn_r)
    expectvariance,expectstd = ExpectVariance(od1_common)

    variance_ratio = variance/max_variance
    std_ratio = std/max_std

    print ("common seq length:\t{}".format(len(od1_common)))
    print ("max variace:\t{}".format(max_variance))
    print ("max std:\t{}".format(max_std))
    print ("expected variace:\t{}".format(expectvariance))
    print ("expected std:\t{}".format(expectstd))
    print ("variace:\t{}".format(variance))
    print("std:\t{}".format(std))
    print ("variace ratio:\t{}".format(variance_ratio))
    print("std ratio:\t{}".format(std_ratio))
#
# =================================================
if __name__ == '__main__':
    main()