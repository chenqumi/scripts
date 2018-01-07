/lustre/project/og04/shichunwei/biosoft/bcftools-1.3/bcftools filter -G 5 -g 5 -O v -o pop.clean.vcf -s LOWQUAL -i '%QUAL>=40 && MQ >=20 && DP >=60 && DP <= 2000 && MAF[0] > 0.01' ../pop.vcf && 
perl -lane 'if (=~/^#/){print;}elsif(( eq PASS) and (/INDEL/)) {print;}' pop.clean.vcf > pop.clean.indel.vcf &&
grep -v INDEL pop.clean.vcf | grep -E "PASS|#" > pop.clean.snp.vcf &&
date &&
echo done
