#chenqumi@20171016
#! /usr/bin/env python
# -*- coding: utf-8 -*-
import sys,os,re

if len(sys.argv) != 5:
    print("\nUsage: {} <data.call> <lod1> <lod2> <sizelimit>".format(sys.argv[0]))
    sys.exit()

dtfile,lod1,lod2,size = sys.argv[1:5]
lod1 = int(lod1)
lod2 = int(lod2)

cmd = "/lustre/project/og04/shichunwei/biosoft/jre1.8.0_91/bin/java "
cmd = cmd + "-cp /p299/user/og03/chenquan1609/Bin/LepMap3/bin "
cmd = cmd + "SeparateChromosomes2 data={}".format(dtfile)

for lod in range(lod1,lod2+1):
    outfile = "sc{}.sh".format(lod)
    with open (outfile,"w") as output:
        shell = "{} lodLimit={} lod3Mode=3 sizeLimit={} > map{}.txt 2> sc{}.log\n".format(cmd,lod,size,lod,lod)
        output.write(shell)