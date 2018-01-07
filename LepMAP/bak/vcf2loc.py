#chenqumi@20171124
#! /usr/bin/env python
# -*- coding: utf-8 -*-
import sys,os,re

if len(sys.argv) ==1:
    print("\nUsage: {} <vcf> <paternal ID> <maternal ID>".format(sys.argv[0]))
    sys.exit()

vcf,paternal,maternal = sys.argv[1:4]


#
# ======================================
def parse_line(line,index_f,index_m):

    lines = line.split("\t")
    
    chrom,pos = lines[:2]
    marker = "{}_{}".format(chrom,pos)

    father = lines.pop(index_f).split(":")[0]
    mother = lines.pop(index_m).split(":")[0]
    offsprings = lines[9:]

    genotype = {}
    genotype["./."] = "--"
    phasetype = ""
    
    if father == "0/1" and mother == "0/1":
        genotype["0/1"] = "hk"
        genotype["0/0"] = "hh"
        genotype["1/1"] = "kk"
        phasetype = "{00}"
    elif father == "0/1" and mother != "0/1":
        genotype["0/1"] = "lm"
        genotype["0/0"] = "ll"
        genotype["1/1"] = "ll"
        phasetype = "{0-}"
    elif mother == "0/1" and father != "0/1":
        genotype["0/1"] = "np"
        genotype["0/0"] = "nn"
        genotype["1/1"] = "nn"
        phasetype = "{-0}"

    gt_f = genotype[father]
    gt_m = genotype[mother]
    markertype = "<{}x{}>".format(gt_f,gt_m)

    tmp = []
    for off in offsprings:
        gt = off.split(":")[0]
        loc = genotype[gt]
        tmp.append(loc)
    
    #tmp.insert(0,phasetype)
    tmp.insert(0,markertype)
    tmp.insert(0,marker)
    
    newline = "\t".join(tmp)
    return newline
    #return marker,markertype,newline
#
# ======================================

with open(vcf) as fd:
    
    index_f = 0
    index_m = 0

    for line in fd:
        line = line.strip()
        if line.startswith("#"):
            
            if line.startswith("#CHROM"):
                lines = line.split("\t")
                index_f = lines.index(paternal)
                index_m = lines.index(maternal)

            continue
        
        #marker,markertype,newline = parse_line(line,index_f,index_m)
        newline = parse_line(line,index_f,index_m)
        #print("{}\t{}".format(marker,markertype))
        print(newline)


