#!/usr/bin/perl -w
use Getopt::Long;

GetOptions("input:s" => \$in, "output:s" => \$o, "help|?" => \$help);

$usage = <<'USAGE';
Description:
			from vcf file get genotypefile
Usage:
			perl $0 [options]
Options:
			-input <str> *  input vcf file ,may sigle or multiple sample;
			-output <str>*  output genotype file ;
			-help|?         help information;
For example:
			perl $0 -input pear.fina.vcf -output pear.final.snp.genotype
--------------------------------- Modified hanxuelian@1gene.com.cn 20140716 ------------------------------------
USAGE

if (!defined $in || defined $help) {
	print $usage;
	exit 1;
}


%combin = (
          "AC" =>  "M" , 
          "AG" =>  "R" , 
          "AT" =>  "W" , 
          "CT" =>  "Y" , 
          "CG" =>  "S" , 
          "GT" =>  "K" , 
          "AA" =>  "A" , 
          "TT" =>  "T" , 
          "GG" =>  "G" , 
          "CC" =>  "C" , 
          "CA" =>  "M" , 
          "GA" =>  "R" , 
          "TA" =>  "W" , 
          "TC" =>  "Y" , 
          "GC" =>  "S" , 
          "TG" =>  "K" , 
);
if ($in =~ /\.gz$/) {
	open VCF,"gzip -dc $in|" or die "fail read $in:$!\n";
} else {
	open VCF,"<$in" or die "fail read $in:$!\n";
}
#if ($o =~ /\.gz$/) {
#	$no = $o;
#} else {
#	$no = "$o.gz";
#}
open OUT,">$o" or die "fail output $o:$!\n";
while (<VCF>) {
	chomp;
	next if /^#/;
    @tmp = split;
    $chr = $tmp[0];
    $pos = $tmp[1];
    $ref = $tmp[3];
    $alt = $tmp[4];
	%info = ();
	@geno = split /\,/,$alt;
	unshift(@geno,$ref);
	for ($k = 0; $k < @geno; $k++) {
		$info{$k} = $geno[$k];
	}
	print OUT "$chr\t$pos\t$ref ";
#	print OUT "$chr\t$pos\t"; #For the request format in the following Population Structrue analysis
    for ($i = 9; $i <= $#tmp; $i++) {
			$g = '';
            $type = (split /\:/,$tmp[$i])[0];
			if ($type eq './.') {
				$g = "-";
			} else {
				@type = split /\//,$type;
				for ($j = 0; $j < @type; $j++) {
					if (exists $info{$type[$j]}) {
						$g .= $info{$type[$j]};
					} else {
						print "$chr\t$pos\t:There is beyond gneotype number,need to check $type[$j]\n";
					}
				}
				if (exists $combin{$g}) {
					$g = $combin{$g};	
				} else {
					print "$chr\t$pos\t:the abbreviation is not all,$g\n";
					last;
				}
			}
			if ($i == 9) {
				print OUT "$g";
			} else {
				print OUT " $g";
			}
    }
    print OUT "\n";
}
close VCF;
close OUT;
