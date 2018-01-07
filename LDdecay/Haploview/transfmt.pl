# Create: 2017-04-18 16:31:35
use warnings;
use strict;
use FindBin qw($Bin);
use File::Basename;
use Cwd qw(abs_path getcwd);
use Getopt::Long;
BEGIN {
    push (@INC,"$Bin");
}
use Qsub;

my($lst,$keep) = @ARGV;
die "perl $0 I:<vcf.lst> <keep.lst>" if (@ARGV==0);

my $VCF = "/lustre/project/og04/shichunwei/biosoft/vcftools/bin/vcftools";
my $PLINK = "/p299/user/og03/chenquan1609/Bin/Plink_v1.9/plink";
my $cwd = getcwd();


my $memory = "10G";
my $thread = 1;
my $queue = "dna.q,rna.q,reseq.q,all.q,super.q";
my $project = "og";
my $max_job = 40;


open LST,"$lst" or die $!;
open SH,">vcf2plink2HV.sh" or die $!;
while (<LST>) {
	chomp;
	my $vcf = abs_path($_);
	my $name = (split/\./,basename($vcf))[0];
	#mkdir "$cwd/$name";
	my $cmd = "mkdir $cwd/$name && ";
	$cmd .= "$VCF --vcf $vcf --plink --out $cwd/$name/$name --keep $keep && ";
	$cmd .= "$PLINK --noweb --file $cwd/$name/$name --recodeHV --out $cwd/$name/$name\.HV";
	print SH "fmt\_$name\.sh\t$cmd\n";

}
close LST;
close SH;

qsub("vcf2plink2HV.sh", $cwd, $memory, $thread,
     $queue, $project, "transfmt", $max_job);
