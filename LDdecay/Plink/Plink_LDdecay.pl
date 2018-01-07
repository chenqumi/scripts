#chenqumi@20170504
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
    Usage:
        # Sample and Group info
        -groupinfo|info :
            
            GroupInfo format:
                name    sample.lst(samplename in vcf file, one sample per line)
                XZ      xz.lst
        
        # Split vcf file    
        -vcf: vcf file
        -cutoff|cut: rm splited vcf files if its length < cutoff    [0]kb
        
        # Plink params
        -ld_window_kb|kb :                                          [500]kb
        -ld_window_r2|r2 :                                          [0]
        -ld_window|n :                                              [99999]
        -maf :                                            <float>   [NULL]
        -hw :                                             <float>   [NULL]
        -mind :                                           <float>   [NULL]
        -geno : maxmissing                                <float>   [NULL]
        -mendel :                                         <int>     [NULL]
        
        # Draw pic
        -bin1:      calc mean r2 in interval of bin       <int>     [10]bp
        -interval:                                        <int>     [100]bp
        -bin2:      calc mean r2 in interval of bin       <int>     [300]bp

    e.g: perl Plink.pl -info group.info -vcf bw.vcf -c 500 -kb 800 -r2 0 -n 9999 -maf 0.01 -bin1 10 -interval 100 -bin2 300 
U

print $usage and exit if (@ARGV == 0);

my($info,$vcf,$cut,$kb,$n,$r2,$geno,$maf,$hw,$mind,$mendel,$bin1,$interval,$bin2);

GetOptions(
	"GroupInfo|info:s" => \$info,
	"vcf:s" => \$vcf,
	"cutoff|cut:i" => \$cut,
	"ld_window_kb|kb:i" => \$kb,
	"ld_window|n:i" => \$n,
    "ld_window_r2|r2:f" => \$r2,
    "maf:f" => \$maf,
    "hw:f" => \$hw,
    "geno:f" => \$geno,
    "mendel:f" => \$mendel,
    "mind:f" => \$mind,
    "bin1:i" => \$bin1,
    "interval:i" => \$interval,
    "bin2:i" => \$bin2,
);
$kb ||= 500;
$n ||= 99999;
$r2 ||= 0;
$bin1 ||= 10;
$interval ||= 100;
$bin2 ||= 300;

#die "perl $0 I:<> O:<>" if (@ARGV==0);
# Scripts
#===================================================================================
my $SPLIT = "perl /p299/user/og03/chenquan1609/Resequencing/script/split_chr4vcf.pl";
my $PLINK = "perl $Bin/plink_r2.pl";
my $DATA = "perl $Bin/calc_mean_r2.pl";
my $DEAL = "perl $Bin/format.pl";
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
my $memory2 = "15G";
my $thread = 1;
my $queue = "super.q";
my $project = "og";
my $max_job = 40;

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
if (defined $cut)
{
    `$SPLIT $vcf -c $cut`;
}
else
{
    `$SPLIT $vcf`;
}

# Format transformation & Calc r2
#=========================================
chdir "$dir_cal";
`ls $dir_split/*.vcf > vcf.lst`;

foreach my $k (keys %gp_info) {
    
    mkdir "$dir_cal/$k";
    chdir "$dir_cal/$k";
    
    my $shell = "$PLINK ../vcf.lst $cwd/$gp_info{$k} -kb $kb -r2 $r2 -n $n";
    $shell .= " -mind $mind" if (defined $mind);
	$shell .= " -geno $geno" if(defined $geno);
    $shell .= " -maf $maf" if(defined $maf);
    $shell .= " -hw $hw" if(defined $hw);
    $shell .= " -mendel $mendel" if(defined $mendel);

    `$shell`;
}


# Deal with File
#=============================================== 
foreach my $k (keys %gp_info) {
    
    mkdir "$dir_deal/$k";
    chdir "$dir_deal/$k";
    
    open SH,">format.sh" or die $!;
    print SH "cat $dir_cal/$k/*/*.ld > combine_ld\n";
    print SH "$DEAL combine_ld plink.ld\n";
    print SH 'sort -t $\'\t\' -k 2n plink.ld -o sort_plink.ld';
    print SH "\nrm combine_ld plink.ld\n";
    close SH;
	my $dir = "$dir_deal/$k";
    
    `echo deal.sh\tsh format.sh > work_format.sh`;
    
    qsub("work_format.sh", $dir, $memory, $thread,
          $queue, $project, "Fmt", $max_job);
}

# Calc mean r2 according bin
#=================================================== 
foreach my $k (keys %gp_info) {

    my $current_dir = "$dir_draw/$k";
    mkdir "$current_dir";
    chdir "$current_dir";
    
    my $cmd = "$DATA $dir_deal/$k/sort_plink.ld $bin1 ";
    $cmd .= "$interval $bin2 $k\.result";
    
    open LD,">ld_mean_r2.sh" or die $!;
    print LD "calc\_$k\.sh\t$cmd\n";
    close LD;
    
    qsub("ld_mean_r2.sh", $current_dir, $memory2, $thread,
         $queue, $project, "Final_calc", $max_job);
}
