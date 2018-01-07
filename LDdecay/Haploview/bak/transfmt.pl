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


my $memory = "5G";
my $thread = 1;
my $queue = "dna.q,rna.q,reseq.q,all.q";
my $project = "og";
my $max_job = 20;


open LST,"$lst" or die $!;
open SH1,">vcf2plink2HV.sh" or die $!;
#open SH2,">plink2HV.sh" or die $!;
while (<LST>) {
	chomp;
	my $vcf = abs_path($_);
	my $name = (split/\./,basename($vcf))[0];
	mkdir "$cwd/$name";
	print SH1 "$VCF --vcf $vcf --plink --out $cwd/$name/$name --keep $keep\n";
	print SH1 "$PLINK --noweb --file $cwd/$name/$name --recodeHV --out $cwd/$name/$name\.HV\n";
	#print SH2 "cd $cwd/$name\n";
	#print SH2 "$PLINK --noweb --file $cwd/$name/$name --recodeHV --out $cwd/$name/$name\.HV\n";

}
close LST;
close SH1;
#close SH2;

`echo transfmt.sh\tsh vcf2plink2HV.sh > work_fmt.sh`;
#`echo trans2HV.sh\tsh plink2HV.sh > work_p2h.sh`;

qsub("work_fmt.sh", $cwd, $memory, $thread,
     $queue, $project, "transfmt", $max_job);

#qsub("work_p2h.sh", $cwd, $memory, $thread,
#     $queue, $project, "transforamt", $max_job);