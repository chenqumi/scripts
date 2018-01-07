#chenqumi@20180105
#! /usr/bin/env python
# -*- coding: utf-8 -*-
import sys,os,re
from random import randint

atcg = {
    0:"A",
    1:"T",
    2:"C",
    3:"G"
}
seqnum = 10000

def GenSequence(seqlen):
    # seqlen = random.randint(200,500)
    # sequence = "".join([atcg[.randint(0,3)] for i in range(seqlen)])
    sequence = ""
    for i in range(seqlen):
        sequence += atcg[randint(0,3)]
    return sequence

def GenReads(sequence):
    rd1 = sequence[:150]
    rd2 = sequence[-150:][::-1]
    # qual = "?"*150
    qual1 = "".join([chr(randint(61,73)) for i in range(150)])
    qual2 = "".join([chr(randint(61,73)) for i in range(150)])
    return(rd1,rd2,qual1,qual2)

def main():
    R1 = open("R1.fastq","aw")
    R2 = open("R2.fastq","aw")
    for i in range(seqnum):
        seqlen = randint(200,500)
        seq = GenSequence(seqlen)
        rd1,rd2,qual1,qual2 = GenReads(seq)
        R1.write("@seq{} 1\n".format(i+1))
        R1.write(rd1+"\n")
        R1.write("+\n")
        R1.write(qual1+"\n")
        R2.write("@seq{} 2\n".format(i+1))
        R2.write(rd2+"\n")
        R2.write("+\n")
        R2.write(qual2+"\n")
    R1.close()
    R2.close()

if __name__ == '__main__':
    main()
