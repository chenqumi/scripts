#chenqumi@20171016
#! /usr/bin/env python
# -*- coding: utf-8 -*-
import sys,os,re

if len(sys.argv) == 1:
    print("\nUsage: {} <datafile> <mapfile> <number of LG> <iterate times>".format(sys.argv[0]))
    sys.exit()

data,mapfile,num,iterate = sys.argv[1:5]
data = os.path.abspath(data)
mapfile = os.path.abspath(mapfile)
num = int(num)
iterate = int(iterate)

cmd = "/lustre/project/og04/shichunwei/biosoft/jre1.8.0_91/bin/java -Xmx30G "
cmd = cmd + "-cp /p299/user/og03/chenquan1609/Bin/LepMap3/bin "
cmd = cmd + "OrderMarkers2"

for times in range(1,iterate+1):
    mkdir = "mkdir repeat{}".format(times)
    os.system(mkdir)
    for i in range(1,num+1):
        outfile = "repeat{}/order{}.sh".format(times,i)
        with open (outfile,"w") as output:
            shell = "{} data={} map={} chromosome={} sexAveraged=1 useKosambi=1 > order{}.txt 2> order{}.log\n".format(cmd,data,mapfile,i,i,i)
            output.write(shell)
