# GATK

## 更新日期  

2017/9/15

## GATK使用方法

```shell
# 1.对reference进行bwa index, samtools faidx, picard CreateSequenceDictionary
bwa index ref.fa

samtools faidx ref.fa 

java -jar picard.jar CreateSequenceDictionary R=ref.fa O=ref.dict

# 2.每对reads进行比对
bwa mem -M -t 8 -k 32 -R "@RG\tID:sample\tLB:sample\tSM:sample\tPL:ILLUMINA" \ 
ref.fa sample_R1.fq.gz sample_R2.fq.gz | samtools view -bS > sample.bam

# 3.每个bam进行sort
samtools sort sample.bam -o sample.sort.bam -O BAM

# 4.Mark duplicate并进行samtools index
java -jar picard.jar MarkDuplicates MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=4000 \
INPUT=sample.sort.bam OUTPUT=sample.sort.rmdup.bam METRICS_FILE=sample.metrics

samtools index sample.sort.rmdup.bam

# 5.Realign
java -jar GenomeAnalysisTK.jar -T RealignerTargetCreator -R ref.fa \
-I sample.sort.rmdup.bam -o sample.intervals

java -jar GenomeAnalysisTK.jar -T IndelRealigner -R ref.fa \
-I sample.sort.rmdup.bam -targetIntervals sample.intervals -o sample.realign.bam
# Realign 这一步可能会因为质量值的问题而报错，软件默认reads是33的质量值；如果是64，需要在realign的两步中加上 -fixMisencodedQuals

# 6.每个样品生成gvcf文件
java -jar GenomeAnalysisTK.jar -T HaplotypeCaller -R ref.fa \
-I sample.realign.bam -o sample.g.vcf -ERC GVCF
# 注意：结果文件似乎只能以*.g.vcf的形式命名，命名为*.gvcf都会报错

# 7.对所有样品call SNP和InDel
java -jar GenomeAnalysisTK.jar -T GenotypeGVCFs -R ref.fa \
-V sample1.g.vcf -V sample2.g.vcf ··· -V sampleN.g.vcf \
-o pop.vcf
```

## 设计说明

群体重测序样品很多，基本上数据也不会一次到齐，本流程希望通过在为每对reads命名时加上特定的字符来识别不同情况的数据，由此来决定该数据可以进行到哪一步。

```shell
# read的命名规则：

# 1.样品数据到齐，命名为name，最终得到.g.vcf文件
name /path/sample_R1.fq.gz
name /path/sample_R2.fq.gz

# 2.样品数据量不足，(仍)需要加测，命名为name_batch，最终得到bam文件，命名为*_batch.bam
# batch是该种数据的关键字
name_batch /path/sample_R1.fq.gz
name_batch /path/sample_R2.fq.gz

# 3.本样品是加测的样品，加上之前的数据，达到数据量要求，命名为name_batchN，和之前的bam文件合并，得到.g.vcf文件
# batchN是该种数据的关键字
name_batchN /path/sample_R1.fq.gz
name_batchN /path/sample_R2.fq.gz
```

## 流程使用

```shell
# 路径：/p299/user/og03/chenquan1609/Resequencing/script/GATK

GATK version: 3.8

perl GATK_pipe.pl <ref.fa> <fq.lst>
    
    -nosplit:     Don't split read
    -bamlst|bam:  bam files in former pipe, one bam per line
     
fq.lst format:
    SAM_1 /path/sample1_R1.fq.gz
    SAM_1 /path/sample1_R1.fq.gz
    SAM_2_batch /path/sample2_R1.fq.gz
    SAM_2_batch /path/sample2_R2.fq.gz
    SAM_3_batchN /path/sample3_R1.fq.gz
    SAM_3_batchN /path/sample3_R2.fq.gz
    SAM_4_batch /path/sample4_R1.fq.gz
    SAM_4_batch /path/sample4_R2.fq.gz
    
batch_bam.lst format:
   SAM_2_batch.bam
   SAM_3_batch.bam

# 根据示例中fq.lst和batch.lst文件，可知：
SAM_1样品数据量合格，可以得到SAM_1.g.vcf文件
SAM_2是加测的样品，但数据量仍不够，会和SAM_2_batch.bam合并最终得到一份新的SAM_2_batch.bam
SAM_3加测后数据量合格，会和SAM_3_batch.bam合并得到SAM_3.g.vcf文件
SAM_4是新到的数据，数据量不足，需要加测，会得到SAM_4_batch.bam

# 最后，使用所有g.vcf文件得到最终的vcf文件
perl gvcf2vcf.pl I:<ref.fa> <gvcf.lst> O:<out>
```





 