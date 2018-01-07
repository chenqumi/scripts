#chenqumi@20170428
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

my($lst) = @ARGV;
die "\nperl $0 I:<ped.lst>\n
Note:
  JUST offer ped.lst as input file.
  this scrpit consider that the .info file has the same name with .ped file in the same directory

Para: same with Haploview
  -skipcheck|skip
  -maxdistance|dis <int> [500]kb
  -minGeno|geno <float> [0.6]
  -minMAF|maf <float> [0.01]
  -hwcutoff|hw <float> [0.001]
  -missingCutoff|miss <float> [0.3]
  -maxMendel|me <int> [NULL]
  -blockoutput|block <str> [GAB|GAM|SPI|ALL]

" if @ARGV == 0;
my($skip,$dis,$geno,$maf,$hw,$miss,$mendel,$block);

GetOptions(
	"skipcheck|skip" => \$skip,
	"maxdistance|dis:i" => \$dis,
	"minGeno|geno:f" => \$geno,
	"minMAF|maf:f" => \$maf,
	"hwcutoff|hw:f" => \$hw,
	"missingCutoff|miss:f" => \$miss,
	"maxMendel|me:i" => \$mendel,
	"blockoutput|block:s" => \$block,
);
#$dis ||= 500;
#$geno ||= 0.6;
#$maf ||= 0.01;
#$hw ||= 0.001;
#$miss ||= 0.3;


my $HAPLO = "/p299/user/og03/chenquan1609/Bin/Haploview/Haploview.jar";
my $JAVA = "/p299/user/og07/baozhigui/reseq/biosoft/jre1.8.0_101/bin/java";
my $cwd = getcwd();


my $memory = "40G";
my $thread = 1;
my $queue = "dna.q,rna.q,reseq.q,all.q,super.q";
my $project = "og";
my $max_job = 20;


open LST,"$lst" or die $!;
open SH,">calc_r2.sh" or die $!;
while (<LST>) {
	chomp;
	my $ped = abs_path($_);
	my $file = basename($ped);
	my $path = dirname($ped);
	$file =~ /(\S+)\.ped/;
	my $name = $1;
	if (defined $skip){
		my $sh = "$JAVA -Xmx20000M -jar $HAPLO -pedfile $ped -info $path/$name\.info -dprime -maxdistance $dis -memory 3000 -n -skipcheck";
		$sh .= " -blockoutput $block" if (defined $block);
		print SH "$sh\n";
	}else{
		my $shell = "$JAVA -Xmx20000M -jar $HAPLO -pedfile $ped -info $path/$name\.info -dprime -maxdistance $dis -memory 3000 -n";
		$shell .= " -minGeno $geno" if(defined $geno);
        $shell .= " -minMAF $maf" if(defined $maf);
        $shell .= " -hwcutoff $hw" if(defined $hw);
        $shell .= " -missingCutoff $miss" if(defined $miss);
        $shell .= " -maxMendel $mendel" if(defined $mendel);
        $shell .= " -blockoutput $block" if (defined $block);
        print SH "$shell\n";
	}
}
close LST;
close SH;

`echo calc.sh\tsh calc_r2.sh > work_calc.sh`;

qsub("work_calc.sh", $cwd, $memory, $thread,
     $queue, $project, "Calc", $max_job);