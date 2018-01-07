#chenqumi@20170807
#! /usr/bin/env python
# -*- coding: utf-8 -*-
import sys,os,re

if len(sys.argv) ==1:
    print("\nUsage: {} <>".format(sys.argv[0]))
    sys.exit()

bam_lst = sys.argv[1]

SAMTOOLS = "/lustre/project/og04/shichunwei/biosoft/samtools-1.3/samtools"

with open(bam_lst) as BAM:
    for line in BAM:
        line = line.strip()
        sample = os.path.basename(line).split(".")[0]
        print ("{} flagstat {} > {}.samtools.stat".format(SAMTOOLS,line,sample))