use warnings;
use strict;

my($file,$type) = @ARGV;
die "\nperl $0 I:<infile> <type>
Usage:
	count sample number for vcf or genotype file
	type must be one of vcf or genotype
" if (@ARGV != 2);

open IN,"$file" or die $!;

if ($type eq "vcf"){
	
	&count_vcf();

}elsif ($type eq "genotype"){

	&count_genotype();

}else{
	die "please check your \"type\", it must be one of \"vcf\" or \"genotype\".";
}

close IN;

sub count_vcf{
	while (<IN>) {
		next if (/^##/);
		if (/^#CHROM/){
			chomp;
			my@arr = split(/\s+/,$_);
			my $len = scalar(@arr)-9;
			print "\n$len\n";
			last;
		}
	}
}


sub count_genotype{
	while(<IN>){
		next if (/^#/);
		chomp;
		my@arr = split(/\s+/,$_);
		my $len = scalar(@arr)-3;
		print "\n$len\n";
		last;
	}
}