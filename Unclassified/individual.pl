use warnings;
use strict;

my($lst, $out) = @ARGV;
die "perl $0 I:<remained_sam.lst> O:<outfile>" if @ARGV==0;

my %hash;
my $index = 1;
open FI,"$lst" or die $!;
open FO,">$out" or die $!;
while (<FI>) {
	chomp;
	my($pos,$num) = (split/-/,$_);
	$num = (sprintf "%03d",$num);
	my $index2 = (sprintf "%02d",$index);
	my $sam = $pos.$num;
	print FO "$index\t$index2\t$sam\t$sam\t$sam\t$pos\n";
	$index ++;
}
close FI;
close FO;