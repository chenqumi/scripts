#chenqumi@20171127
use warnings;
use strict;
use POSIX;
use File::Basename;
use FindBin qw($Bin);
use Cwd qw(abs_path getcwd);

my ($ref,$chrom,$blocks,$outdir) = @ARGV;
die "perl $0 <ref.fa> <pseudo chrom num> <splited blocks num> <outdir>" if (@ARGV != 4);
#
# ======================================
my $cwd = getcwd();
$outdir = abs_path($outdir);
my $file = "$outdir/Chrom1.fa";
if (-e $file){
    `rm $outdir/Chrom*.fa`;
}

#
# ======================================
my $num = POSIX::ceil($chrom/$blocks);
my $actual_num = POSIX::ceil($chrom/$num);

if ($actual_num != $blocks)
{
    print "Notice: The genome will be split into $actual_num blocks\n";
}
#
# ======================================
$/ = ">";
my $count = 1;
my $index = 1;
my %hash;
open REF,"$ref" or die $!;
while (<REF>) {
    chomp;
    next if ($_ eq "");
    my $outfile = "$outdir/Chrom${index}\.fa";
    $hash{$outfile} = 1;
    open OT,">>$outfile" or die $!;
    print OT ">$_\n";
    close OT;
    if ($count == $num)
    {
        $index ++;
        $count = 0;
    }
    $count ++;
}
close REF;
$/ = "\n";

foreach my $x (keys %hash) {
    my $dir = (split /\./,basename($x))[0];
    my $cmd = "mv $x $cwd/$dir/Index";
    mkdir ("$cwd/$dir");
    mkdir ("$cwd/$dir/Index");
    system("$cmd");
}