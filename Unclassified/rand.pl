use strict;
use warnings;
use FindBin qw($Bin);
use File::Basename;
use Cwd qw(abs_path getcwd);

my($num,$lst) = @ARGV;
die "perl $0 I:<number> <list> O:<out>" if @ARGV == 0;

my @arr;
open LST,"$lst" or die $!;
while (<LST>) {
	chomp;
	push (@arr;$_);
}
close LST;

foreach (1..$num) {
	my $index = int(rand(scalar @arr));
	print "$arr[$index]\n";
}