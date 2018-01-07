#chenqumi@20170815
#! /usr/bin/env python
# -*- coding: utf-8 -*-
import sys,os,re

if len(sys.argv) != 3:
    print("\nUsage: {} I:<vcf> O:<hapmap>".format(sys.argv[0]))
    sys.exit()

vcf,hapmap = sys.argv[1:]

#
# ================================================
def judge(ref,alt,alle):

    if alle == "0":
        alle = ref
    elif alle == "1":
        alle = alt
    else:
        alle = "N"

    return alle

#
# =================================================
def alleles(ref,alt,gt):
    
    lst = []

    for i in gt:
        alle1,alle2 = i.split(":")[0].split("/")
        alle1 = judge(ref,alt,alle1)
        alle2 = judge(ref,alt,alle2)
        alle = alle1+alle2
        lst.append(alle)

    return lst
#
# ==================================================
head = [
   "rs","alleles","chrom","pos","strand","assembly",
   "center","protLSID","assayLSID","panel","QCcode" ]

HA = open(hapmap,"w")
with open(vcf) as VCF:
    index = 1
    for line in VCF:
        line = line.strip()
        
        if line.startswith("##"):
            continue
        
        if line.startswith("#CHROM"):
            samples = line.split("\t")[9:]
            for i in samples:
                head.append(i)
            header = "\t".join(head)
            HA.write(header+"\n")
            continue
        
        chrom,pos,ref,alt = [line.split("\t")[i] for i in (0,1,3,4)]
        gt = line.split("\t")[9:]
        num = len(gt)
        
        genotype = "\t".join(alleles(ref,alt,gt))
        
        HA.write("marker_{}\t{}/{}\t{}\t{}\t+\tNA\tonegene\tNA\tNA\tpanel{}\tNA\t{}\n".format(index,ref,alt,chrom,pos,num,genotype))
        
        index += 1
HA.close()

