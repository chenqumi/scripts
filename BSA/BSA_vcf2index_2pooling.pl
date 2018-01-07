#!/usr/bin/perl
#shi^16Nov22
#shi^16Dec12
use strict;
use warnings;
use Cwd 'abs_path';
use Getopt::Long;
my ($pop,$outdir,$parent,$offspring);

GetOptions(
    'vcf|v=s' => \$pop,
    'outdir|o=s' => \$outdir,
    'parent|P=s' => \$parent,
    'offspring|O=s' => \$offspring,
);

my $usage =<<U;
 usage:
 	-vcf|v vcf,by samtools.[required]
 	-outdir|o output directory.
 	-parent|P parent order in vcf,can be 0 parent; 1 parent; 2 parents. 0 parent means regard the reference as parent.
 	-offspring|O offspring pooling order in vcf, must be 2 poolings.[required]
 	
 eg: perl $0 -v pop.vcf -o outdir -P 1,2 -O 3,4 
 default: 
	parent = wild,mutation
	offspring = wild pooling,mutation pooling.
U

if ($pop and $offspring){
	print "analysis start\n";
}
else{
	print $usage;
	exit;
}

if (!defined $outdir){
    $outdir = abs_path("./");
}
print $outdir,"\n";

my @parent;
if (defined $parent){
	@parent = split /,/,$parent;
}

my ($Of1,$Of2) = split /,/,$offspring;
# candidate sites: different genotype in parent01 and parent02.

my %candidate_sites;
my %sample;
open IN,$pop or die $!;
while(<IN>){
	chomp;
	if (/^#/){
		if (/^#CHROM/){
			my @last = split /\t/,$_;
			for (9..$#last){
				$sample{$_ - 8} = $last[$_];
			}
		}
		next;
	}

    my @l = split /\t/,$_;
	my ($chr,$pos,$ref,$alt,$filter,$indel) = @l[0,1,3,4,6,7];


	next if (($filter ne 'PASS') and ($filter ne '.')); 
	next if ($indel =~ /^INDEL;/); # filter indel
    next if ($alt =~ /,/); # filter 3-bases
	my ($genotype_p1,$genotype_p2,$p1,$p2);

	if ((scalar @parent) == 0 ){
		$candidate_sites{$chr}{$pos} = 1;
	}
	elsif((scalar @parent) == 1){
		$p1 = $l[$parent[0]+8];
		if ($p1 =~ /^0\/0/ or $p1 =~ /^1\/1/){ # homozygosis
			$genotype_p1 = &genotype($ref,$alt,$p1);
			$candidate_sites{$chr}{$pos} = 1;
		}
	}
	elsif((scalar @parent) == 2){
		$p1 = $l[$parent[0]+8];
		$p2 = $l[$parent[1]+8];
		if ($p1 =~ /^0\/0/ or $p1 =~ /^1\/1/){ # homozygosis
			$genotype_p1 = &genotype($ref,$alt,$p1);
			if ($p2 =~ /^0\/0/ or $p2 =~ /^1\/1/){
				$genotype_p2 = &genotype($ref,$alt,$p2);
				$candidate_sites{$chr}{$pos} = 1 if ($genotype_p1 ne $genotype_p2); # different genotype sites of p1 and p2.
			}
		}
	}
	else{
		warn and exit;
	}
}
close IN;
# get parent genotype[sub]
sub genotype{
	my ($ref,$alt,$p) = @_;
	return "$ref" if (!defined $p);
	if ($p =~ /^0\/0/){
		return $ref;
	}
	elsif($p =~ /^1\/1/){
		return $alt;
	}
	else{
		warn;
	}
}
# SNP-index
if ((scalar @parent) == 0){
	push @parent,'none';
}

for my $k(0..$#parent){
    my %hash;
    open IN,$pop or die $!;
    if ($parent[$k] eq 'none'){
    	open T,'>',"$outdir/SNP-index_noparent.xls" or die $!;
    }
    else{
    	open T,'>',"$outdir/SNP-index\_$sample{$parent[$k]}.xls" or die $!;
    }
	my $head = join "\t",('CHROM','POS','REF','ALT','Genotype_P','Depth_P','Ref_depth_of1','Alt_depth_of1','Depth_of1','SNPindex_of1','Ref_depth_of2','Alt_depth_of2','Depth_of2','SNPindex_of2');
	open HEAD,'>',"$outdir/ChrLength.xls" or die $!;
	while(<IN>){
   		if (/^#/){
       		if (/^##contig=/){
           		/^##contig=<ID=(\S+),length=(\d+)>/;
           		print HEAD "$1\t$2\n";
           		next;
       		}
    		else{
            	next;
        	}
    	}
    	if (defined $head){
        	print T $head,"\n";
        	$head = ();
        	next;
    	}

		chomp;
		my ($chr,$pos,$ref,$alt,$filter,$indel) = (split /\t/,$_)[0,1,3,4,6,7];
		next if (not exists $candidate_sites{$chr}{$pos});
		my $of1 = (split /\t/,$_)[$Of1+8];
		my $of2 = (split /\t/,$_)[$Of2+8];
		
		my $p;
		if ($parent[$k] ne 'none'){
			$p = (split /\t/,$_)[8+$parent[$k]];
		}

		my @out = ($chr,$pos,$ref,$alt);
    	my ($Genotype_P,$Depth_p);

    	if ($parent[$k] ne 'none'){
    	 	$Genotype_P = &genotype($ref,$alt,$p);
    	 	$p =~ /:(\d+),(\d+)$/;
    	 	$Depth_p = $1 + $2;
    	}
    	else{
    		$Genotype_P = &genotype($ref,$alt);
    		$Depth_p = "-";
    	}
   		push @out,($Genotype_P,$Depth_p);

    	## SNPindex 1
    	$of1 =~ /:(\d+),(\d+)$/;
    	push @out,($1,$2,$1+$2);
    	my $SNPindex_of1;
    	if ($Genotype_P eq $ref){
        	next if (($1+$2) == 0); # next if genotype is ./.
        	$SNPindex_of1 = $2/($1+$2);
    	}
    	elsif($Genotype_P eq $alt){
        	next if (($1+$2) == 0);
        	$SNPindex_of1 = $1/($1+$2);
    	}
    	else{
        	warn;
    	}
    	push @out,$SNPindex_of1;
    	
    	## SNPindex 2
    	$of2 =~ /:(\d+),(\d+)$/;
    	push @out,($1,$2,$1+$2);
    	my $SNPindex_of2;
    	if ($Genotype_P eq $ref){
        	next if (($1+$2) == 0);
        	$SNPindex_of2 = $2/($1+$2);
    	}
    	elsif($Genotype_P eq $alt){
        	next if (($1+$2) == 0);
        	$SNPindex_of2 = $1/($1+$2);
    	}
    	else{
        	warn;
    	}
    	push @out,$SNPindex_of2;
    	# output
    	my $out = join "\t",@out;
    	print T $out,"\n";	
	}
	close IN;
	close T;
	close HEAD;
}
print "vcf to SNP-index: done\n";