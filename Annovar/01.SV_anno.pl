#!/usr/bin/perl -w
#================================================
#
#         Author: chenli
#          Email: chenli1606@1gene.com.cn
#         Create: 2017-01-03 21:23:57
#    Description: -
#
#================================================
use strict;
die "perl $0 <multianno.txt> <stat.out>\n\n" unless (@ARGV == 2);
my($in,$out) = @ARGV;

open(OUT,">$out") || die "$!";
print OUT "#Chr\tRegion\tType\tFunc.refGene\tGene.refGene\n";
open(IN,"<$in") || die "$!";
while(<IN>)
{
	if(/Chr\tStart/)
	{
		next;
	}
	else
	{
		chomp;
		my @tmp = split /\t/,$_;
		if($tmp[3] eq "0")
		{
			print OUT "$tmp[0]\t$tmp[1]-$tmp[2]\tDEL\t$tmp[5]\t$tmp[6]\n";
		}
		else
		{
			print OUT "$tmp[0]\t$tmp[1]\tDUP\t$tmp[5]\t$tmp[6]\n";
		}
	}
}
close(IN);
close(OUT);
