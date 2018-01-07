use warnings;
use strict;
use File::Basename;
use Cwd qw(abs_path getcwd);

my ($dir_list,$ref) = @ARGV;

die 

"
\nperl <rawdata_dir_list> <ref.fa>
 
 list format: samplename /path
 example: C8-12 /P299/DNA/raw/20171011
" 

if @ARGV==0;

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
my %hash;
open FI,"$dir_list" or die $!;
while (<FI>) {
	chomp;
	my($sample,$dir) = split(/\s+/,$_);
	$hash{$dir} = $sample;
	`ls $dir/*.gz >> data.lst`;
}
close FI;

open LST,"$cwd/data.lst" or die $!;
open LST2,">$cwd/data.list" or die $!;
while (<LST>) {
	chomp;
	my $path = dirname($_);
	print LST2 "$hash{$path}\t$_\n";
}
close LST;
close LST2;
`rm $cwd/data.lst`;

# mkdir raw & soft link
#=====================================
#
chdir "$dir_raw";
open RD,"$cwd/data.list" or die $!;
open NA,">namelist" or die $!;
#my $index = 1;

while (my $ln1 = <RD>) {
	my $ln2 = <RD>;
	chomp($ln1);
	chomp($ln2);
	my($sample1,$rd1) = split(/\t/,$ln1);
	my($sample2,$rd2) = split(/\t/,$ln2);
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
