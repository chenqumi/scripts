#chenqumi@20170420
use warnings;
use strict;
use File::Basename;
use FindBin qw($Bin);
use Cwd qw(abs_path getcwd);

my ($pi1,$pi2,$fst,$out) = @ARGV;
die "perl $0 I:<group1.pi> <group2.pi> <g1_g2.fst> O:<outfile>" if (@ARGV==0);

my %hash1 = &save_info($pi1);
my %hash2 = &save_info($pi2);

open FST,"$fst" or die $!;
open OT,">$out" or die $!;

print OT "#num\tchr\tstart\tend\tPiratio\tFst\n";
my $index = 1;
while (<FST>) {
	chomp;
	my($chr,$s,$e,$fst) = (split)[0,1,2,5];
	my $k = "$chr\t$s\t$e";

	if (exists $hash1{$k} and exists $hash2{$k}){
		#next if ($fst < 0);
		$fst = 0 if ($fst < 0);
		my $piratio = log($hash1{$k}/$hash2{$k});
		print OT "$index\t$k\t$piratio\t$fst\n";
		$index ++;
	}
}
close FST;
close OT;


sub save_info{
	my ($file) = @_;
	my %hash;
	open PI,"$file" or die $!;
	while (<PI>) {
		chomp;
		next if (/^CHROM/);
		my($chr,$s,$e,$pi) = (split)[0,1,2,4];
		my $k = "$chr\t$s\t$e";
		$hash{$k} = $pi;
	}
	close PI;
	return %hash;
}
