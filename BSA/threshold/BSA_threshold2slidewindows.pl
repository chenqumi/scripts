#!/usr/bin/perl
#shi^Nov25
use warnings;
use strict;
use Cwd 'abs_path';
use File::Basename;
use Getopt::Long;

my ($in,$flag,$chrinfo,$win,$step,$min,$fd,$fi,$top);
GetOptions(
	'index|i=s' => \$in,
	'flag|f=s' => \$flag,
	'chr|c=s' => \$chrinfo,
	'win|w=s' => \$win,
	'step|s=s' => \$step,
	'min|m=s' => \$min,
	'filterDepth|fd=s' => \$fd,
	'filterIndex|fi=s' => \$fi,
	'top|t=s' => \$top,
);

my $usage=<<U;
	usage:
		-index|i: SNP-index file generated by BSA_index2threshold.pl[required];
		-flag|f: output file flag, default is out.
		-chr|c: ChrLength.xls file generated by BSA_vcf2index_2pooling.pl[required];
		-win|w: sliding window size,default is 1,000,000.
		-step|s: sliding window step size,default is 100,000.
		-min|m: the number of SNPs should be larger than [int]. if not, merge with the next window.default is 10.
		-filterDepth|fd： [int],[int] => the range of SNP depth, default is 10,100.
		-filterIndex|fi: [int],[int] => the range of SNP-index,default is 0.3,1.
		-top|t: top percent of the whole genome region[0.005~0.01].the default is 0.005.
	
	eg:
		perl BSA_threshold2slidewindows.pl -i SNP-index.xls -c ChrLength.xls
U
if ($in and $chrinfo ){
	print "analysis start\n";
}
else{
	print $usage and exit;
}

$flag ||= "out";
$win ||= 1000000;
$step ||= 100000;
$min ||= 10;
$fd = "10,100";
$fi = "0.3,1";

my %hash;
my %chr;
open CHR,$chrinfo or die $!;
while(<CHR>){
	next if (/^#/);
    my @l =split;
    $chr{$l[0]} = $l[1];
}

open IN,$in or die $!;
while(<IN>){
    next if (/^#/);
    next if (/^CHROM/);   
    chomp;
    my ($chr,$pos,$depth1,$index1,$depth2,$index2,$l99,$l95,$r95,$r99) = (split /\t/,$_)[0,1,8,9,12,13,14,15,16,17];
    
    next if ($depth1 < 10 and $depth2 < 10);   # filter depth < 10
    next if ($depth1 > 100 and $depth2 > 100); # filter depth > 100
    next if ($index1 < 0.3 and $index2 < 0.3);  # filter both < 0.3
    $l99 = 0 if ($l99 eq "NA");  #Nov.27
    $l95 = 0 if ($l95 eq "NA");

    push @{$hash{$chr}{$pos}},($index1,$index2,$l99,$l95,$r95,$r99,$pos);
}
print "all data readed.\n";
print (scalar keys %hash);
print "\n";

my @output;
my %delta;
for my $k(sort keys %hash){
    my @keys = sort {$a <=> $b} keys %{$hash{$k}};
    my $snp_count = 0;
    my $index;
    my $index2;
    my ($l99,$l95,$r95,$r99);
    my @index;
    my @real_pos;
    my @delta;
    my $delta_count = 0;
    my $delta_chr = "ABC";
    for (my $i = 0; ($win + $step * $i) < $chr{$k};$i++){
        for ($i*$step..$i*$step+$win){
            if (exists $hash{$k}{$_}){
                my @l = @{$hash{$k}{$_}};
                $snp_count += 1;
                $index += $l[0];
                $index2 += $l[1];
                push @delta,(join "\t",($k,$l[6]/$win,$l[0],$l[1],$l[1]-$l[0]));
                
                $l[2] = 0 if ($l[2] eq 'NA'); # set NA to 0. but it is wrong.
                $l[3] = 0 if ($l[3] eq 'NA'); # 

                $l99 += $l[2];
                $l95 += $l[3];
                $r95 += $l[4];
                $r99 += $l[5];
                push @index,@l;
            }
        }

        push @real_pos,$i;

        if ($snp_count >= $min){ # if SNP count > 10 ,print.
            if ($delta_chr ne $k){
                $delta_count = 0;
                $delta_chr = $k;
            }
            else{
                $delta_count ++;
            }
            my $out = $index/$snp_count;
            my $out2 = $index2/$snp_count;
            my $out3 = $l99/$snp_count;
            my $out4 = $l95/$snp_count;
            my $out5 = $r95/$snp_count;
            my $out6 = $r99/$snp_count;
            my $delta = $out2 - $out;
            my $real_pos = join ",",@real_pos;

            $snp_count = 0; # all init 
            $index = 0;
            $index2 = 0;
            $l99 = 0;
            $l95 = 0;
            $r95 = 0;
            $r99 = 0;
            @index = ();
            push @output,(join "\t",($k,$out,$out2,$delta,$out3,$out4,$out5,$out6,$real_pos, ($real_pos[-1]*$step + $win)/$win));
            push @{$delta{$k}{$delta_count}},@delta;
            @delta = ();
            @real_pos = ();
        }
    }
}

print "start to print \n";

# print out.
my $path = abs_path($in);
$path = dirname $path;
open T,'>',"$path/$flag\_snpindex.txt" or die $!;
open D,'>',"$path/$flag\_delta.txt" or die $!;
my %temp;
my $count;
print T "Count\tChromosome\tW_SnpIndex\tM_SnpIndex\tdelta_SnpIndex\tL99\tL95\tR95\tR99\tRealWindow\tRealPos\n";
# every chromsome start from count 0 ...
for (0..$#output){
    $output[$_] =~ /^(\S+)/;
    $count += 1;
    if (not exists $temp{$1}){
        $temp{$1} = 1;
        $count = 0;
    }
    print T "$count\t$output[$_]\n";
}

# print every site snp-index and delta-snp-index 
print D "count\tChromosome\tPos\tW_snpindex\tM_snpindex\tdelta_snpindex\n";
for my $k1(sort keys %delta){
    for my $k2(sort keys %{$delta{$k1}}){
        for (@{$delta{$k1}{$k2}}){
            print D "$k2\t$_\n";
        }
    }
}

