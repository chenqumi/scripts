use warnings;
# Create: 2017-04-18 17:30:28
use strict;

my($ld,$out) = @ARGV;
die "perl $0 I:<plink.ld> O:<format_plink.ld>" if (@ARGV==0);

open LD,"$ld" or die $!;
open OT,">$out" or die $!;
while (<LD>) {
	next if (/CHR_A/);
	chomp;
	my($bp_a,$bp_b,$r2) = (split)[1,4,6];
	my $dis = $bp_b - $bp_a;
	print OT "$r2\t$dis\n";
}
close LD;
close OT;
