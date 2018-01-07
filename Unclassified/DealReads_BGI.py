#chenqumi@20171020
#! /usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import division
import sys,os,re
import gzip
import math
import argparse

#
# ==================================
parser = argparse.ArgumentParser(description=
    "Filter reads and Joint MaxLenTagTag")
parser.add_argument("-r1",dest="read1",required=True,
    help="input read1")
parser.add_argument("-r2",dest="read2",required=True,
    help="input read2")
parser.add_argument("-w",dest="window",type=int,default=50,
    help="window size when stat qual [50]")
parser.add_argument("-c",dest="cut_ratio",type=float,default=0.3,
    help="cut ratio threshold [0.3]")
parser.add_argument("-n",dest="N_ratio",type=float,default=0.1,
    help="N ratio threshold [0.1]")
parser.add_argument("-match",dest="min_match",type=int,default=50,
    help="minimum match number [50]")
parser.add_argument("-mr",dest="mismatch_ratio",type=float,default=0.1,
    help="max mismatch ratio [0.1]")

args = parser.parse_args()
read1 = args.read1
read2 = args.read2
window = args.window
cut_ratio = args.cut_ratio
N_ratio = args.N_ratio
min_match = args.min_match
mismatch_ratio = args.mismatch_ratio
#
# ==================================
def FilterLowQual(qual,seq_length,phred=33):
    
    index = seq_length
    times = int(seq_length/window) + 1
    qual_r = qual[::-1]
    
    for i in range(times):
        
        start = window * i
        end = start + window
        sum_qual = 0
        
        for base_qual in qual_r[start:end]:
            base_qual = ord(base_qual) - phred
            sum_qual += base_qual
        
        mean_qual = sum_qual/window

        if mean_qual < 20:
            index = seq_length - window*(i+1)

    qual_filter_len = len(qual[:index])

    return qual_filter_len,index
    
#
# ==================================
def FilterN(seq):

    count = 0
    
    for base in seq:
        if base == "N" or base == "n":
            count += 1
    seqNratio = count/len(seq)

    if seqNratio > N_ratio:
        return 1
    else :
        return 0    
#
# ==================================
def MaxMatchTag(seq1,seq2,qual1,qual2,id1,id2):
    # seq  ATGCACATG
    # rd1  ATGCACAT
    # rd2  GTACA
    #      ACATG 
    # reverse rd2
    seq2_r = seq2[::-1]
    qual2_r = qual2[::-1]
    #marker = seq2_r[:min_match]
    max_mismatch_num = int(mismatch_ratio * min_match)
    seq1_len = len(seq1)
    seq2_len = len(seq2)
    #min_seq_len = min(seq1_len,seq2_len)
    
    seq1_tmp_len = seq1_len
    #reads_num = 0
    tag_num = 0
    fq_hd = open("MaxMatchTag.fastq","aw")
    fa_hd = open("MaxMatchTag.fasta","aw")
    for step in range(seq1_len-min_match+1):
        
        seq1_tmp_len -= 1
        if seq2_len < seq1_tmp_len:
            continue

        min_seq_len = min(seq1_tmp_len,seq2_len)

        mismatch_num = 0
        for i in range(min_seq_len):
        #for i in range(seq1_tmp_len):    

            if seq1[step+i] != seq2_r[i]:
                mismatch_num += 1

            if mismatch_num > max_mismatch_num:
                break
        
        if mismatch_num > max_mismatch_num:
            continue
        else:
            # Combine Reads to Tag
            tag_num = 1
            tag1 = seq1[:step]
            tag1_qual = qual1[:step]
            #tag2 = overlap
            seq1_match = seq1[step:step+min_seq_len]
            seq2_match = seq2_r[:min_seq_len]
            qual1_match = qual1[step:step+min_seq_len]
            qual2_match = qual2_r[:min_seq_len]
            tag2= ""
            tag2_qual = ""
            for base in range(len(seq1_match)):
                if ord(qual1_match[base]) >= ord(qual2_match[base]):
                    tag2 += seq1_match[base]
                    tag2_qual += qual1_match[base]
                else :
                    tag2 += seq2_match[base]
                    tag2_qual += qual2_match[base]

            tag3 = seq2_r[min_seq_len:]
            tag3_qual = qual2_r[min_seq_len:]
            
            tag = tag1 + tag2 + tag3
            tag_qual = tag1_qual + tag2_qual + tag3_qual
            
            #with open("Tag.fastq","w") as fq_hd,open("Tag.fasta","w") as fa_hd:
            fq_hd.write("@{}\n".format(id1))
            fq_hd.write(tag+"\n")
            fq_hd.write("+\n")
            fq_hd.write(tag_qual+"\n")
            fa_hd.write(">{}\n".format(id1))
            fa_hd.write(tag+"\n")

    fq_hd.close()
    fa_hd.close()
    return tag_num

#
# ==================================
def MaxLenTag(seq1,seq2,qual1,qual2,id1,id2):
    seq2_r = seq2[::-1]
    qual2_r = qual2[::-1]
    #marker = seq2_r[:min_match]
    max_mismatch_num = int(mismatch_ratio * min_match)
    seq1_len = len(seq1)
    seq2_len = len(seq2)

    mismatch_num = 0
    tag_num = 0
    tag_len = -1

    #if seq1_len < min_match :
    #    sys.exit("wrong")

    match_len = min_match

    fq_hd = open("MaxLenTag.fastq","aw")
    fa_hd = open("MaxLenTag.fasta","aw")

    min_seq_len = min(seq1_len,seq2_len) # max step!!!
    for step in range(min_seq_len-min_match + 1):

        for i in range(match_len):
            
            if seq1[seq1_len-match_len+i] != seq2_r[i]:
                mismatch_num += 1
            if mismatch_num > max_mismatch_num:
                break

        if mismatch_num > max_mismatch_num:
            match_len += 1
            continue
        else :
            tag_num = 1

            tag1 = seq1[:seq1_len-match_len]
            tag1_qual = qual1[:seq1_len-match_len]
            #tag2 = overlap
            seq1_match = seq1[seq1_len-match_len:]
            qual1_match = qual1[seq1_len-match_len:]
            seq2_match = seq2_r[:match_len]
            qual2_match = qual2_r[:match_len]
            tag2= ""
            tag2_qual = ""
            for base in range(len(seq1_match)):
                if ord(qual1_match[base]) >= ord(qual2_match[base]):
                    tag2 += seq1_match[base]
                    tag2_qual += qual1_match[base]
                else :
                    tag2 += seq2_match[base]
                    tag2_qual += qual2_match[base]

            tag3 = seq2_r[match_len:]
            tag3_qual = qual2_r[match_len:]
            
            tag = tag1 + tag2 + tag3
            tag_qual = tag1_qual + tag2_qual + tag3_qual
            tag_len = len(tag)
            
            fq_hd.write("@{}\n".format(id1))
            fq_hd.write(tag+"\n")
            fq_hd.write("+\n")
            fq_hd.write(tag_qual+"\n")
            fa_hd.write(">{}\n".format(id1))
            fa_hd.write(tag+"\n")
            
            match_len += 1
            
            break

    fq_hd.close()
    fa_hd.close()

    return tag_num,tag_len
#
# ==================================
def TagLengthStat(lst):

    mean = sum(lst)/len(lst)
    variance = 0
    
    for i in lst:
        variance += (i-mean)**2

    variance = variance/len(lst)
    std = math.sqrt(variance)

    return mean,std
#
# ==================================
def OpenFile(fastq):
    
    if fastq.endswith(".gz"):
        fastq_fd = gzip.open(fastq)
    else :
        fastq_fd = open(fastq)

    return fastq_fd
#
# ==================================
def main():
    
    rd1_fd = OpenFile(read1)
    rd2_fd = OpenFile(read2)
    
    reads_num = 0
    tag_num = 0
    tag_lst = []
    #tag_len_fd = open ("TagLengthStat.txt","w")
    
    for line in rd1_fd:
        
        reads_num += 1
        # read1
        head1 = line.strip()
        rd1_id = head1.split("@")[1]
        seq1 = rd1_fd.next().strip()
        rd1_fd.next().strip()
        qual1 = rd1_fd.next().strip()
        seq1_length = len(seq1)
        
        # read2
        head2 = rd2_fd.readline().strip()
        rd2_id = head2.split("@")[1]
        seq2 = rd2_fd.readline().strip()
        rd2_fd.readline()
        qual2 = rd2_fd.readline().strip()
        seq2_length = len(seq2)
        
        # Filter low qual
        qual_filter_len1,index1 = FilterLowQual(qual1,seq1_length)
        qual_filter_len2,index2 = FilterLowQual(qual2,seq2_length)
        len_ratio1 = qual_filter_len1/seq1_length
        len_ratio2 = qual_filter_len2/seq2_length

        if len_ratio1 < cut_ratio or len_ratio2 < cut_ratio:
            continue

        seq1_filterlow = seq1[:index1]
        qual1_filterlow = qual1[:index1]
        seq2_filterlow = seq2[:index2]
        qual2_filterlow = qual2[:index2]
        
        # Filter N
        if FilterN(seq1_filterlow) == 1 or FilterN(seq2_filterlow) == 1:
            continue

        # Tag
        if len(seq1_filterlow) < min_match or len(seq2_filterlow) < min_match:
            continue

        combinetag,tag_len = MaxLenTag(seq1_filterlow,seq2_filterlow,
                             qual1_filterlow,qual2_filterlow,rd1_id,rd2_id)
        
        if combinetag == 0:
            combinetag,tag_len = MaxLenTag(seq2_filterlow,seq1_filterlow,
                                 qual2_filterlow,qual1_filterlow,rd2_id,rd1_id)
        
        tag_num += combinetag
        
        if tag_len != -1:
            #tag_len_fd.write(tag_len+"\n")
            tag_lst.append(tag_len)


    rd1_fd.close()
    rd2_fd.close()
    tag_ratio = tag_num/reads_num
    print ("Read number\t{}".format(reads_num))
    print ("Tag number\t{}".format(tag_num))
    print ("Tag ratio\t{}".format(tag_ratio))

    # Tag stat
    tag_len_fd = open ("TagLengthStat.txt","w")
    mean,std = TagLengthStat(tag_lst)
    
    for i in tag_lst:
        tag_len_fd.write(str(i)+"\n")
    
    tag_len_fd.write("mean\t{}\n".format(mean))
    tag_len_fd.write("std\t{}\n".format(std))
    tag_len_fd.close()
#
# ==================================
if __name__ == '__main__':
    main()
