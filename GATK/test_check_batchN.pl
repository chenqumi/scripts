use warnings;
use strict;
use Getopt::Long;
use File::Basename;
use FindBin qw($Bin);
use Cwd qw(abs_path getcwd);

my($tmp_lst,$bam_lst)=@ARGV;
die "perl $0 <tmp.lst> <bam.lst>" if (@ARGV == 0);

my $MERGE = "perl $Bin/merge.pl";

`cat $tmp_lst $bam_lst > tmp_bam.lst`;

my %lib;
my %lib2;
open FI,"tmp_bam.lst" or die $!;
open ME,">merge.lst" or die $!;
while (<FI>) {
	chomp;
	my $file = basename($_);
	my ($sample,$header) = &parse_merge2($file);
	print "$sample\t$header\n";

	if (!exists $lib{$sample}){
		$lib{$sample} = $header;
	}
	$lib2{$lib{$sample}} .= "$_ ";


	#if (!exists $lib{$sample}){
	#	print ME ">$header\n";
	#	$lib{$sample} = 1;
	#}
	#print ME "$_\n";
}
close FI;

foreach my $key (keys %lib2) {
	my @arr = split(/\s+/,$lib2{$key});
	print ME ">$key\n";
	foreach my $x (@arr) {
		print ME "$x\n";
	}
}
close ME;



sub check_batchN_and_bamfile{
	#"check whether batchN in bam_lst";
	my($tmp_lst,$bam_lst) = @_;
	my %hash;
	open TMP,"$tmp_lst" or die $!;
	while (<TMP>) {
		chomp;
		if (basename($_) =~ /(\S+)\_batch[N]*\_split/){
			my $key = $1;
			$hash{$key} = 1;
		}
	}
	close TMP;

	open BAM,"$bam_lst" or die $!;
	while (<BAM>) {
		chomp;
		basename($_) =~ /(\S+)\_batch[N]*\_split/;
		my $name = $1;
		die "No corresponding file in bam.lst" if (!exists $hash{$name});
	}
}



sub parse_merge{
	my $file = shift;

	if ($file =~ /(\S+)\_batch\_split/)
	{	
		return "$1\_batch";
	}
	elsif($file =~ /(\S+)_split/)
	{	
		return $1;
	}
	elsif($file =~ /(\S+)\_batchN\_split/)
	{
		return "$1\_batchN";
	}
	else
	{
		die "May be wrong with sample name when merge bam!";
	}
}

sub parse_merge2{
	my $file = shift;

	if ($file =~ /(\S+)\_batch\_split/)
	{	
		return $1,"$1\_batch";
		#$lib{$1} = "$1\_batch";
	}
	elsif($file =~ /(\S+)\_batchN\_split/)
	{
		return $1,$1;
		#$lib{$1} = "$1\_batchN";
	}
	elsif($file =~ /(\S+)\_batch\.bam/)
	{
		return $1,$1;
	}
	elsif($file =~ /(\S+)_split/)
	{	
		return $1,$1;
		#$lib{$1} = "$1";
	}
	else
	{
		die "May be wrong with sample name when merge bam!";
	}
}