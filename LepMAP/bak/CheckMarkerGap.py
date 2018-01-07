#chenqumi@20171110
#! /usr/bin/env python
# -*- coding: utf-8 -*-
import sys,os,re

if len(sys.argv) ==1:
    print("\nUsage: {} <order.txt> <gap size>".format(sys.argv[0]))
    sys.exit()

order,gap = sys.argv[1:3]
gap = float(gap)

with open(order) as fd:
    dist = 0
    for line in fd:
        line = line.strip()
        if line.startswith("#"):
            continue
        pos = float(line.split("\t")[1])
        if pos - dist > gap:
            print ("Big Gap:{}-{}".format(dist,pos))
            break 
        dist = pos
        

