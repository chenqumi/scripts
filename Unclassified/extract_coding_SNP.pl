#chenqumi@20170911
use warnings;
use strict;
use File::Basename;
use FindBin qw($Bin);
use Cwd qw(abs_path getcwd);

my ($vcf,$gff) = @ARGV;
die "perl $0 I:<vcf> <gff> " if (@ARGV==0);

my %gene_region;
open GFF,"$gff" or die $!;
while (<GFF>) {
    chomp;
    my($chr,$start,$end) = (split /\s+/,$_)[0,3,4];
    $gene_region{$chr} .= "$start $end,";
}
close GFF;

open VCF,"$vcf" or die $!;
open CO,">coding_SNP.vcf" or die $!;
open NO,">noncoding_SNP.vcf" or die $!;
while (<VCF>) {
    chomp;
    if (/^#/)
    {
        print CO "$_\n";
        print NO "$_\n";
        next;
    }

    my($chr,$pos) = (split /\s+/,$_)[0,1];
    
    if (judge($chr,$pos) == 1)
    {
        print CO "$_\n";
    }
    else
    {
        print NO "$_\n";
    }

    #my $region = $gene_region{$chr};

}
close VCF;
close CO;
close NO;

sub judge
{
    my($chr,$pos) = @_;
    $pos = int($pos);
    my $value = $gene_region{$chr};
    my @region = split(/\,/,$value);
    
    my $flag = 0;

    foreach my $x (@region)
    {
        my($s,$e) = split(/\s+/,$x);
        $s = int($s);
        $e = int($e);
        if ($pos >= $s and $pos <= $e)
        {
            $flag = 1;
            last;
        }   
    }
    return $flag;
}