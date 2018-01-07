#chenqumi@20171130
#! /usr/bin/env python
# -*- coding: utf-8 -*-
import sys,os,re

if len(sys.argv) != 3:
    print("\nUsage: {} <ref.fa> <pseudochrom_vcf.lst>".format(sys.argv[0]))
    sys.exit()

ref,lst = sys.argv[1:3]

ref = os.path.abspath(ref)
tmp = []
chrom_info = ""
#
# ====================================
with open(lst) as lst_fd:

    for line in lst_fd:
        line = line.strip()
        line = os.path.abspath(line)

        with open(line) as fd:
            for i in fd:
                i = i.strip()
                if i.startswith("##contig"):
                    tmp.append(i)
                elif i.startswith("#CHROM"):
                    chrom_info = i
                    break
                else:
                    continue
#
# ====================================
with open(lst) as lst_fd:

    for line in lst_fd:
        line = line.strip()
        line = os.path.abspath(line)

        with open(line) as fd:
            for i in fd:
                i = i.strip()
                if i.startswith("##"):
                    if i.startswith("##contig"):
                        continue
                    elif i.startswith("##reference"):
                        continue
                    print(i)
                elif i.startswith("#CHROM"):
                    break
                else:
                    continue
        break
#
# ====================================
for conitg in tmp:
    print(conitg)
print("##reference=file://{0}".format(ref))
print(chrom_info)
#
# ====================================
with open(lst) as lst_fd:

    for line in lst_fd:
        line = line.strip()
        line = os.path.abspath(line)

        with open(line) as fd:
            for i in fd:
                i = i.strip()
                if i.startswith("#"):
                    continue
                print(i)
