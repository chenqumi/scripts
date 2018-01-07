#!/usr/bin/perl -w
#yuewei@1gene.com.cn 2016.1.19
use strict;
use FindBin qw($Bin);
use Cwd qw(abs_path getcwd);
BEGIN {
    push (@INC,"$Bin");
}
use Qsub;


die "\nusage: perl $0 <ref.fa> <list.bam> <list.depth>\n
format:
list.bam => file.bam or file-num.bam
list.depth => sample_name average_depth
\n"unless (@ARGV == 3);

my ($ref,$list,$list_depth) = @ARGV;


#qsub parameters
#=============================================
#
my $outdir = "Shell";
my $memory = "5G";
my $thread = 1;
my $queue = "dna.q,rna.q,reseq.q,all.q";
my $project = "og";
my $max_job = 20;
my $pro_name = "psmc";
#
#==============================================
my $cwd = getcwd();
my $dir_shell = "$cwd/Shell";
mkdir "$dir_shell";
#==============================================
#
my %depth;
open DEPTH,"$list_depth" or die "$!";
while (<DEPTH>)
{
	chomp;
	next if /^#/;
	my @tmp = split /\s+/,$_;
	$depth{$tmp[0]} = $tmp[3];
}
close DEPTH;

my $samtools = "/lustre/project/og04/shichunwei/biosoft/samtools-1.3/samtools";
my $bcftools = "/lustre/project/og04/shichunwei/biosoft/bcftools-1.3/bcftools";
my $vcf2fq = "/lustre/project/og04/shichunwei/biosoft/bcftools-1.3/vcfutils.pl";
my $fq2psmcfa = "/nfs3/onegene/user/group1/guolihua/Test_soft/PSMC/psmc-master/utils/fq2psmcfa";


my $shell = "bam2fq2psmcfa.sh";
open OUT, ">$shell" or die "$!";
open LIST, "$list" or die "$!";
while (<LIST>)
{
	chomp;
	my $bam = $_;
	my $ff = (split /\//,$bam)[-1];
	my $name = (split /\./,$ff)[0];#format of bam file: file.bam or file-num.bam
	my $d = int ($depth{$name} / 3) -1;#recommended a third of the average depth
	my $D = int (2 * $depth{$name}) +1;#redommended the twice of the average depth
	#print OUT "echo start time\ndate\n";
	$ref = abs_path($ref);
	my $shell = "$name\.sh";
	my $cmd = "$samtools mpileup -C50 -uf $ref $bam |$bcftools call -c - |$vcf2fq vcf2fq -d $d -D $D |gzip > $cwd/$name.fq.gz && echo $name bam2fq job done! && ";
	$cmd .= "$fq2psmcfa -q 20 $cwd/$name.fq.gz > $cwd/$name.psmcfa && echo $name fq2psmcfa job done!";
	print OUT "$shell\t$cmd\n";
	#print OUT "$samtools mpileup -C50 -uf $ref $bam |$bcftools call -c - |$vcf2fq vcf2fq -d $d -D $D |gzip > $name.fq.gz && echo $name bam2fq job done!\n";
	#print OUT "$samtools mpileup -C50 -uf $ref $bam |$bcftools view -c - |$vcf2fq vcf2fq -d 10 -D 100 |gzip > $name.fq.gz && echo $name bam2fq job done!\n";
	#print OUT "$fq2psmcfa -q 20 $name.fq.gz > $name.psmcfa && echo $name fq2psmcfa job done!\n";
	#print OUT "echo end time\ndate\n";
}
close LIST;
close OUT;

qsub($shell, $dir_shell, $memory, $thread,
         $queue, $project, $pro_name, $max_job);
