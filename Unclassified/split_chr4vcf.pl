use strict;
use warnings;
use Getopt::Long;

my ($vcf) = @ARGV;
die "\nperl $0 I:<.vcf>

	 -cutoff|c [0]Kb
	 rm contig.vcf if length of contig < cutoff" if @ARGV==0;

my $cut;
GetOptions(
	"cutoff|c:i" => \$cut,
);
$cut ||= 0;
$cut = $cut * 10**3;

#
#========================================
my $pre_id = "";
my @arr;
my @file;
my %cutoff;
open FI,"$vcf" or die $!;
open HE,">head" or die $!;
while (<FI>) {
	chomp;
	if (/^#/){
		print HE "$_\n";
		if (/^##contig/){
			$_ =~ /ID=(\S+),length=(\d+)/;
			my $chr = $1;
			my $len = $2;
			$cutoff{$chr} = 1 if ($len < $cut);
		}
		next;
	}else{

		my($id,$info) = split(/\t/,$_,2);
		if ($pre_id ne $id){
			output();
			push(@file,$id);
		}
		push(@arr,$info);
		$pre_id = $id;
	}
	
}

output();
#push(@file,$pre_id);
close FI;

# combine head and split.vcf
#======================================
foreach (@file) {
	#print "$_\n";
	my $name = "$_\.vcf";
	`cat head $_ > $name`;
	`rm $_`;
}


# rm contig.vcg if length(congtig) < cutoff
#======================================
foreach my $k (keys %cutoff) {
	`rm $k\.vcf`;
}

# sub function
#======================================
sub output{
	return if (@arr == 0);
	
	open FO,">$pre_id" or die $!;
	
	foreach (@arr) {
		print FO "$pre_id\t$_\n";
	}
	
	close FO;

	@arr = ();
}
