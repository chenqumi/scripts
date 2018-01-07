#! /usr/bin/env python
# -*- coding: utf-8 -*-
import sys,os,re

if len(sys.argv) == 1:
	print("\nUsage: {} <fq.lst> <out.lst>".format(sys.argv[0]))
	sys.exit()

lst,out = sys.argv[1:3]

OT = open(out,"w")
with open(lst) as LST:
	for line in LST:
		line = line.rstrip()
		rd = os.path.basename(line)
		print(rd)
		m = re.match(r"(\S+)\_R\d+\.fastq\.gz",rd)
		lib = m.group(1)
		OT.write("{} {}\n".format(lib,line))
OT.close()