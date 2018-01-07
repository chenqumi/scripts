use warnings;
use strict;
use Getopt::Long;
use File::Basename;
use FindBin qw($Bin);
use Cwd qw(abs_path getcwd);
BEGIN {
    push (@INC,"$Bin");
}
use Qsub;

my($ref,$fq_lst)=@ARGV;

die 
"
perl $0 <ref.fa> <fq.lst>
     -nosplit:     Don't split read
     -bamlst|bam:  bam file in former pipe
" 
if (@ARGV == 0);

my($nosplit,$bam_lst);
GetOptions(
	"nosplit" => \$nosplit,
	"bamlst|bam:s" => \$bam_lst,
);


# Software
#=============================================
#
my $BWA = "/nfs2/pipe/Cancer/Software/BWA/v0.7.12/bwa-master/bwa";
my $SPLIT = "perl $Bin/split_read_mk_list.pl";
my $ALIGN = "perl $Bin/Align.pl";
my $ALIGN_NO = "perl $Bin/Align_no_Index.pl";
my $MERGE = "perl $Bin/merge.pl";
my $BAM2GVCF = "perl $Bin/bam2gvcf.pl";
my $SAMTOOLS = "/lustre/project/og04/shichunwei/biosoft/samtools-1.3/samtools";
my $JAVA = "/p299/user/og07/baozhigui/reseq/biosoft/jre1.8.0_101/bin/java";
my $PICARD = "/p299/user/og06/pipe/pub/baozhigui/biosoft/picard-2.8.0/picard.jar";

#qsub parameters
#==============================================
#
my $memory = "5G";
my $thread = 4;
my $queue = "dna.q,rna.q,reseq.q,all.q";
my $project = "og";
my $max_job = 20;

# Working dir
#=============================================
#
my $cwd = getcwd();
my $dir_split = "$cwd/Split";
my $dir_index = "$cwd/Index";
my $dir_align = "$cwd/Align";
my $dir_merge = "$cwd/Merge";
my $dir_gatk = "$cwd/GATK";

mkdir "$dir_split";
mkdir "$dir_index";
mkdir "$dir_align";
mkdir "$dir_merge";
mkdir "$dir_gatk";

#========================================
#
$ref = abs_path($ref);
$bam_lst = abs_path($bam_lst);
`ln -s $ref $dir_index/ref.fa`;

# Check batch[N]* and bamfile in fq.lst & bam.lst
#=============================================
&check_batch_and_bam($fq_lst,$bam_lst) if (defined $bam_lst);

#Solve path of fq.lst
#=========================================
#
open FQ,"$fq_lst" or die $!;
open LI,">tmp_file.lst" or die $!;
while (my $line_1 = <FQ>) {
	my $line_2 = <FQ>;
	chomp $line_1;
	chomp $line_2;
	my ($lib_1,$rd_1)=split(/\s+/,$line_1);
	my ($lib_2,$rd_2)=split(/\s+/,$line_2);
	die "Not match" if ($lib_1 ne $lib_2);
	$rd_1 = abs_path($rd_1);
	$rd_2 = abs_path($rd_2);
	print LI "$lib_1\t$rd_1\n";
	print LI "$lib_2\t$rd_2\n";

	open OT,">$dir_split/$lib_1\.lst" or die $!;
	print OT "$lib_1\t$rd_1\n";
	print OT "$lib_1\t$rd_2\n";
	close OT;
}
close FQ;
close LI;


# Split read & Index reference
#=============================================
if (defined $nosplit){
	# NOT split read
	`$ALIGN $ref $cwd/tmp_file.lst`;
}else{
	chdir "$dir_split";
	`ls *.lst > list`;
	open LST,"list" or die $!;
	open SP,">Split.sh" or die $!;
	while (<LST>) {
		chomp;
		$_ =~ /(\S+).lst/;
		my $lib = $1;
		my $cmd = "$SPLIT $_ 1G";
		#$cmd .= " $size" if (defined $size);
		print SP "split\_$lib\.sh\t$cmd\n";
	}
	my $index_cmd = "$BWA index $dir_index/ref.fa && ";
	$index_cmd .= "$SAMTOOLS faidx $dir_index/ref.fa && ";
	$index_cmd .= "$JAVA -jar $PICARD CreateSequenceDictionary ";
	$index_cmd .= "R=$dir_index/ref.fa O=$dir_index/ref.dict";
	print SP "Index.sh\t$index_cmd\n";
	close LST;
	close SP;

	qsub("Split.sh", $dir_split, $memory, $thread,
     $queue, $project, "Split", $max_job);
}


# Index & Align
#=============================================
#
if (!defined $nosplit){
	chdir "$cwd";
	`$ALIGN_NO $dir_index/ref.fa $dir_split/split.lst`;
}

# Merge bam 
#=============================================
# Situ1: Split read
if (!defined $nosplit){
	chdir "$dir_merge";

	`ls $dir_align/*.bam > tmp`;

	if (defined $bam_lst){
		`cat tmp $bam_lst > tmp_bam.lst`;
	}else{
		`mv tmp tmp_bam.lst`;
	}
	

	my (%lib,%lib2);
	open FI,"tmp_bam.lst" or die $!;
	while (<FI>) {
		chomp;
		my $file = basename($_);
		my ($sample,$header) = &parse_merge($file);

		if (!exists $lib{$sample}){
		$lib{$sample} = $header;
		}
		$lib2{$lib{$sample}} .= "$_ ";
	}
	close FI;

	open ME,">merge.lst" or die $!;
	
	foreach my $key (keys %lib2) {
		my @arr = split(/\s+/,$lib2{$key});
		print ME ">$key\n";
		foreach my $x (@arr) {
			print ME "$x\n";
		}
	}
	close ME;

	`$MERGE merge.lst`;
}
# Situ2: NO split read 
else{
	
	if (defined $bam_lst){
		#"pass";
		chdir("$dir_merge");
		`ls $dir_align/*.bam > tmp`;
		`cat tmp $bam_lst > tmp_bam.lst`;
	}
	else {
		#"pass";
		`mv tmp tmp_bam.lst`;
	}
}

# GATK pipe: sort-->mark dup-->realign-->gvcf
#============================================
chdir("$dir_gatk");
if (!defined $nosplit){
	`ls $dir_merge/*.bam > tmp.lst`;
}
open TMP,"tmp.lst" or die $!;
open GLST,">gatk_bam.lst" or die $!;
while (<TMP>) {
	chomp;
	if (/(\S+)\_batch\.bam/){
		next;
	}else{
		print GLST "$_\n";
	}
}
close TMP;
close GLST;

`$BAM2GVCF $dir_index/ref.fa gatk_bam.lst`;



# subroutine
#============================================
#
sub check_batch_and_bam{
	#"check whether batchN in bam_lst";
	my($fq_lst,$bam_lst) = @_;
	my %hash;
	
	open TMP,"$fq_lst" or die $!;
	while (<TMP>) {
		chomp;
		my($lib,$rd) = split;
		if ($lib =~ /(\S+)\_batch[N]*/){
			my $name = $1;
			$hash{$name} = 1;	
		}
	}
	close TMP;

	open BAM,"$bam_lst" or die $!;
	while (<BAM>) {
		chomp;
		if (basename($_) =~ /(\S+)\_batch\.bam/){
			my $name = $1;
			die "No corresponding file in bam.lst" if (!exists $hash{$name});
		}else{
			die "check file name in bam.lst !";
		}
	}
	close BAM;

	
}

#
#===========================================================
#
sub parse_merge{
	my $file = shift;

	if ($file =~ /(\S+)\_batch\_split/)
	{	
		return $1,"$1\_batch";
	}
	elsif($file =~ /(\S+)\_batchN\_split/)
	{
		return $1,$1;
	}
	elsif($file =~ /(\S+)\_batch\.bam/)
	{
		return $1,$1;
	}
	elsif($file =~ /(\S+)_split/)
	{	
		return $1,$1;
	}
	else
	{
		die "May be wrong with sample name when merge bam!";
	}
}