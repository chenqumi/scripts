#chenqumi@20170825
use warnings;
use strict;
my($ld,$bin1,$interval,$bin2,$out) = @ARGV;
die "\nperl $0 I:<plink.ld> <bin1|bp> <interval|bp> <bin2|bp> O:<out>
            
        plink.ld:
        bin: calculate mean r2 in interval of bin 
" if (@ARGV==0);

# TODO !!!! sort plink.ld 

my (@arr1,@arr2);
my $distance;
my $flag = 1;
my $step1 = $bin1;
my $step2 = $bin2;

open LD,"$ld" or die $!;
open OT,">$out" or die $!;
while (<LD>) {
    chomp;
    my($r2,$dis) = split;
    $distance = $dis;

    if ($dis <= $interval)
    {   

        if ($dis <= $bin1)
        {
            push(@arr1,$r2);
        }
        else
        {   
            mean1();
            push(@arr1,$r2);
            $bin1 = (int($dis/$step1) + 1)*$step1;   
        }
    }
    else
    {   
        mean1() if ($flag == 1);
        $flag = -1;
        
        if ($dis <= $bin2)
        {
            push(@arr2,$r2);
        }
        else
        {   
            mean2();
            push(@arr2,$r2);
            $bin2 = (int($dis/$step2) + 1)*$step2;
        }
    }
}

$bin2 = (int($distance/$step2) + 1)*$step2;
&mean2();

close LD;
close OT;
#
# =========================================
#
sub mean1{
    my $sum = 0;
    foreach (@arr1) {
        $sum += $_;
    }
    my $mean_r2 = $sum/(scalar @arr1);
    print OT "$mean_r2\t$bin1\n";
    @arr1 = ();
}

sub mean2{
    my $sum = 0;
    foreach (@arr2) {
        $sum += $_;
    }
    my $mean_r2 = $sum/(scalar @arr2);
    print OT "$mean_r2\t$bin2\n";
    @arr2 = ();
}