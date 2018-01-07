#!/usr/bin/perl
#shichunwei^16Nov.22
#shi^16Dec.13
use strict;
use warnings;
use Cwd 'abs_path';
use Getopt::Long;
my ($in,$outdir,$out,$replication,$fd,$fi);
GetOptions(
	'index|i=s' => \$in,
	'Outdir|O=s' => \$outdir,
	'outfile|o=s' => \$out,
	'replication|r=s' => \$replication,
	'filterDepth|fd=s' => \$fd,
	'filterIndex|fi=s' => \$fi,
);

my $usage=<<U;
	usage:
		-index|i: SNP-index file.[required]
		-Outdir|O: output directory
		-outfile|o: output file name,default is thredshold.snpindex.xls.
		-replication|r: replication times,default is 1,000.
		-filterDepth|fd： [int],[int] => the range of SNP depth, default is 10,100.
		-filterIndex|fi: [int],[int] => the range of SNP-index,default is 0.3,1.
	eg:
		perl BSA_index2threshold.pl -i SNP-index.xls -o outname -r 10000
U

if ($in){
	print "analysis start\n";
}
else{
	print $usage and exit;
}

$replication ||= 1000;
$outdir ||= "./";
$outdir = abs_path($outdir);
$out ||= "thredshold.snpindex.xls";
$fd ||= "10,100";
$fi ||= "0.3,1";

my @fd = split /,/,$fd;
my @fi = split /,/,$fi;

my %hash;
open IN,$in or die $!;
open T,'>',$out or die $!;
while(<IN>){
    chomp;
    next if (/^#/);
    if (/^CHROM/){
        print T $_;
        print T "\tL99\tL95\tR95\tR99\n";
        next;
    }
##CHROM  POS REF ALT Genotype_P Depth_P Ref_depth_of1 Alt_depth_of1 Depth_of1 SNPindex_of1 Ref_depth_of2  Alt_depth_of2  Depth_of2  SNPindex_of2
	my ($ref,$alt,$f1_ref,$f1_alt,$depth1,$index1,$f2_ref,$f2_alt,$depth2,$index2) = (split /\t/,$_)[2,3,6,7,8,9,10,11,12,13];
	# filter 
    next if ($depth1 < $fd[0] and $depth2 < $fd[0]);   # filter depth < 10
    next if ($depth1 > $fd[1] and $depth2 > $fd[1]); # filter depth > 100
    next if ($index1 < $fi[0] and $index2 < $fi[0]);  # filter both < 0.3
    next if ($index1 >= $fi[1] and $index2 == $fi[1]);
    next if ($depth1 == 0 or $depth2 == 0); # filter if one is missiing.

    my @bases;
    if (($f1_ref+$f2_ref) != 0){
	   for (1..($f1_ref+$f2_ref)){
		  push @bases,$ref;
	   }
    }

    if (($f1_alt+$f2_alt) != 0){
	   for (1..($f1_alt+$f2_alt)){
		  push @bases,$alt;
	   }
    }

	my $f1 = $f1_ref + $f1_alt;
    my $f2 = $f2_ref + $f2_alt;
    my @replication;
    open TR,'>',"permutation.tmp.R" or die $!;
    for (1..$replication){
        my $delta = permutation($ref,$alt,$f1,$f2,@bases);
        push @replication,$delta;
    }

    #@replication = sort {$a <=> $b} @replication;
    print T "$_\t";
    #print T "$replication[5]\t$replication[25]\t$replication[974]\t$replication[994]\n"; # 0.95 & 0.99  confidence interval
    #last;
    my $tmp = join ",",@replication;
    print TR "f<-ecdf(c(",$tmp,"))\n";
    print TR "inv_ecdf <- function(f){\n";
	print TR "x <- environment(f)\$x\n"; 
  	print TR "y <- environment(f)\$y\n";
  	print TR "approxfun(y, x)\n}\n";
	print TR "g <- inv_ecdf(f)\n";
	print TR "g(0.01)\ng(0.05)\ng(0.95)\ng(0.99)\n";
	close TR;
	my @tmp = `Rscript permutation.tmp.R`;

	for (@tmp){
		chomp;
		$_ = (split /\s+/,$_)[-1];
		#exit if ($_ =~ /NA/);
	}
	#print "@tmp\n";
	#last;
    print T "$tmp[0]\t$tmp[1]\t$tmp[2]\t$tmp[3]\n"; # 0.95 & 0.99  confidence interval	
}


# permutation test 
sub permutation {
    my ($ref,$alt,$f1,$f2,@bases) = @_;
    #print join "\t",($ref,$alt,$f1,$f2);
    #print "\t",$#bases;
    #exit;
    my (@f1,@f2);
    my %f1_num;
    while(1){
        my $k = int(rand($#bases + 1));
        $f1_num{$k} = 1;
        last if ((scalar keys %f1_num) == $f1);
    }

    for (0..$#bases){
        if (exists $f1_num{$_}){
            push @f1,$bases[$_];
        }
        else{
            push @f2,$bases[$_];
        }
    }

    my ($index_f1,$index_f2);
    for (@f1){
        $index_f1 += 1 if ($_ eq $alt);
    }
    if (not defined $index_f1){
        $index_f1 = 0;
    }
    else{
        $index_f1 = $index_f1 / (scalar @f1);
    }

    for (@f2){
        $index_f2 += 1 if ($_ eq $alt);
    }
    if (not defined $index_f2){
        $index_f2 = 0;
    }
    else{
        $index_f2 = $index_f2 /(scalar @f2);
    }

    my $delta_snp_index = $index_f1 - $index_f2;
}
