#!usr/bin/perl
use strict ;
my $snp = shift ;
my $anno = shift ;
my %h ;
open IN,"$snp" or die ;
while (<IN>){
	chomp ;
	my @l = split ;
	$h{$l[0]}{$l[1]} = "$_" ;
}
close IN ;
open IN,"$anno" or die ;
while (<IN>){
	chomp ;
	my @l= split ;
	my @n = @l ;
	shift @n ;
	shift @n ;
	shift @n ;
	shift @n ;
	my $a = join "\t",@n ;
	if (exists $h{$l[0]}{$l[1]}){
		print "$h{$l[0]}{$l[1]}\t$a\n";
	}
}
