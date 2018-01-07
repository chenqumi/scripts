#chenqumi@20170905
use warnings;
use strict;
use File::Basename;
use FindBin qw($Bin);
use Cwd qw(abs_path getcwd);
BEGIN {
    push (@INC,"$Bin");
}
use Qsub;

my ($bfile,$k) = @ARGV;
die "perl $0 I:<plink_bed_file> <K>" if (@ARGV==0);

my $ADMIX = "/p299/user/og06/pipe/pub/baozhigui/biosoft/admixture_linux-1.3.0/admixture";

# qsub parameters
#==============================================
#
my $memory = "10G";
my $thread = 4;
my $queue = "dna.q,rna.q,reseq.q,all.q";
my $project = "og";
my $max_job = 20;

my $cwd = getcwd();

open SH,">admixture.sh" or die $!;
for (my $i = 2; $i <= $k; $i++) {
    $bfile = abs_path($bfile);
    my $cmd = "$ADMIX --cv=10 -j4 $bfile $i -j8|tee log$i\.out";
    print SH "K$i\.sh\t$cmd\n";
}
close SH;

qsub("admixture.sh", $cwd, $memory, $thread,
     $queue, $project, "ADMIX", $max_job);
