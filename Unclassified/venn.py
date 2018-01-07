#chenqumi@20171013
#! /usr/bin/env python
# -*- coding: utf-8 -*-
import sys,os,re

if len(sys.argv) != 3:
    print("\nUsage: {} <file1> <file2>".format(sys.argv[0]))
    sys.exit()

file1,file2 = sys.argv[1:3]

def MakeSet(file):

    tmp = []
    with open(file) as fd:
        for line in fd:
            line = line.strip()
            tmp.append(line)
    set_f = set(tmp)
    return set_f

set1 = MakeSet(file1)
set2 = MakeSet(file2)


common = set1 & set2

uniq1 = [i for i in set1 if i not in common]
uniq2 = [i for i in set2 if i not in common]

with open("common","w") as co_fd:
    for i in common:
        co_fd.write(i+"\n")

with open("uniq_file1","w") as u1_fd:
    for i in uniq1:
        u1_fd.write(i+"\n")

with open("uniq_file2","w") as u2_fd:
    for i in uniq2:
        u2_fd.write(i+"\n")