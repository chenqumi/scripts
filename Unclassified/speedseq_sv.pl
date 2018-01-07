use warnings;
use strict;
use File::Basename;
use Cwd qw(abs_path getcwd);



my($ref,$fq_lst) = @ARGV;
die "perl $0 I:<ref.fa> <fq.lst>" if (@ARGV==0);

my $BWA = "/lustre/project/og04/shichunwei/biosoft/bwa-0.7.13/bwa";
my $SAMTOOLS = "/lustre/project/og04/shichunwei/biosoft/samtools-1.3/samtools";
my $SPEEDSEQ = "/lustre/project/og04/pub/biosoft/speedseq/bin/speedseq";

my $cwd = getcwd();
$ref = abs_path($ref);

# step1 samtools faidx ref.fa
`echo $SAMTOOLS faidx $ref > $cwd/faidx.sh`;

# step2 Align & get bam files
open LST,"$fq_lst" or die $!;
open OT,">call_sv.sh" or die $!;
while (my $rd1 = <LST>) {
	my $rd2 = <LST>;
	chomp($rd1);
	chomp($rd2);
	$rd1 = abs_path($rd1);
	$rd2 = abs_path($rd2);
	my $prefix = (split /_/,basename($rd1))[0];
	my $head = "\@RG\\tID:$prefix\\tSM:$prefix\\tLB:$prefix";
	my $cmd = "$SPEEDSEQ align -v -t 8 -o $cwd/$prefix -R \"$head\" ";
	$cmd .= "$ref $rd1 $rd2 &&\n";
	$cmd .= "$SPEEDSEQ sv -v -t 4 -o $cwd/$prefix ";
	$cmd .= "-R $ref -B $cwd/$prefix\.bam -S $cwd/$prefix\.splitters.bam -D $cwd/$prefix\.discordants.bam\n";
	print OT "$cmd\n";
}
close LST;
close OT;






