#chenqumi@20171123
use warnings;
use strict;
use File::Basename;
use FindBin qw($Bin);
use Cwd qw(abs_path getcwd);

my ($vcf,$qual,$mindp,$maxdp) = @ARGV;
die "perl $0 I:<raw.vcf> <Qual> <minDP> <maxDP>" if (@ARGV==0);

#my $count = 0;
open VCF,"$vcf" or die $!;
while (<VCF>) {
    chomp;
    #$count ++;
    if (/^#/){
        print "$_\n";
        next;
    }
    my($alt,$q,$info) = (split/\t/,$_)[4,5,7];
    if ($alt=~/,/ or $q < $qual){
        next;
    }
    #$info =~ /DP=(\d+);.*;FS=(\S+?);.*;MQ=(\S+?);MQRankSum=(\S+?);QD=(\S+?);/;
    $info =~ /DP=(\d+);.*;FS=(\S+?);.*;MQ=(\S+?);.*SOR=(\S+)/;
    my $dp = $1;
    my $fs = $2;
    my $mq = $3;
    my $sor = $4;

    my $qd = "";
    my $mqranksum = "";
    my $readpos = "";
    
    if ($info =~ /QD=(\S+?);/){
        $qd = $1;
    }

    if ($info =~ /MQRankSum=(\S+?);/){
        $mqranksum = $1;
    }
    if ($info =~ /ReadPosRankSum=(\S+?);/){
        $readpos = $1;
    }
    
    #print "$dp\t$fs\t$mq\t$mqranksum\t$qd\t$readpos\t$sor\n";
    #print "$dp\t$fs\t$mq\t$mqranksum\t$qd\n";
    #last if ($count > 92);
    if ($dp < $mindp or $dp > $maxdp or $fs > 60 or $mq < 40 or $sor > 3){
        next;
    }

    if ($qd ne "" and $qd < 2 ){
        next;
    }

    if ($mqranksum ne "" and $mqranksum < -12.5){
        next;
    }

    if ($readpos ne "" and $readpos < -8){
        next;
    }
    print "$_\n";
}
close VCF;

