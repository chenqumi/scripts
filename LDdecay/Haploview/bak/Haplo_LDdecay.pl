#chenqumi@20170503
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

my $usage = <<U;
    \nUsage:
        # Sample and Group info
        -GroupInfo|info: 
            GroupInfo format:
                name    sample.lst(samplename in vcf file, one sample per line)
                XZ      xz.lst
        
        # Split vcf file    
        -vcf: vcf file
        -cutoff|cut: rm splited vcf files if its length < cutoff [0]kb
        
        # Haploview Params
        -maxdistance|dis: calc r2 whithin max distance <int> [500]kb 
        -blockoutput|block : output block <str> [GAB|GAM|SPI|ALL]
        -skipcheck|skip: use ALL markers to calc r2; 
          filter params below will be NO work when defined this param

        -minGeno|geno: <float> [NULL]
        -minMAF|maf: <float> [NULL]
        -hwcutoff|hw: <float> [NULL]
        -missingCutoff|miss: <float> [NULL]
        -maxMendel|me: <int> [NULL]
        
        # Draw pic
        -bin1:      calc mean r2 in interval of bin [10]bp
        -interval:                                  [100]bp
        -bin2:      calc mean r2 in interval of bin [300]bp

    e.g: perl Haplo_LDdecay.pl -vcf bw.vcf -info group.info -c 500 -dis 800 -skip -bin1 10 -interval 100 -bin2 300 -block
     or: perl Haplo_LDdecay.pl -vcf bw.vcf -info group.info -c 500 -dis 800 -geno 0.1 -maf 0.01 -hw 0.001 -miss 0.3 -me 1 -block -bin1 10 -interval 100 -bin2 300
U

print $usage and exit if (@ARGV == 0);

my($info,$vcf,$cut,$dis,$geno,$maf,$hw,$miss,$skip,$mendel,$block,$bin1,$interval,$bin2);

GetOptions(
	"GroupInfo|info:s" => \$info,
	"vcf:s" => \$vcf,
	"cutoff|cut:i" => \$cut,
	"maxdistance|dis:i" => \$dis,
    "minGeno|geno:f" => \$geno,
    "minMAF|maf:f" => \$maf,
    "hwcutoff|hw:f" => \$hw,
    "missingCutoff|miss:f" => \$miss,
    "skipcheck|skip" => \$skip,
    "maxMendel|me:i" => \$mendel,
    "blockoutput|block:s" => \$block,
    "bin1:i" => \$bin1,
    "interval:i" => \$interval,
    "bin2:i" => \$bin2,
);
$dis ||= 500;
$bin1 ||= 10;
$interval ||= 100;
$bin2 ||= 300;

#die "perl $0 I:<> O:<>" if (@ARGV==0);
# Scripts
#===================================================================================
my $SPLIT = "perl /p299/user/og03/chenquan1609/Resequencing/script/split_chr4vcf.pl";
my $FORMAT = "perl $Bin/transfmt.pl";
my $HAP = "perl $Bin/haplo_r2.pl";
my $DATA = "perl $Bin/calc_mean_r2.pl";

# Directory
#==================================
my$cwd = getcwd();
my$dir_split = "$cwd/00.Split_Chr";
my$dir_cal = "$cwd/01.Cal_r2";
my$dir_deal = "$cwd/02.DealData";
my$dir_draw = "$cwd/03.Draw";
mkdir "$dir_split";
mkdir "$dir_cal";
mkdir "$dir_deal";
mkdir "$dir_draw";

# Qsub Parameters
#====================
my $memory = "40G";
my $thread = 1;
my $queue = "super.q";
my $project = "og";
my $max_job = 20;


# groupinfo format
# name sample.lst
# XZ xz.lst

# Parse GroupInfo
#==========================
my %gp_info;
open IN,"$info" or die $!;
while (<IN>) {
    chomp;
    my($gp,$lst) = split;
    $gp_info{$gp} = $lst;
}
close IN;

# Split vcf
#==========================
$vcf = abs_path($vcf);
chdir "$dir_split";
if (defined $cut){
    `$SPLIT $vcf -c $cut`;
}else{
    `$SPLIT $vcf`;
}

# Format transformation
#=========================================
chdir "$dir_cal";
`ls $dir_split/*.vcf > vcf.lst`;

foreach my $k (keys %gp_info) {
    mkdir "$dir_cal/$k";
    chdir "$dir_cal/$k";
    `$FORMAT ../vcf.lst $cwd/$gp_info{$k}`;
}

# Calc r2
#=============================================
chdir "$dir_deal";

foreach my $k (keys %gp_info) {
    mkdir "$dir_deal/$k";
    chdir "$dir_deal/$k";
    `ls $dir_cal/$k/*/*.HV.ped > ped.lst`;
    if (defined $skip){
        my $sh = "$HAP ped.lst -dis $dis -skip";
        $sh .= " -block $block" if (defined $block);
        `$sh`;
    }else{
        my $shell = "$HAP ped.lst -dis $dis";
        $shell .= " -geno $geno" if(defined $geno);
        $shell .= " -maf $maf" if(defined $maf);
        $shell .= " -hw $hw" if(defined $hw);
        $shell .= " -miss $miss" if(defined $miss);
        $shell .= " -me $mendel" if(defined $mendel);
        $shell .= " -block $block" if (defined $block);
        `$shell`;
    }
}

# Deal with File
#=============================================== 
foreach my $k (keys %gp_info) {
    chdir "$dir_deal/$k";
    open SH,">format.sh" or die $!;
    print SH "cat $dir_cal/$k/*/*.LD > combine_ld\n";
    print SH 'awk \'{print $5,"\t",$8}\' combine_ld > format_ld';
    print SH "\ngrep -v \"Dist\" format_ld > hap.ld\n";
    print SH 'sort -t $\'\t\' -k 2n hap.ld -o sort_hap.ld';
    print SH "\nrm combine_ld format_ld hap.ld\n";
    close SH;
	my $dir = "$dir_deal/$k";
    `echo deal.sh\tsh format.sh > work_format.sh`;
    qsub("work_format.sh", $dir, $memory, $thread,
     $queue, $project, "Fmt", $max_job);
}

# Calc mean r2 according bin
#=================================================== 
foreach my $k (keys %gp_info) {
    mkdir "$dir_draw/$k";
    chdir "$dir_draw/$k";
    `$DATA $dir_deal/$k/sort_hap.ld $bin1 $interval $bin2 $k\.result`;
}