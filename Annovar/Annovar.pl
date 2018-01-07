use warnings;
use strict;
use Getopt::Long;
use File::Basename;
use FindBin qw($Bin);
use Cwd qw(abs_path getcwd);

my($ref,$sv_lst,$gff,$name) = @ARGV;
die "perl $0 I:<ref.fa> <sv.lst> <.gff> <species_name> -type <brk|lum|cnv>" if @ARGV == 0;

my $type;
GetOptions(
	"type|t:s"=>\$type,
);
# script
#==============================================================================
my $GFF2GP = "/p299/user/og06/pipe/pub/chenli/biosoft/SVannotate/gff3ToGenePred";
my $FA2SEQ = "perl /p299/user/og06/pipe/pub/chenli/biosoft/SVannotate/annovar/retrieve_seq_from_fasta.pl";
my $S2AV = "perl /p299/user/og06/pipe/pub/chenli/biosoft/SVannotate/speedseq2avinput.pl";
my $B2AV = "perl /p299/user/og06/pipe/pub/chenli/biosoft/SVannotate/breakdancer2avinput.pl";
my $C2AV = "perl /p299/user/og06/pipe/pub/chenli/biosoft/SVannotate/cnvnator2avinput.pl";
my $ANNO = "perl /p299/user/og06/pipe/pub/chenli/biosoft/SVannotate/annovar/table_annovar.pl";
my $SVANNO = "perl /p299/user/og03/chenquan1609/Resequencing/script/Annovar/01.SV_anno.pl";
my $SVSTAT = "perl /p299/user/og03/chenquan1609/Resequencing/script/Annovar/02.SV_anno_stat.pl";

# db dir
#================================================================
my $cwd = getcwd();
my $db = "/p299/user/og06/pipe/pub/chenli/biosoft/SVannotate/db";

# parse the type of sv file
#=================================================================
my $vcf2av;
if ($type eq "brk"){
	$vcf2av = $B2AV;
}elsif ($type eq "lum"){
	$vcf2av = $S2AV;
}elsif ($type eq "cnv"){
	$vcf2av = $C2AV;
}else{
	die "type error, it must be one of [bkr,lum,cnv]";
}

# step 1 make db & transform gff file
#=================================================================
$ref = abs_path($ref);
$gff = abs_path($gff);
my $dbname = $name."db";
mkdir "$db/$dbname";
chdir "$db/$dbname";
`ln -s $ref $name\.fa`;
`ln -s $gff $name\.gff`;
`echo $GFF2GP $name\.gff $name\_refGene.txt > gff2GenePred.sh`;
`sh gff2GenePred.sh`;

`echo $FA2SEQ --format refGene --seqfile $name\.fa $name\_refGene.txt --outfile $name\_refGeneMrna.fa > tomRNA.sh`;
`sh tomRNA.sh`;

# step 2 get avinput file
#==============================================================
chdir "$cwd";

my @arr;
open SV,"$sv_lst" or die $!;
open SH1,">sv2av.sh" or die $!;
while (<SV>) {
	chomp;
	my $sample = (split/\./,basename($_))[0];
	push (@arr,$sample);
	mkdir "$sample";
	print SH1 "$vcf2av $_ $sample\.avinput\n";
}
close SV;
close SH1;
`sh sv2av.sh`;

# step 3 annotate
#===================================================================
`ls *.avinput > avinput.lst`;

open AV,"avinput.lst" or die $!;
open SH2,">anno.sh" or die $!;
while (<AV>) {
	chomp;
	my $sample = (split/\./,$_)[0];
	print SH2 "$ANNO $_ $db/$dbname --outfile $sample/$sample --buildver $name --protocol refGene --operation g\n";
}
close AV;
close SH2;
`sh anno.sh`;

# step 4 stat
#===================================================================
foreach my $sam (@arr) {
	chdir "$cwd/$sam";
	my $out1 = "$sam\.sv_anno.xls";
	my $out2 = "$sam\.sv_type.xls";
	`$SVANNO $sam\.$name\_multianno.txt $out1`;
	`$SVSTAT $out1 $out2`;
}
