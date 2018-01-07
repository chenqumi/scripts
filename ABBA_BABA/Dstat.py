#chenqumi@20171212
#! /usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import division
from collections import OrderedDict
import jackknife
import sys,os,re
import argparse

# Args parse
#==========================================================
parser = argparse.ArgumentParser(description =
    "D-statistic(ABBA-BABA test) for SNP")

parser.add_argument("-v", dest="vcf", required=True,
                    help="population vcf file")

parser.add_argument("-p1", dest="pop1", required=True,
                    help="population1 sample list, 1 sam per line")

parser.add_argument("-p2", dest="pop2", required=True,
                    help="population2 sample list, 1 sam per line")

parser.add_argument("-p3", dest="pop3", required=True,
                    help="population2 sample list, 1 sam per line")

parser.add_argument("-o", dest="outgroup", required=True,
                    help="outgroup sample list, 1 sam per line")

parser.add_argument("-w", dest="window", type=int, required=True,
                    help="window for genome-wide scan, larger than LD")

args = parser.parse_args()
vcf = args.vcf
pop1 = args.pop1
pop2 = args.pop2
pop3 = args.pop3
outgroup = args.outgroup
window = args.window

# global variable
#==========================================================
abba = OrderedDict({})
D_jacked = []

#
#==========================================================
def indexpop(pop):
    
    sample = []
    with open(pop) as POP:
        for line in POP:
            line = line.strip()
            sample.append(line)

    tmp = []
    with open(vcf) as fd:
        for line in fd:
            if line.startswith("#CHROM"):
                lines = line.strip().split("\t")
                for i in sample:
                    tmp.append(lines.index(i))

    return tmp

#
#==========================================================
def calc(pop_gt):
    
    allele = {"0":0,"1":0}
    
    for sam in pop_gt:
        gt1,gt2 = sam.split(":")[0].split("/")
        
        if gt1 == ".":
            continue
        
        allele[gt1] += 1
        allele[gt2] += 1

    try:
        frqsnp = allele["1"]/(allele["0"]+allele["1"])
    except:
        # all miss site should be filterd before run script 
        frqsnp = 0.0
    
    return frqsnp
#
#==========================================================
def dealwindow():
    
    global abba

    if len(abba) == 0:
        return

    abbadiff = 0
    abbasum = 0
    
    for k,v in abba.items():
        abbadiff += v[0]
        abbasum += v[1]

    try:
        dstat = abbadiff/abbasum
    except:
        dstat = 0
    
    D_jacked.append(dstat)

    abba.clear()

#
#==========================================================
def main():

    pop1_index = indexpop(pop1)
    pop2_index = indexpop(pop2)
    pop3_index = indexpop(pop3)
    outgrp_index = indexpop(outgroup)

    win_tmp = window
    pre_chrom = ""
    ABBAdiff = 0.0
    ABBAsum = 0.0

    with open(vcf) as VCF:
        for line in VCF:
            line = line.strip()
            if line.startswith("#"):
                continue
            lines = line.split("\t")
            chrom,pos = lines[:2]
            pos = int(pos)

            p1_gt = [lines[i] for i in pop1_index]
            p2_gt = [lines[i] for i in pop2_index]
            p3_gt = [lines[i] for i in pop3_index]
            ogrp_gt = [lines[i] for i in outgrp_index]

            p1 = calc(p1_gt)
            p2 = calc(p2_gt)
            p3 = calc(p3_gt)
            ogrp = calc(ogrp_gt)

            frq_abba = (1-p1)*p2*p3*(1-ogrp)
            frq_baba = p1*(1-p2)*(1-p3)*ogrp

            ABBAdiff += (frq_abba-frq_baba)
            ABBAsum  += (frq_abba+frq_baba)
            
            if chrom != pre_chrom:
                dealwindow()
                pre_chrom = chrom
                win_tmp = window
            elif pos > win_tmp:
                dealwindow()
                win_tmp += window
            
            key = "{}_{}".format(chrom,pos)
            abba[key] = [frq_abba-frq_baba,frq_abba+frq_baba]        
            
            #print(chrom,pre_chrom)
            #print(pos,win_tmp)

    dealwindow()

    D_stat = ABBAdiff/ABBAsum

    return D_stat


#
#==========================================================
if __name__ == '__main__':
    D_stat = main()
    statistic = jackknife.jackknife(D_stat,D_jacked)
    p,z,stderr = statistic.pvalue()
    print("D: {}\tstd-err: {}\tZ: {}\tP: {}".format(D_stat,stderr,z,p))