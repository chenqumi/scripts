#chenqumi@20171129
use warnings;
use strict;
use File::Basename;
use FindBin qw($Bin);
use Cwd qw(abs_path getcwd);

my ($read,$num,$out) = @ARGV;
die "perl $0 <read.fq.gz> <former seq num> <outfile>" if (@ARGV==0);

my $count = 0;
open RD,"gzip -dc $read |" or die $!;
open OT,"| gzip >$out" or die $!;
while (my $id = <RD>) {
    my $seq = <RD>;
    <RD>;
    my $qual = <RD>;
    print OT "$id";
    print OT "$seq";
    print OT "+\n";
    print OT "$qual";
    $count ++;
    last if ($count >= $num);
}
close RD;

