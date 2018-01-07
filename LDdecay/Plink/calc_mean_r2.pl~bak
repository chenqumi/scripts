# Create:2017-04-18 19:22:34
use warnings;
use strict;
my($ld,$bin,$out) = @ARGV;
die "\nperl $0 I:<plink.ld> <bin|kb> O:<out>
			
		plink.ld:
        bin: calculate mean r2 in interval of bin 
" if (@ARGV==0);


# TODO !!!! sort plink.ld 


my @arr;
my $step = $bin;
my $distance;
open LD,"$ld" or die $!;
open OT,">$out" or die $!;
while (<LD>) {
	chomp;
	next if (/^#/);
	my($r2,$dis) = split;
	$distance = $dis;
	if ($dis < $bin){
		
		push(@arr,$r2);

	}else {
		&mean();
		push(@arr,$r2);
		$bin = (int($dis/$step) + 1)*$step;
		#print "$bin\n"; 
		#$bin += $step;
	}
}
#print "$bin\n";
#$bin += $step;
$bin = (int($distance/$step) + 1)*$step;# TODO!!!
&mean();


close LD;
close OT;

sub mean{
	my $sum = 0;
	foreach (@arr) {
		$sum += $_;
	}
	my $mean_r2 = $sum/(scalar @arr);
	print OT "$mean_r2\t$bin\n";
	@arr = ();
}
