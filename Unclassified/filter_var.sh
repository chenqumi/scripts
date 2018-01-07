/lustre/project/og04/shichunwei/biosoft/bcftools-1.3/bcftools filter -G 5 -g 5 -O v -o pop.clean.vcf -s LOWQUAL -i '%QUAL>=20 && MQ >=20 && DP >=5 && (DP4[2]+DP4[3] >= 2)' pop.vcf &&
perl -lane 'if ($F[0]=~/^#/){print;}elsif(($F[6] eq "PASS") and (/INDEL/)) {print;}' pop.clean.vcf > pop.clean.indel.vcf &&
grep -v INDEL pop.clean.vcf | grep -E "PASS|#" > pop.clean.snp.vcf &&
date &&
echo done
