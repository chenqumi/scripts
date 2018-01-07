#chenqumi@20171019
#! /usr/bin/env python
# -*- coding: utf-8 -*-
import sys,os,re

if len(sys.argv) != 3:
    print("\nUsage: {} <map.txt> <data.call>".format(sys.argv[0]))
    sys.exit()

mapfile,data = sys.argv[1:3]

#
# ==============================================================
grp = []
with open (mapfile) as map_fd:
        
    for line in map_fd:
        line = line.strip()
        if line.startswith("#"):
            continue
        grp.append(line)

dic = {}
with open(data) as dt_fd:
    index = 0
    for line in dt_fd:
        line = line.strip()
        if line.startswith("#"):
            continue
        elif line.startswith("CHR"):
            continue

        chrom,pos = line.split("\t")[:2]
        marker = "{}_{}".format(chrom,pos)
        lg = grp[index]
        dic.setdefault(lg,[]).append(marker)

        index += 1

# Output marker number in each LG
dic_sort = sorted(dic.items(),key=lambda d:int(d[0]))

total_marker_num = 0
for item in dic_sort:

    marker_num = len(item[1])
    print ("LG{}:\t{}".format(item[0],marker_num))

    if item[0] != "0":
        total_marker_num += marker_num

print ("Total mapped marker:\t{}".format(total_marker_num))

# Output marker in each LG
for k,v in dic.items():
    outfile = "LG{}.txt".format(k)
    ot_fd = open(outfile,"w")
    for i in v:
        ot_fd.write(i+"\n")
    ot_fd.close()