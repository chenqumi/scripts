#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sys,os

if len(sys.argv) == 1:
	print("\nUsage: {} <ref.fa> <vcf>".format(sys.argv[0]))
	sys.exit()

ref,vcf = sys.argv[1:]
ref = os.path.abspath(ref)
vcf = os.path.abspath(vcf)

BGZIP = "/nfs2/biosoft/bin/bgzip"
TABIX = "/nfs2/biosoft/bin/tabix"
BCF = "/lustre/project/og04/shichunwei/biosoft/bcftools-1.3/bcftools"

# Sample info
#=========================================
with open(vcf) as VCF:
	for line in VCF:
		if line.startswith("##"):continue
		if line.startswith("#CHROM"):
			line = line.rstrip()
			samples = line.split("\t")[9:]
			break

# Write script
#=========================================
SH = open("consensus.sh","w")
SH.write("{} {}\n".format(BGZIP,vcf))
SH.write("{} {}.gz\n".format(TABIX,vcf))
for x in samples:
	shell = "{} consensus -f {} -s {} {}.gz | gzip > s{}.fa.gz\n".format(BCF,ref,x,vcf,x)
	SH.write(shell)
SH.write("gunzip {}.gz\n".format(vcf))
SH.close()
