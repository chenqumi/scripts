use warnings;
use strict;
use FindBin qw($Bin);
use File::Basename;
use Cwd qw(abs_path getcwd);
BEGIN {
    push (@INC,"$Bin");
}
use Qsub;
=head1 Usage 

 perl Align.pl <ref.fa> <fq.lst>

=head1 Description

 This script includ Index & Align

=head1 fq.lst format:

 lib_name	read
 PE450	read1.fq.gz
 PE450	read2.fq.gz

=cut
my ($ref,$fq_lst) = @ARGV;
die `pod2text $0`  if (@ARGV != 2);

# Software
my $BWA = "/nfs2/pipe/Cancer/Software/BWA/v0.7.12/bwa-master/bwa";
my $SAMTOOLS = "/lustre/project/og04/shichunwei/biosoft/samtools-1.3/samtools";

#qsub parameters
#==============================================
#
my $memory = "10G";
my $thread = 8;
my $queue = "dna.q,rna.q,reseq.q,all.q";
my $project = "og";
my $max_job = 20;

# Work dir
#===============================================
#
my $cwd = getcwd();
#my $dir_index = "$cwd/Index";
my $dir_align = "$cwd/Align";
my $dir_shell = "$cwd/Shell_BWA";
#mkdir "$dir_index";
mkdir "$dir_align";
mkdir "$dir_shell";

#$ref = abs_path($ref);

# Align
#=================================================
#
my $shell_align = "$dir_shell/Align.sh";

open FI, "$fq_lst" or die $!;
open FO, ">$shell_align" or die $!;

while (my $line_1 = <FI>) {
	my $line_2 = <FI>;
	chomp $line_1;
	chomp $line_2;
	my ($lib_1,$rd_1)=split(/\s+/,$line_1);
	my ($lib_2,$rd_2)=split(/\s+/,$line_2);
	die "Not match" if ($lib_1 ne $lib_2);
	$rd_1=abs_path($rd_1);
	$rd_2=abs_path($rd_2);
	my $shell = "bwa\_$lib_1.sh";
	my $header = &parse($lib_1);
	my $cmd = "$BWA mem -M -t 8 -k 32 -R \"\@RG\\tID:$header\\tLB:$header\\tSM:$header\\tPL:ILLUMINA\" ";
	$cmd .= "$ref ";
	$cmd .= "$rd_1 $rd_2 | ";
	$cmd .= "$SAMTOOLS view -bS > $dir_align/$lib_1.bam";
	print FO "$shell\t$cmd\n";
}
close FI;
close FO;

qsub($shell_align, $dir_shell, $memory, $thread,
     $queue, $project, "Align", $max_job);

sub parse{
	my $lib = shift;
	if ($lib =~ /(\S+)\_batch(\S*)/){
		return $1;
	}elsif($lib =~ /(\S+)\_split\_\d+/){
		return $1;
	}else{
		return $lib;
	}
}