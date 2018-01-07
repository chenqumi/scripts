use warnings;
use strict;
use File::Basename;
use FindBin qw($Bin);
use Cwd qw(abs_path getcwd);

=head1 Usage 

 perl split_read_mk_list.pl <fq.lst> <size[5G]>

=head1 Description

 This script split read into sized-block, note that size must be "G"

=head1 fq.lst format:

 lib_name	read
 PE450	read1.fq.gz
 PE450	read2.fq.gz

=cut

my ($fq_lst,$size)=@ARGV;
die `pod2text $0` if @ARGV == 0;
$size ||= "5G";

if($size !~ /(\d+)([G])/){
    die "Error format of split_size";
}else{
    $size = $1 * 10**9 if($2 eq "G");
 }

#========================================
my %rd_hash;
open FI,"$fq_lst" or die $!;

while (my $line_1 = <FI>) {
	my $line_2 = <FI>;
	chomp $line_1;
	chomp $line_2;
	my ($lib_1,$rd_1)=split(/\s+/,$line_1);
	my ($lib_2,$rd_2)=split(/\s+/,$line_2);
	die "Not match" if ($lib_1 ne $lib_2);
	$rd_1 = abs_path($rd_1);
	$rd_2 = abs_path($rd_2);
	&split_read($rd_1,$rd_2,$lib_1,\%rd_hash);
}

close FI;

#======================================
#`ls *.fq > tmp.lst`;
#open TMP,"tmp.lst" or die $!;
#open FO,">split.lst" or die $!;
#while (my $rd1 = <TMP>) {
#	my $rd2 = <TMP>;
#	chomp($rd1);
#	chomp($rd2);
#	$rd1 = abs_path($rd1);
#	$rd2 = abs_path($rd2);
#	my $rd1_n = basename($rd1);
#	$rd1_n =~ /(\S+)_R1_split_(\w+)/;
#	my $lib = $1;
#	my $sp = $2;
#	print FO "$lib\_split\_$sp\t$rd1\n";
#	print FO "$lib\_split\_$sp\t$rd2\n";
#}
#close TMP;
#close FO;

open FO,">>split.lst" or die $!;
foreach my $k (keys %rd_hash){
	my $v = $rd_hash{$k};
	$k =~ /(\S+)_R1_(\w+)/;
	my $sp = (split(/\./,$2))[0];
	my $lib = "$1\_$sp";
	$k = abs_path($k);
	$v = abs_path($v);
	print FO "$lib\t$k\n";
	print FO "$lib\t$v\n";
}
close FO;

#======================================
sub split_read{

	my ($r1,$r2,$lib,$rd_h) = @_;
	
	my $index = 0;
	my $base = 0;
	
	my $split_r1 = "$lib\_R1\_split\_$index.fq";
	my $split_r2 = "$lib\_R2\_split\_$index.fq";
	
	#$file =~ /\.gz$/ && $file !~ /\>/
	if ($r1 =~ /\.gz$/ && $r1 !~ /\>/){
		open R1,"gzip -dc $r1 |" or die $!;
		
	}else{
		open R1,"$r1" or die $!;
	}

	if ($r2 =~ /\.gz$/ && $r2 !~ /\>/){
		open R2,"gzip -dc $r2 |" or die $!;
		
	}else{
		open R2,"$r2" or die $!;
	}

	#open R1,"gzip -dc $r1 |" or die $!;
	#open R2,"gzip -dc $r2 |" or die $!;
	open O1, ">$split_r1" or die $!;
	open O2, ">$split_r2" or die $!;

	while (my $id_1 = <R1>){
		my $seq_1 = <R1>;
	    <R1>;
	    my $qual_1 = <R1>;
	    # rd_2
	    my $id_2 = <R2>;
		my $seq_2 = <R2>;
	    <R2>;
	    my $qual_2 = <R2>;

	    chomp $seq_1;
	    my $len = length($seq_1);
	    $base += $len;

	    if ($base >= $size){
	    	close O1;
	    	close O2;
	    	$rd_h->{$split_r1}=$split_r2;
	        $index ++;
	        $base = 0;
	        $split_r1 = "$lib\_R1\_split\_$index.fq";
	        $split_r2 = "$lib\_R2\_split\_$index.fq";
	        open O1, ">$split_r1" or die $!;
	        open O2, ">$split_r2" or die $!;   
	    }
	    print O1 "$id_1";
	    print O1 "$seq_1\n";
	    print O1 "+\n";
	    print O1 "$qual_1";

	    print O2 "$id_2";
	    print O2 "$seq_2";
	    print O2 "+\n";
	    print O2 "$qual_2";
	}
	$rd_h->{$split_r1}=$split_r2;
	close R1;
	close R2;
	close O1;
	close O2;
}
