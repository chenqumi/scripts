use warnings;
use strict;
use File::Basename;
use FindBin qw($Bin);
use Cwd qw(abs_path getcwd);
BEGIN {
    push (@INC,"$Bin");
}
use Qsub;

=head1 Usage 

 perl merge.pl <merge.lst> <project_name>

=head1 Description

 This script merge series of bams into one bam using samtools

=head1 merge.lst format:
 >PE450
 PE450_split_1.bam
 PE450_split_2.bam
 PE450_split_3.bam
 >PE800
 PE800_split_1.bam
 PE800_split_2.bam
 PE800_split_3.bam

=cut

my ($merge_lst)=@ARGV;
die `pod2text $0` if @ARGV != 1;

#Sortware
#===================================================
my $SAMTOOLS = "/lustre/project/og04/shichunwei/biosoft/samtools-1.3/samtools";

#qsub parameters
#==============================================
#
my $memory = "5G";
my $thread = 2;
my $queue = "dna.q,rna.q,reseq.q,all.q";
my $project = "og";
my $max_job = 20;

# woking dir
#==============================================
#
my $cwd = getcwd();
my $dir_shell = "$cwd/Shell";
mkdir "$dir_shell";


# Merge bam
#=====================================================
my $shell_merge = "$dir_shell/Merge.sh";

$/ = ">";
open LST,"$merge_lst" or die $!;
open SH,">$shell_merge" or die $!;
while (<LST>) {
	chomp;
	next if ($_ eq "");
	print "$_\n";
	my($lib,@file) = split(/\n/,$_);

	my $cmd = "$SAMTOOLS merge $cwd/$lib\.bam";

	foreach my $bam (@file) {
		my $bam = abs_path($bam);
		$cmd .= " $bam";
	}
	print SH "merge\_$lib.sh\t$cmd\n";
	
}
close LST;
close SH;
$/ = "\n";

qsub($shell_merge, $dir_shell, $memory, $thread,
     $queue, $project, "merge", $max_job);