use warnings;
use strict;
use File::Basename;
use Cwd qw(abs_path getcwd);

my ($lst,$ref) = @ARGV;

die 

"
\nperl <fq.lst> <ref.fa>
 
 fq.lst format: 
   samplename rd1.fq.gz
   samplename rd2.fq.gz
" 

if @ARGV==0;

# Software & dir
#=================================
#
my $SNAKE = "/nfs2/pipe/Re/Software/bin/snakemake";
my $cwd = getcwd();
my $dir_raw = "$cwd/raw";
mkdir "$dir_raw";


# mkdir raw & soft link
#=====================================
#
chdir "$dir_raw";
open RD,"$cwd/$lst" or die $!;
open NA,">$dir_raw/namelist" or die $!;
#my $index = 1;

while (my $ln1 = <RD>) {
	my $ln2 = <RD>;
	chomp($ln1);
	chomp($ln2);
	my($sample1,$rd1) = split(/\s+/,$ln1);
	my($sample2,$rd2) = split(/\s+/,$ln2);
	$rd1 = abs_path($rd1);
	$rd2 = abs_path($rd2);
	`ln -s $rd1 $sample1\_R1.fastq.gz`;
	`ln -s $rd2 $sample1\_R2.fastq.gz`;
	print NA "$sample1\n";
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
