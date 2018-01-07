#chenqumi@20170905
#! /usr/bin/env python
# -*- coding: utf-8 -*-
import sys,os,re

if len(sys.argv) ==1:
    print("\nUsage: {} <vcf>".format(sys.argv[0]))
    sys.exit()

vcf = sys.argv[1]

with open(vcf) as VCF:
    for line in VCF:
        if line.startswith("#CHROM"):
            line = line.strip()
            samples = line.split()[9:]
            for i in samples:
                print (i)
            break
