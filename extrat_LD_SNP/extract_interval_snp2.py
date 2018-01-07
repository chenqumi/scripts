#chenqumi@20170704
#! /usr/bin/env python
# -*- coding: utf-8 -*-
import sys,os,re

if len(sys.argv) ==1:
    print("\nUsage: {} <vcf> <distance> <out>".format(sys.argv[0]))
    sys.exit()

vcf,dist,out = sys.argv[1:4]

dist = int(dist)
index = 0

OT = open(out,"w")
with open(vcf) as VCF:
    
    init_pos = int
    
    for line in VCF:
        
        if line.startswith("#"):
            #OT.write(line)
            continue

        pos = int(line.split("\t")[1])
        
        if index == 0:
            init_pos = pos
        
        m = init_pos + index*dist

        if pos >= m:
            OT.write(line)
            index += 1
        else:
            continue

OT.close()
