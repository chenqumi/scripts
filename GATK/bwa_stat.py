#chenqumi@20170808
#! /usr/bin/env python
# -*- coding: utf-8 -*-
import sys,os,re

if len(sys.argv) != 4:
    print("\nUsage: {} <samstat.lst> <itoolstat.lst> <out>".format(sys.argv[0]))
    sys.exit()

sam,itool,out = sys.argv[1:4]
STAT = "perl /p299/user/og07/shichunwei/project/temp/snakemake/test/snakemake_rules/bin/bwa_stat.pl"

def parse_stat(lst):
    
    statfile = []
    with open(lst) as LST:
        for line in LST:
            line = line.strip()
            statfile.append(line)
    files = " ".join(statfile)
    return files

def main():

    samfiles = parse_stat(sam)
    itoolfiles = parse_stat(itool)
    cmd = "{} {} {} {}\n".format(STAT,out,samfiles,itoolfiles)
    print (cmd)

if __name__ == '__main__':
    main()