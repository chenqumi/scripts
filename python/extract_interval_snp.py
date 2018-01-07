#chenqumi@20170704
#! /usr/bin/env python
# -*- coding: utf-8 -*-
import sys,os,re

if len(sys.argv) ==1:
    print("\nUsage: {} <vcf> <distance> <out>".format(sys.argv[0]))
    sys.exit()

vcf,dist,out = sys.argv[1:4]

dist = int(dist)
flag = 1
OT = open(out,"w")
with open(vcf) as VCF:
    
    for line in VCF:
        if line.startswith("#"):
            continue
        
        pos = int(line.split("\t")[1])
        m = int(pos/dist)
        if  m < flag:
            continue
        else:
            OT.write(line)
            flag = m + 1
OT.close()
