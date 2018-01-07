#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sys,re,os

if len(sys.argv) == 1:
	print("\nUsage: {} I:<gff> O:<gene.info>".format(sys.argv[0]))
	sys.exit()

gff,info = sys.argv[1:]

GFF = open(gff)
INFO = open(info,"w")

for line in GFF:
	if line.startswith("#"): continue
	line = line.rstrip()
	scaff = line.split("\t")[0]
	type1,start,end = line.split("\t")[2:5]
	name = line.split("\t")[8]
	gene = re.match(r"\S+Target=(\S+)\s+\S+",name).group(1)
	#out = gene+"\t"+gene+"\t"+scaff+"\t"+type1+"\t"+start+"\t"+end+"\n"
	out = "{}\t{}\t{}\t{}\t{}\t{}\n".format(gene,gene,scaff,type1,start,end)
	INFO.write(out)

GFF.close()
INFO.close()