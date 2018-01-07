python /p299/user/og03/chenquan1609/Resequencing/script/EIGENSOFT/vcf2eigenformat.py /p299/user/og03/chenquan1609/Resequencing/Buckwheat/Cut32samples/01.filter/bw168.recode.vcf
export EIGEN="/p299/user/og03/chenquan1609/Bin/EIGENSOFT/EIG-6.1.4/bin/"
export PATH=$EIGEN:$PATH
perl /p299/user/og03/chenquan1609/Bin/EIGENSOFT/EIG-6.1.4/bin//smartpca.perl -i bw168.recode.geno -a bw168.recode.snp -b bw168.recode.ind -k 10 -o pca -p result.plot -e pca.eval -l result.log
