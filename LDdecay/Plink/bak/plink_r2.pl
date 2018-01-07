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

# Usage
#=====================================
# TODO : Para description
my $usage = <<U;
Usage:
	perl plink_r2.pl <vcf.lst> <keep.lst>

	-ld_window_kb|kb : [500]kb
	-ld_window_r2|r2 : [0]
	-ld_window|n : [99999]
	-maf : <float> [NULL]
	-hw : <float> [NULL]
	-mind :<float> [NULL]
	-geno : maxmissing <float> [NULL]
	-mendel : <int> [NULL]
U

print $usage and exit if (@ARGV == 0);

# Para
#===========================================
my($lst,$keep) = @ARGV;
my($kb,$r2,$n,$mind,$geno,$mendel,$maf,$hw);

GetOptions(
	"ld_window_kb|kb:i" => \$kb,
	"ld_window_r2|r2:i" => \$r2,
	"ld_window|n:i" => \$n,
	"hw:f" => \$hw,
	"maf:f" => \$maf,
	"mind:f" => \$mind,
	"geno:f" => \$geno,
	"mendel:i" => \$mendel,
);
$kb ||= 500;
$r2 ||= 0;
$n ||= 99999;

# Qsub Parameters
#====================
my $memory = "10G";
my $thread = 1;
my $queue = "reseq.q,dna.q,rna.q,all.q,super.q";
my $project = "og";
my $max_job = 20;

# Scripts
#===================================
my $VCF = "/lustre/project/og04/shichunwei/biosoft/vcftools/bin/vcftools";
my $PLINK = "/p299/user/og03/chenquan1609/Bin/Plink_v1.9/plink";
my $cwd = getcwd();

# Format transformation & Calc r2
#=============================================================
open LST,"$lst" or die $!;
open SH,">vcf2plink2ld.sh" or die $!;
#open SH2,">plink2ld.sh" or die $!;
while (<LST>) {
	chomp;
	my $vcf = abs_path($_);
	#my $name = (split/\./,basename($vcf))[0];
	my $file = basename($vcf);
	$file =~ /(\S+)\.vcf/;
	my $name = $1;
	mkdir "$cwd/$name";
	print SH "$VCF --vcf $vcf --plink --out $cwd/$name/$name --keep $keep\n";
	print SH "cd $cwd/$name\n";
	
	my $shell = "$PLINK --noweb --file $name --r2 --ld-window-kb $kb --ld-window-r2 $r2 --ld-window $n";
	$shell .= " --mind $mind" if (defined $mind);
	$shell .= " --geno $geno" if(defined $geno);
    $shell .= " --maf $maf" if(defined $maf);
    $shell .= " --hwe $hw" if(defined $hw);
    $shell .= " --mendel $mendel" if(defined $mendel);

	print SH "$shell\n";
}
close LST;
close SH;

# Qsub tasks
#===================================================
`echo calc_r2.sh\tsh vcf2plink2ld.sh > work_plink.sh`;
#`echo calc.sh\tsh plink2ld.sh > work_calc.sh`;

qsub("work_plink.sh", $cwd, $memory, $thread,
     $queue, $project, "Plink", $max_job);

#qsub("work_calc.sh", $cwd, $memory, $thread,
#     $queue, $project, "Calc", $max_job);
