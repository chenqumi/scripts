use strict;
use warnings;

my ($geno) = @ARGV;
die "perl $0 <.genotype>" if @ARGV==0;

open FI,"$geno" or die $!;

my $pre_id = "";
my @arr;
my $index = 1;

while (<FI>) {
	chomp;
	my($id,$info) = split(/\t/,$_,2);
	if ($pre_id ne $id){
		output();
		$index ++;
	}
	push(@arr,$info);
	$pre_id = $id;
}
$index ++;
output();
close FI;
print "$index\n";


sub output{
	return if (@arr == 0);
	#my($id,$info) = split(/\t/,$_,2);
	#my $handle = "OT$index";
	open FO,">$pre_id\.genotype" or die $!;
	#open $handle,">$pre_id\.genotype" or die $!;
	foreach (@arr) {
		print FO "$pre_id\t$_\n";
	}
	#close $handle;
	close FO;

	@arr = ();
}