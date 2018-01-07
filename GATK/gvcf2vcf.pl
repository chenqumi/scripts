#chenqumi@20170615
use warnings;
use strict;
use File::Basename;
use FindBin qw($Bin);
use Cwd qw(abs_path getcwd);
BEGIN {
    push (@INC,"$Bin");
}
use Qsub;


my ($ref,$gvcf_lst,$out) = @ARGV;
die "perl $0 I:<ref.fa> <gvcf.lst> O:<out>" if (@ARGV==0);

my $JAVA = "/p299/user/og07/baozhigui/reseq/biosoft/jre1.8.0_101/bin/java";
my $GATK = "/p299/user/og03/chenquan1609/Bin/GATK_v3.8/GenomeAnalysisTK.jar";

#qsub parameters
#==============================================
#
my $memory = "40G";
my $thread = 4;
my $queue = "dna.q,rna.q,reseq.q,all.q,super.q";
my $project = "og";
my $max_job = 20;


my $cwd = getcwd();

my $cmd = "$JAVA -Xmx30G -jar $GATK -T GenotypeGVCFs -R $ref";
open LST,"$gvcf_lst" or die $!;
open SH,">gvcf2vcf.sh" or die $!;
while (<LST>) {
	chomp;
	my $gvcf = abs_path($_);
	$cmd .= " -V $gvcf";
}
$cmd .= " -o $out";
print SH "gatk_call.sh\t$cmd\n";
close LST;
close SH;

qsub("gvcf2vcf.sh", $cwd, $memory, $thread,
     $queue, $project, "GATK", $max_job);