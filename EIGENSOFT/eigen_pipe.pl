#chenqumi@20170831
use warnings;
use strict;
use Getopt::Long;
use File::Basename;
use FindBin qw($Bin);
use Cwd qw(abs_path getcwd);

my ($vcf) = @ARGV;
die 
"
perl $0 <vcf> -k [10]

    k: number of principal components to output <int> [10]
"
if (@ARGV==0);

my $k;
GetOptions(
    "k:i" => \$k,
);
$k ||= 10;

my $FORMAT = "python $Bin/vcf2eigenformat.py";
my $EIGEN_bin = "/p299/user/og03/chenquan1609/Bin/EIGENSOFT/EIG-6.1.4/bin";

$vcf = abs_path($vcf);
#`$FORMAT $vcf`;

my $vcf_name = (split /.vcf/, basename($vcf))[0];
my $geno = "$vcf_name\.geno";
my $snp = "$vcf_name\.snp";
my $ind = "$vcf_name\.ind";

my $env = "export EIGEN=\"$EIGEN_bin\"\n";
$env .= "export PATH=\$EIGEN:\$PATH";

my $smartpca = "perl $EIGEN_bin/smartpca.perl ";
$smartpca .= "-i $geno -a $snp -b $ind ";
$smartpca .= "-k $k -o pca -p result.plot ";
$smartpca .= "-e pca.eval -l result.log -m 0";

open SH,">eigen_pca.sh" or die $!;
print SH "$FORMAT $vcf\n";
print SH "$env\n";
print SH "$smartpca\n";
close SH;
