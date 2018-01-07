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
  -maxdistance|dis      <int>    [500]kb
  -minGeno|geno         <float>  [0.6]
  -minMAF|maf           <float>  [0.01]
  -hwcutoff|hw          <float>  [0.001]
  -missingCutoff|miss   <float>  [0.3]
  -maxMendel|me         <int>    [NULL]
  -blockoutput|block    <str>    [GAB|GAM|SPI|ALL]

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
$dis ||= 500;
#$geno ||= 0.6;
#$maf ||= 0.01;
#$hw ||= 0.001;
#$miss ||= 0.3;


my $HAPLO = "/p299/user/og03/chenquan1609/Bin/Haploview/Haploview.jar";
my $JAVA = "/p299/user/og07/baozhigui/reseq/biosoft/jre1.8.0_101/bin/java";
my $cwd = getcwd();


my $memory = "40G";
my $thread = 2;
my $queue = "dna.q,rna.q,reseq.q,all.q,super.q";
my $project = "og";
my $max_job = 40;


open LST,"$lst" or die $!;
open SH,">calc_r2.sh" or die $!;
while (<LST>) {
	chomp;
	my $ped = abs_path($_);
	my $file = basename($ped);
	my $path = dirname($ped);
	$file =~ /(\S+)\.ped/;
	my $name = $1;

    my $cmd = "$JAVA -Xmx20000M -jar $HAPLO -pedfile $ped -info $path/$name\.info";
    $cmd .= " -dprime -maxdistance $dis -memory 3000 -n";

	if (defined $skip)
    {
        $cmd .= " -skipcheck";
        $cmd .= " -blockoutput $block" if (defined $block);
        print SH "calcr2\_$name\.sh\t$cmd\n";
	}
    else
    {
		$cmd .= " -minGeno $geno" if(defined $geno);
        $cmd .= " -minMAF $maf" if(defined $maf);
        $cmd .= " -hwcutoff $hw" if(defined $hw);
        $cmd .= " -missingCutoff $miss" if(defined $miss);
        $cmd .= " -maxMendel $mendel" if(defined $mendel);
        $cmd .= " -blockoutput $block" if (defined $block);
        print SH "calcr2\_$name\.sh\t$cmd\n";
	}
}
close LST;
close SH;

#`echo calc.sh\tsh calc_r2.sh > work_calc.sh`;

qsub("calc_r2.sh", $cwd, $memory, $thread,
     $queue, $project, "Calc_r2", $max_job);