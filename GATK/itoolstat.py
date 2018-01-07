#chenqumi@20170807
#! /usr/bin/env python
# -*- coding: utf-8 -*-
import sys,os,re

if len(sys.argv) ==1:
    print("\nUsage: {} <bam.lst> <ref>".format(sys.argv[0]))
    sys.exit()

bam_lst,ref = sys.argv[1:3]

ITOOLS = "/p299/user/og06/pipe/pub/baozhigui/biosoft/iTools_Code/iTools"
#ref = "/p299/user/og03/chenquan1609/Resequencing/KF-CQ-B1-20160505-01_honeybee/03.GVCF/20170619/Index/ref.fa"

with open(bam_lst) as BAM:
    for line in BAM:
        line = line.strip()
        sample = os.path.basename(line).split(".")[0]
        print ("{} Xamtools stat -InFile {} -Ref {} -OutStat {}.itools.stat -Bam".format(ITOOLS,line,ref,sample))