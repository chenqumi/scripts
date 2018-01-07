#chenqumi@20171130
#! /usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import division
import sys,os,re
import json
import argparse

# Args parse
#==========================================================
parser = argparse.ArgumentParser(description =
    "Generate config for snpcalling pipe in snakemake")

parser.add_argument("-r", dest="ref", required=True,
                    help="reference genome")

parser.add_argument("-l", dest="fq_lst",
                    type=str, required=True,
                    help="fq.lst,format: sam sam_R1.fq.gz")

parser.add_argument("-p", dest="pseudochr_num",
                    type=int, required=True,
                    help="pseudochrom number")

parser.add_argument("-b", dest="blocks", type=int,
                    help="split ref into blocks")

parser.add_argument("-t", dest="tool", default="GATK",
                    help="use [SAM|GATK] to call snp,default=GATK")

args = parser.parse_args()
ref = args.ref
fq_lst = args.fq_lst
pseudochr_num = args.pseudochr_num
blocks = args.blocks
tool = args.tool

# software
#==========================================================
BCFTOOLS = "/lustre/project/og04/shichunwei/biosoft/bcftools-1.3/bcftools"
BWA = "/lustre/project/og04/shichunwei/biosoft/bwa-0.7.13/bwa"
GATK = "/p299/user/og03/chenquan1609/Bin/GATK_v3.8/GenomeAnalysisTK.jar"
ITOOLS = "/p299/user/og06/pipe/pub/baozhigui/biosoft/iTools_Code/iTools"
JAVA = "/p299/user/og07/baozhigui/reseq/biosoft/jre1.8.0_101/bin/java"
PICARD = "/p299/user/og06/pipe/pub/baozhigui/biosoft/picard-2.8.0/picard.jar"
SAMTOOLS = "/lustre/project/og04/shichunwei/biosoft/samtools-1.3/samtools"
SPLIT = "perl /p299/user/og03/chenquan1609/Resequencing/script/GATK2/split.pl"
COMBINEVCF = "python /p299/user/og03/chenquan1609/Resequencing/script/GATK2/CombineVCF.py"
BWASTAT = "perl /p299/user/og07/shichunwei/project/temp/snakemake/test/snakemake_rules/bin/bwa_stat.pl";
SNAKE = "/nfs2/pipe/Re/Software/bin/snakemake"
sam_rules = "/p299/user/og03/chenquan1609/Resequencing/script/GATK2/sam.call.rules"
gatk_rules = "/p299/user/og03/chenquan1609/Resequencing/script/GATK2/gatk.call.rules"
fq2realign = "/p299/user/og03/chenquan1609/Resequencing/script/GATK2/fq2realinbam.rules"
# mkdir & link
#==========================================================
#cwd = os.getcwd()
try:
    os.mkdir("rules")
except Exception as e:
    pass

rules = ""
if tool == "SAM":
    rules = sam_rules
elif tool == "GATK":
    rules = gatk_rules
else :
    rules = gatk_rules
    print("Maybe misspell TOOL param, GATK will be set !")

cp = "cp {} {} ./rules/".format(fq2realign,rules)
os.system(cp)

try:
    os.mkdir("Data")
except Exception as e:
    pass

try:
    os.mkdir("Data/Clean")
except Exception as e:
    pass

try:
    os.mkdir("Reference")
except Exception as e:
    pass

ref = os.path.abspath(ref)
cmd = "ln -s {} Reference/ref.fa".format(ref)
try:
    os.system(cmd)
except Exception as e:
    pass

# sample & fastq parse
#==========================================================
samples = []
with open(fq_lst) as lst_fd:
    for line in lst_fd:
        ln1 = line.strip()
        ln2 = lst_fd.next().strip()

        sample,rd1 = ln1.split()
        rd2 = ln2.split()[1]
        samples.append(sample)

        rd1 = os.path.abspath(rd1)
        rd2 = os.path.abspath(rd2)

        cmd1 = "ln -s {} Data/Clean/{}_R1.fastq.gz".format(rd1,sample)
        cmd2 = "ln -s {} Data/Clean/{}_R2.fastq.gz".format(rd2,sample)

        try:
            os.system(cmd1)
        except Exception as e:
            pass

        try:
            os.system(cmd2)
        except Exception as e:
            pass

# generate config file
#==========================================================
num = int((pseudochr_num+blocks-1)/blocks)
actual_block_num = int((pseudochr_num+num-1)/num)

biosoft = {
"bwa":BWA,"gatk":GATK,"itools":ITOOLS,"java":JAVA,
"picard":PICARD,"samtools":SAMTOOLS,"split":SPLIT,
"bwastat":BWASTAT,
"combinevcf":COMBINEVCF,"bcftools":BCFTOOLS
}

config = {
"biosoft":biosoft,
"pseudochrom_num":pseudochr_num,
"split_blocks_num":actual_block_num,
"samples":samples
}

data = json.dumps(config,sort_keys=True,indent=2)
with open("rules/snp.config.json","w") as out:
    out.write(data+"\n")

# generate work shell
#==========================================================
rule_name = os.path.basename(rules)
with open("snake_work.sh","w") as wk:
    sh = "{} -s ./rules/{} -T --stats ".format(SNAKE,rule_name)
    sh = sh + "./snakejob.$(date +%Y%m%d%H%M%S).stats "
    sh = sh + "-c 'qsub -cwd -S /bin/sh -q dna.q,rna.q,reseq.q,all.q "
    sh = sh + "-l vf={resources.qsub_vf}G,p={resources.qsub_p}' "
    sh = sh + "-j 40 -k 2>>./snakedetail.log.$(date +%Y%m%d%H%M%S)\n"
    wk.write(sh)

with open("snake_check.sh","w") as ck:
    sh = "{} -nrp -s ./rules/{}\n".format(SNAKE,rule_name)
    ck.write(sh)
