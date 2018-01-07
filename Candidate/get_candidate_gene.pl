#create: 2017-03-31 15:27:57
use warnings;
use strict;
use FindBin qw($Bin);
my($snp,$region,$anno,$desc,$gff,$out) = @ARGV;

die 
"\nperl $0 I:<SNP-index> <region_info> <snp_anno> <desc.xls> <gff> O:<outfile>\n
region_info format:\n
	region1 Chr5 17.4-17.9
	region2 Chr5 21.2-23.0\n
" if (@ARGV==0);

# script
#============================================================
my $REANNO = "perl $Bin/get_region_anno.pl";

# parse region_info
#====================================
my %interval;
open RE,"$region" or die $!;
while (<RE>) {
	chomp;
	my($no,$chr,$block) = split;
	my($s,$e) = split(/-/,$block);
	$s = $s * 10**6;
	$e = $e * 10**6;
	$interval{$no} = "$chr $s $e";
}
close RE;


# get snp in region
#============================================
open INFO,">region_snp.xls" or die $!;
foreach my $k (keys %interval) {
	
	my($chr,$s,$e)=split(/\s+/,$interval{$k});
	
	open SNP,"$snp" or die $!;
	open OT,">$k\_snp.xls" or die $!;
	while (<SNP>) {
		chomp;
		if (/^CHROM/){
			print OT "$_\n";
			next;
		}
		my($scaff,$pos,$of1_d,$of1_s,$of2_d,$of2_s) = (split)[0,1,8,9,12,13];
		next if ($scaff ne $chr);
		next if ($pos < $s or $pos > $e);
		next if ($of1_s < 0.3 and $of2_s < 0.3);
		next if ($of1_s == 1 and $of2_s == 1);
		next if ($of1_d < 10 and $of2_d < 10);
		next if ($of1_d > 250 and $of2_d > 250);
		print OT "$_\n";
		print INFO "$_\n";
	}
	close SNP;
	close OT;
}
close INFO;

# Annotation for snp in region
#=================================================================
my $head = "CHROM\tPOS\tREF\tALT\tGenotype_P\tDepth_P\tRef_depth_of1\tAlt_depth_of1\t";
$head .= "Depth_of1\tSNPindex_of1\tRef_depth_of2\tAlt_depth_of2\tDepth_of2\tSNPindex_of2\t";
$head .= "GeneType\tGeneName\tAnnotation\tCodon\tFirst_ANN\tSnpEffGeneName\tSnpEffGeneID";
`echo $head > head`;

`$REANNO region_snp.xls $anno > region_snp_anno.cache`;
`cat head region_snp_anno.cache > region_snp_anno.xls`;

# get cadidate gene 
#===============================================
my %cadidate;
open RSA,"region_snp_anno.xls" or die $!;
while (<RSA>) {
	next if (/^CHROM/);
	chomp;
	my $gene;
	my($genename,$snpeffname) = (split)[15,19];
	if ($genename ne "-"){
		$gene = $genename;
	}else{
		$gene = &parse($snpeffname);
	}
	$cadidate{$gene} = "";
}
close RSA;


# get cadidate gene anno_info
#================================================
open GFF,"$gff" or die $!;
while (<GFF>) {
	next if (/^#/);
	chomp;
	my($chr,$type,$start,$end) = (split)[0,2..4];
	$_ =~ /ID=(\S+?);/;
	my $gene = $1;  # TODO! bug in relation between $gene and $1 when gene is ATG5555.1 format
	if (exists $cadidate{$gene}){
		$cadidate{$gene} .= "$chr\t$type\t$start\t$end";
	}
}
close GFF;


# get cadidate gene kogo_info
#===================================================
open DE,"$desc" or die $!;

while (<DE>) {
	chomp;
	next if (/^GeneID/);
	my($geneid,@want)=(split/\t/,$_)[0,2..5];
	my$content = join("\t",@want);
	$cadidate{$geneid} .= "\t$geneid\t$content" if (exists $cadidate{$geneid});
	#print OT "$cadidate{$geneid}\t$geneid\t$content\n" if (exists $cadidate{$geneid});
}
close DE;

open OT,">$out" or die $!;
print OT "Chr\tType\tStart\tEnd\tGeneID\tPathway\tGO Component\tGO Function\tGO Process\tBlast nr\n";
foreach my $k (keys %cadidate) {
	print OT "$cadidate{$k}\n";
}
close OT;



sub parse{
	my($snpeffname) = @_;
	my $gene;
	if ($snpeffname =~ /_/){
		$gene = (split/\_/,$snpeffname)[1];
		#$snpeffname =~ /(\w+)_(\S+).(\d+)/;
	}else{
		$gene = $snpeffname;
	}
	return $gene;
}
