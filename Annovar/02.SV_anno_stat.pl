#!/usr/bin/perl -w
#================================================
#
#         Author: chenli
#          Email: chenli1606@1gene.com.cn
#         Create: 2017-01-04 13:27:35
#    Description: -
#
#================================================
use strict;
die "perl $0 <SV_anno.xls> <type_stat.out>\n\n" unless (@ARGV == 2);
my($in,$out) = @ARGV;

my %type;
open(IN,"<$in") || die "$!";
while(<IN>)
{
	if(/^#/)
	{
		next;
	}
	else
	{
		chomp;
		my @tmp = split /\t/,$_;
		my @tmp2 = split /;/,$tmp[3];
		foreach my $i (0..$#tmp2)
		{
			$type{$tmp2[$i]} += 1;
		}
	}
}
close(IN);

open(OUT,">$out") || die "$!";
print OUT "TYPE\tNUM\n";
foreach my $key (sort keys %type)
{
	print OUT "$key\t$type{$key}\n";
}
close(OUT);
