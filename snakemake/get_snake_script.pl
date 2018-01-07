use warnings;
use strict;
use Cwd qw(abs_path getcwd);

my ($dir_list,$ref) = @ARGV;
die "perl <dir_list_rawdata> <ref.fa>" if @ARGV==0;

# Software & dir
#=================================
#
my $SNAKE = "/nfs2/pipe/Re/Software/bin/snakemake";
my $cwd = getcwd();
my $dir_raw = "$cwd/raw";
mkdir "$dir_raw";

# rawdata dir
#====================================
#
open FI,"$dir_list" or die $!;
while (<FI>) {
	chomp;
	`ls $_/*.gz >> data.lst`;
}
close FI;

# mkdir raw & soft link
#=====================================
#
chdir "$dir_raw";
open RD,"$cwd/data.lst" or die $!;
open NA,">namelist" or die $!;
my $index = 1;

while (my $rd1 = <RD>) {
	my $rd2 = <RD>;
	chomp($rd1);
	chomp($rd2);
	`ln -s $rd1 lib${index}\_R1.fastq.gz`;
	`ln -s $rd2 lib${index}\_R2.fastq.gz`;
	print NA "lib${index}\n";
	$index ++;
}
close RD;
close NA;

# generate initial.sh & check.sh & work.sh
#===========================================
#
chdir "$cwd";
`echo perl /p299/user/og07/shichunwei/project/temp/snakemake/test/snakemake_rules/bin/reseq_bwa_init.pl -n raw/namelist -r $ref > initial.sh`;
`echo $SNAKE -nrp -s rules/reseq_bwa.rules > check.sh`;
#`echo "$SNAKE -s ./rules/reseq_bwa.rules  -T --stats ./snakejob.\$(date +%Y%m%d%H%M%S).stats -c 'qsub -cwd -S /bin/sh -q dna.q,rna.q,reseq.q,all.q -l vf={resources.qsub_vf}M,p={resources.qsub_p}' -j -k 2>>./snakedetail.log.\$(date +%Y%m%d%H%M%S)" > work.sh`;
open QC,">qc.sh" or die $!;
print QC "$SNAKE -s ./rules/filter_raw.rules -T --stats ./snakejob.\$(date +%Y%m%d%H%M%S).stats -c 'qsub -cwd -S /bin/sh -q dna.q,rna.q,reseq.q,all.q -l vf={resources.qsub_vf}M,p={resources.qsub_p}' -j -k 2>>./snakedetail.log.\$(date +%Y%m%d%H%M%S)\n";
close QC;

open OT,">work.sh" or die $!;
print OT "$SNAKE -s ./rules/reseq_bwa.rules -T --stats ./snakejob.\$(date +%Y%m%d%H%M%S).stats -c 'qsub -cwd -S /bin/sh -q dna.q,rna.q,reseq.q,all.q -l vf={resources.qsub_vf}M,p={resources.qsub_p}' -j -k 2>>./snakedetail.log.\$(date +%Y%m%d%H%M%S)\n";
close OT;
