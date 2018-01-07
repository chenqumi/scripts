use warnings;
use strict;
use File::Basename;
use Cwd qw(abs_path getcwd);

my ($ref,$gff,$snp,$indel) = @ARGV;
die "perl $0 <ref.fa> <gff> <snp.vcf> <indel.vcf>" if @ARGV == 0;

my $cwd = getcwd();
my $SNP = "/p299/user/og03/chenquan1609/Bin/snpEff/snpEff";
my $JAVA = "/lustre/project/og04/shichunwei/biosoft/jre1.8.0_91/bin/java";

$ref = abs_path($ref);
$gff = abs_path($gff);
$snp = abs_path($snp);
$indel = abs_path($indel);
my $ref_name = basename($ref);
my $name = (split(/\./,$ref_name))[0];

chdir "$SNP/data/genomes";
`ln -s $ref $name\.fa`;

mkdir "$SNP/data/$name";
chdir "$SNP/data/$name";
`ln -s $gff genes.gff`;

open CO,">$cwd/add_config" or die $!;
print CO "# $name\n$name\.genome : $name\n";
close CO;

open SH1,">$cwd/update.sh" or die $!;
print SH1 "$JAVA -jar $SNP/snpEff.jar build -gff3 -v $name\n";
close SH1;

open SH2,">$cwd/anno_snp.sh" or die $!;
print SH2 "$JAVA -Xmx4g -jar $SNP/snpEff.jar -csvStats $name\.snp.filter.vcf.csv -ud 1000 $name $snp > $name\.snp.eff.vcf";
close SH2;


open SH3,">$cwd/anno_InDel.sh" or die $!;
print SH3 "$JAVA -Xmx4g -jar $SNP/snpEff.jar -csvStats $name\.indel.filter.vcf.csv -ud 1000 $name $indel > $name\.indel.eff.vcf";
close SH3;
