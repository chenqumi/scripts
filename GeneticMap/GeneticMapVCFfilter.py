#chenqumi@20171013
#! /usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import division
from scipy import stats
import sys,os,re

if len(sys.argv) != 5:
    print("\nUsage: {} <vcf> <min_dp> <missing_rate> <P_threshold>".format(sys.argv[0]))
    sys.exit()

vcf,min_dp,missing_rate,P_threshold = sys.argv[1:5]
min_dp = int(min_dp)
missing_rate = float(missing_rate)
P_threshold = float(P_threshold)
#
# ======================================
def format_dp(sam):
    dp = int(sam.split(":")[1])
    #if dp < min_dp:
    if dp <= min_dp:
        sam = "./.:0:.,.:.,.,."
    gt = sam.split(":")[0]
    return sam,gt

#
# =======================================
def segregation(gt_m,gt_f):
    gamete_m = gt_m.split("/")
    gamete_f = gt_f.split("/")
    ratio = {}
    for m in gamete_m:
        for f in gamete_f:
            zygote = "{}/{}".format(m,f)
            if zygote == "1/0":
                zygote = "0/1"
            ratio[zygote] = ratio.get(zygote,0) + 0.25
    return ratio

#
# ========================================
def check_offspring(gt_m,gt_f,off):
    ratio = segregation(gt_m,gt_f)
    if not ratio.get(off.split(":")[0]):
        off = "./.:0:.,.:.,.,."
    off_gt = off.split(":")[0]

    return off,off_gt

#
# ========================================
def calc_exp(gt_m,gt_f,off_num):
    ratio = segregation(gt_m,gt_f)
    off_num = int(off_num)
    exp_00 = ratio.get("0/0",0)*off_num
    exp_01 = ratio.get("0/1",0)*off_num
    exp_11 = ratio.get("1/1",0)*off_num

    return exp_00,exp_01,exp_11
#
# ========================================

output = open("result.vcf","w")
with open(vcf) as fd:
    for line in fd:
        line = line.strip()
        if line.startswith("#"):
            output.write(line+"\n")
            continue
        lines = line.split("\t")
        tmp = lines[:9]
        mother = lines[-2]
        father = lines[-1]
        mother,gt_m = format_dp(mother)
        father,gt_f = format_dp(father)
        
        # filter Parent genotype
        if gt_m == "./.":
            continue
        elif gt_f == "./.":
            continue
        elif gt_m == "0/0" and gt_f == "0/0":
            continue
        elif gt_m == "1/1" and gt_f == "1/1":
            continue

        # set offspring as miss type
        count = {}
        offsprings = lines[9:409]
        off_num = len(offsprings)
        sam_num = off_num + 2

        for off in offsprings:
            off,off_gt = format_dp(off)
            off,off_gt = check_offspring(gt_m,gt_f,off)
            tmp.append(off)
            count[off_gt] = count.get(off_gt,0) + 1

        num_00 = count.get("0/0",0)
        num_01 = count.get("0/1",0)
        num_11 = count.get("1/1",0)
        num_miss = count.get("./.",0)

        # filter max-missing
        #if num_miss/off_num > missing_rate:
        if num_miss/sam_num > missing_rate:
            continue

        # chi-square test
        effect_off_num = off_num - num_miss
        exp_00,exp_01,exp_11 = calc_exp(gt_m,gt_f,effect_off_num)

        obs_tmp = [num_00,num_01,num_11]
        exp_tmp = [exp_00,exp_01,exp_11]
        non_zero = [i for i in range(3) if exp_tmp[i] != 0]
        exp = [exp_tmp[i] for i in non_zero]
        obs = [obs_tmp[i] for i in non_zero]

        chi,pvalue = stats.chisquare(obs,f_exp=exp)
        
        if pvalue > P_threshold:
            tmp.append(mother)
            tmp.append(father)
            newline = "\t".join(tmp)
            output.write(newline+"\n")

output.close()