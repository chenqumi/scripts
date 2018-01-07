#chenqumi@20170908
use warnings;
use strict;
use File::Basename;
use FindBin qw($Bin);
use Cwd qw(abs_path getcwd);
BEGIN {
    push (@INC,"$Bin");
}
use Qsub;


my ($vcf,$interval) = @ARGV;
die "perl $0 I:<vcf> <interval> " if (@ARGV != 2);


my $SPLIT = "perl $Bin/split_chr4vcf.pl";
my $LDSNP = "python $Bin/extract_interval_snp2.py";

# qsub parameters
#==============================================
#
my $memory = "10G";
my $thread = 1;
my $queue = "dna.q,rna.q,reseq.q,all.q";
my $project = "og";
my $max_job = 20;

my $cwd = getcwd();

# split vcf
# ============================================
$vcf = abs_path($vcf);
open SP,">split.sh" or die $!;
my $split = "$SPLIT $vcf";
print SP "split_vcf.sh\t$split\n";
close SP;

qsub("split.sh", $cwd, $memory, $thread,
     $queue, $project, "Split", $max_job);


# extract snp
# ============================================
`ls *.vcf > vcf.lst`;

#my @cat_file;
open LST,"vcf.lst" or die $!;
open SH,">extract.sh" or die $!;
while (<LST>) {
    chomp;
    next if ( $_ eq basename($vcf) );
    my $name = (split /\.vcf/,$_ )[0];
    my $cmd = "$LDSNP $_ $interval $name\.LDSNP.vcf";
    #push(@cat_file,"$name\.LDSNP.vcf");
    print SH "extract\_$name\.sh\t$cmd\n";
}
close LST;
close SH;

qsub("extract.sh", $cwd, $memory, $thread,
     $queue, $project, "extract", $max_job);

# combine file 
# ===============================================
my $cat_cmd = "cat head ";
open OD,"chr_order" or die $!;
open CAT,">cat_file.sh" or die $!;
while (<OD>) {
    chomp;
    $cat_cmd .= "$_\.LDSNP.vcf ";
    `rm $_\.vcf`;
}
my $vcf_name = ( split /\.vcf/,basename($vcf) )[0];
$cat_cmd .= "> $vcf_name\.LD_SNP.vcf";
print CAT "combine_vcf.sh\t$cat_cmd\n";
close CAT;
close OD;

qsub("cat_file.sh", $cwd, $memory, $thread,
     $queue, $project, "CAT", $max_job);

`rm *.LDSNP.vcf`;