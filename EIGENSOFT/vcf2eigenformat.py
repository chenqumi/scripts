#chenqumi@20170825
#! /usr/bin/env python
# -*- coding: utf-8 -*-
import sys,os,re

if len(sys.argv) ==1:
    print("\nUsage: {} <vcf>".format(sys.argv[0]))
    sys.exit()

vcf = sys.argv[1]

#
# ============================================
#
def allele(geno):
    if geno == "0/0":
        return "0"
    elif geno == "0/1":
        return "1"
    elif geno == "1/1":
        return "2"
    else:
        return "9"

#
# ============================================
#
file = os.path.basename(vcf)
name = file[:file.rindex(".vcf")]
genofile = "{}.geno".format(name)
snpfile = "{}.snp".format(name)
indfile = "{}.ind".format(name)

GE = open(genofile,"w")
SNP = open(snpfile,"w")
IND = open(indfile,"w")
sample_info = []

with open(vcf) as VCF:
    for line in VCF:
        line = line.strip()
        if line.startswith("##"):
            continue
        if line.startswith("#CHROM"):
            sample_info = line.split("\t")[9:]
            continue
        # snp file
        chrom,pos,ref,alt = [line.split("\t")[i] for i in (0,1,3,4)]
        marker = "{}_{}".format(chrom,pos)
        m = re.match(r"NewChr(\d+)",chrom)
        chrom_num = m.group(1)
        # geno file
        genotype = line.split("\t")[9:]
        tmp = []
        for item in genotype:
            geno = item.split(":")[0]
            symbol = allele(geno)
            tmp.append(symbol)
        newline = "".join(tmp)

        SNP.write("{}\t{}\t0.0\t{}\t{}\t{}\n".format(marker,chrom_num,pos,ref,alt))
        GE.write(newline+"\n")
#
# ============================================       
for sample in sample_info:
    IND.write("{}\tU\tGP\n".format(sample))

GE.close()
SNP.close()
IND.close()
