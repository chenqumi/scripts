#! /usr/bin/env python
# -*- coding: utf-8 -*-
import sys,os,re

if len(sys.argv) == 1:
    print("\nUsage: {} <fq.lst> ".format(sys.argv[0]))
    sys.exit()

lst = sys.argv[1]

OT = open("data.lst","w")
with open(lst) as LST:
    for line in LST:
        line = line.rstrip()
        rd = os.path.basename(line)
        #m = re.match(r"(\S+)\_R\d+\.fastq\.gz",rd)
        m = re.match(r"(\S+)\_H\w{8}\_",rd)
        lib = m.group(1)
        OT.write("{} {}\n".format(lib,line))
OT.close()