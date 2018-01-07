#chenqumi@20171016
#! /usr/bin/env python
# -*- coding: utf-8 -*-
import sys,os,re

if len(sys.argv) == 1:
    print("\nUsage: {} <datafile> <mapfile> <number of LG>".format(sys.argv[0]))
    sys.exit()

data,mapfile,num = sys.argv[1:4]
num = int(num)

cmd = "/lustre/project/og04/shichunwei/biosoft/jre1.8.0_91/bin/java -Xmx30G "
cmd = cmd + "-cp /p299/user/og03/chenquan1609/Bin/LepMap3/bin "
cmd = cmd + "OrderMarkers2"

for i in range(1,num+1):
    outfile = "order{}.sh".format(i)
    with open (outfile,"w") as output:
        shell = "{} data={} map={} chromosome={} sexAveraged=1 useKosambi=1 > order{}.txt 2> order{}.log\n".format(cmd,data,mapfile,i,i,i)
        output.write(shell)
