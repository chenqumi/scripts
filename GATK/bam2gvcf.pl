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


my ($ref,$bam_lst) = @ARGV;
die "perl $0 I:<ref.fa> <bam.lst> " if (@ARGV==0);

# Software
#===================================
my $SAMTOOLS = "/lustre/project/og04/shichunwei/biosoft/samtools-1.3/samtools";
my $JAVA = "/p299/user/og07/baozhigui/reseq/biosoft/jre1.8.0_101/bin/java";
my $PICARD = "/p299/user/og06/pipe/pub/baozhigui/biosoft/picard-2.8.0/picard.jar";
my $GATK = "/p299/user/og03/chenquan1609/Bin/GATK_v3.8/GenomeAnalysisTK.jar";

# Work Dir
#====================================
my $cwd = getcwd();
my $dir_sort = "$cwd/Sort";
my $dir_mark = "$cwd/MarkDup";
my $dir_realign = "$cwd/Realign";
my $dir_gvcf = "$cwd/GVCF";

mkdir "$dir_sort";
mkdir "$dir_mark";
mkdir "$dir_realign";
mkdir "$dir_gvcf";

#qsub parameters
#==============================================
#
my $memory = "40G";
my $thread = 4;
my $queue = "dna.q,rna.q,reseq.q,all.q,super.q";
my $project = "og";
my $max_job = 40;

# Sort bam
#===========================================
my $shell_sort = "$dir_sort/sort.sh";
chdir("$dir_sort");
open BLST,"$cwd/$bam_lst" or die $!;
open SH1,">$shell_sort" or die $!;
while (<BLST>) {
	chomp;
	my $bam = abs_path($_);
	my $name = (split/\./,basename($bam))[0];
	my $cmd = "$SAMTOOLS sort -o $dir_sort/$name\.sort.bam $bam";
	print SH1 "sort\_$name\.sh\t$cmd\n";
}
close BLST;
close SH1;

qsub($shell_sort, "./", "10G", $thread,
     $queue, $project, "sort", $max_job);

# Mark duplicate
#==========================================
#
chdir("$dir_mark");
my $shell_mark = "$dir_mark/markdup.sh";
`ls $dir_sort/*.sort.bam > sort_bam.lst`;
open SB,"sort_bam.lst" or die $!;
open SH2,">$shell_mark" or die $!;
while (<SB>) {
	chomp;
	basename($_) =~ /(\S+)\.sort\.bam/;
	my $name = $1;
	my $cmd = "$JAVA -Xmx30G -jar $PICARD MarkDuplicates ";
	$cmd .= "MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=4000 ";
	$cmd .= "INPUT=$_ ";
	$cmd .= "OUTPUT=$name\.sort.rmdup.bam ";
	$cmd .= "METRICS_FILE=$name\.metrics && ";
	$cmd .= "$SAMTOOLS index $name\.sort.rmdup.bam";
	print SH2 "rmdup\_$name\.sh\t$cmd\n";
}
close SB;
close SH2;

qsub($shell_mark, "./", $memory, $thread,
     $queue, $project, "rmdup", $max_job);

# Realign 
#=============================================
#
chdir("$dir_realign");
my $shell_realign = "$dir_realign/realign.sh";
`ls $dir_mark/*.sort.rmdup.bam > rmdup_bam.lst`;
open MB,"rmdup_bam.lst" or die $!;
open SH3,">$shell_realign" or die $!;
while (<MB>) {
	chomp;
	basename($_) =~ /(\S+)\.sort\.rmdup\.bam/;
    # -fixMisencodedQuals
	my $name = $1;
	my $cmd = "$JAVA -Xmx30G -jar $GATK -T RealignerTargetCreator ";
	$cmd .= "-R $ref -I $_ ";
	$cmd .= "-o $name\.intervals && ";
	$cmd .= "$JAVA -Xmx30G -jar $GATK -T IndelRealigner ";
	$cmd .= "-R $ref -I $_ -targetIntervals $name\.intervals ";
	$cmd .= "-o $name\.realign.bam";

	print SH3 "realign\_$name\.sh\t$cmd\n";
}
close MB;
close SH3;

qsub($shell_realign, "./", $memory, $thread,
     $queue, $project, "realign", $max_job);

# Generate GVCF
#===========================================
#
chdir("$dir_gvcf");
`ls $dir_realign/*.realign.bam > realign_bam.lst`;
my $shell_gvcf = "$dir_gvcf/gvcf.sh";
open RB,"realign_bam.lst" or die $!;
open SH4,">$shell_gvcf" or die $!;
while (<RB>) {
	chomp;
	basename($_) =~ /(\S+)\.realign\.bam/;
	my $name = $1;
	my $cmd = "$JAVA -Xmx30G -jar $GATK -T HaplotypeCaller ";
	$cmd .= "-R $ref -I $_ -o $name\.g.vcf -ERC GVCF";
	print SH4 "gvcf\_$name\.sh\t$cmd\n";
}
close RB;
close SH4;

qsub($shell_gvcf, "./", $memory, $thread,
     $queue, $project, "gvcf", $max_job);
