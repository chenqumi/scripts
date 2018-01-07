#chenqumi@20170918
#! /usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import division
import sys,os,re

if len(sys.argv) != 5:
    print("\nUsage: {} <vcf> <sam.lst> <max-missing> <outfile>".format(sys.argv[0]))
    sys.exit()

vcf,samlst,miss,out = sys.argv[1:5]
miss = float(miss)
#
# ====================================

def calc_missing(checklist):
    
    total = 0
    miss_num = 0
    
    for i in checklist:
        genotype = i.split(":")[0]
        total += 1
        if genotype == "./.":
            miss_num += 1

    missing_rate = miss_num/total
    return missing_rate
#
# ====================================
sam_lst = []
sam_idx = []

with open(samlst) as lst_fd:
    for line in lst_fd:
        line = line.strip()
        sam_lst.append(line)
#
# ====================================
OT = open(out,"w")
with open(vcf) as vcf_fd:
    
    for line in vcf_fd:
        line = line.strip()

        if line.startswith("##"):
            OT.write(line+"\n")
            continue
        
        elif line.startswith("#CHROM"):
            
            tmp = line.split("\t")
            
            for sam in sam_lst:
                idx = tmp.index(sam)
                sam_idx.append(idx)
            
            OT.write(line+"\n")
            continue

        tmp = line.split("\t")
        sam_check = [tmp[i] for i in sam_idx]

        missing_rate = calc_missing(sam_check)
        #print (sam_check)
        if missing_rate <= miss:
            OT.write(line+"\n")
OT.close()