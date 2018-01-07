#!/usr/bin/perl -w 
#yuewei@1gene.com.cn 2016.1.19
use strict;
use Getopt::Long;
use FindBin qw($Bin);
use Cwd qw(abs_path getcwd);
BEGIN {
    push (@INC,"$Bin");
}
use Qsub;


my ($list) = @ARGV;
my ($u,$g);
GetOptions(
		"mutation_rate|u:s"=>\$u,
		"years_per_generation|g:i"=>\$g,
);
$u = "0.53e-8" if (!defined $u);
$g = 1 if (!defined $g);

die "\nusage: perl $0 <list.psmcfa> -u <mutation_rate|[0.53e-8]> -g <years_per_generation|[1]>\n\n" if (@ARGV==0);

# scripts
#======================================================================================
my $psmc = "/nfs3/onegene/user/group1/guolihua/Test_soft/PSMC/psmc-master/psmc";
my $psmc2history = "/nfs3/onegene/user/group1/guolihua/Test_soft/PSMC/psmc-master/utils/psmc2history.pl";
my $history2ms = "/nfs3/onegene/user/group1/guolihua/Test_soft/PSMC/psmc-master/utils/history2ms.pl";
my $psmc_plot = "/nfs3/onegene/user/group1/guolihua/Test_soft/PSMC/psmc-master/utils/psmc_plot.pl";

my $splitfa = "/nfs3/onegene/user/group1/guolihua/Test_soft/PSMC/psmc-master/utils/splitfa";
#===============================================================================================
#
#qsub parameters
#=============================================
#
my $outdir = "Shell";
my $memory = "5G";
my $thread = 1;
my $queue = "dna.q,rna.q,reseq.q,all.q";
my $project = "og";
my $max_job = 20;
my $pro_name = "psmc";
#
#==============================================
my $cwd = getcwd();
my $dir_shell = "$cwd/Shell";
mkdir "$dir_shell";
#==============================================
#
my $shell_psmc = "psmc.sh";
my $shell_boot = "bootstrap.sh";
open PSMC, ">$shell_psmc" or die "$!";
open BOOT, ">$shell_boot" or die "$!";
open LIST, "$list" or die "$!";
while(<LIST>)
{
	chomp;
	my $psmcfa = $_;
	my $ff = (split /\//,$psmcfa)[-1];
	my $name = (split /\./,$ff)[0];
	# psmc shell
	my $cmd_psmc = "$psmc -N25 -t15 -r5 -p \"4+25*2+4+6\" -o $name.psmc $psmcfa && echo $name.psmc job done && ";
	$cmd_psmc .= "$psmc2history $name.psmc |$history2ms > $name\_ms_cmd.sh && echo $name.history job done && ";
	$cmd_psmc .= "export PATH=/nfs3/onegene/user/group1/guolihua/soft/bin:\$PATH && export PATH=/nfs/biosoft/latex/2014/bin/x86_64-linux/:\$PATH && ";
	$cmd_psmc .= "$psmc_plot -p -u $u -g $g -R $name $name.psmc && echo $name.plot job done";
	print PSMC "$name\_psmc.sh\t$cmd_psmc\n";
	#print PSMC "echo start time\ndate\n";
	#print PSMC "$psmc -N25 -t15 -r5 -p \"4+25*2+4+6\" -o $name.psmc $psmcfa && echo $name.psmc job done\n";
	#print PSMC "$psmc2history $name.psmc |$history2ms > $name\_ms_cmd.sh && echo $name.history job done\n";
	#print PSMC "export PATH=/nfs3/onegene/user/group1/guolihua/soft/bin:\$PATH\nexport PATH=/nfs/biosoft/latex/2014/bin/x86_64-linux/:\$PATH\n";
	#print PSMC "$psmc_plot -p -u 0.53e-8 -g 1 -R $name $name.psmc && echo $name.plot job done\n";
	#print PSMC "echo end time\ndate\n";

	# bootstrap shell
	my $cmd_boot = "$splitfa $psmcfa > split.$name.psmcfa && echo $name.split job done && ";
	$cmd_boot .= "/usr/bin/seq 100 | /usr/bin/xargs -i echo $psmc -N25 -t15 -r5 -b -p \"4+25*2+4+6\" -o round-{}.$name.psmc split.$name.psmcfa |sh && echo $name.bootstrap job done && ";
	$cmd_boot .= "cat $name.psmc round-*$name.psmc > combined.$name.psmc && ";
	$cmd_boot .= "export PATH=/nfs3/onegene/user/group1/guolihua/soft/bin:\$PATH && ";
	$cmd_boot .= "export PATH=/nfs/biosoft/latex/2014/bin/x86_64-linux/:\$PATH && ";
	$cmd_boot .= "$psmc_plot -p -u $u -g $g -R combined.$name combined.$name.psmc && echo $name.plot job done";
	print BOOT "$name\_bootstrap.sh\t$cmd_boot\n";
	#print BOOT "echo start time\ndate\n";
	#print BOOT "$splitfa $psmcfa > split.$name.psmcfa && echo $name.split job done\n";
	#print BOOT "/usr/bin/seq 100 | /usr/bin/xargs -i echo $psmc -N25 -t15 -r5 -b -p \"4+25*2+4+6\" -o round-{}.$name.psmc split.$name.psmcfa |sh && echo $name.bootstrap job done\n";
	#print BOOT "cat $name.psmc round-*$name.psmc > combined.$name.psmc\n";
	#print BOOT "export PATH=/nfs3/onegene/user/group1/guolihua/soft/bin:\$PATH\n";
	#print BOOT "export PATH=/nfs/biosoft/latex/2014/bin/x86_64-linux/:\$PATH\n";
	#print BOOT "$psmc_plot -p -u 0.53e-8 -g 1 -R combined.$name combined.$name.psmc && echo $name.plot job done\n";
	#print BOOT "echo end time\ndate\n";
}
close LIST;
close PSMC;
close BOOT;

qsub($shell_psmc, $dir_shell, $memory, $thread,
         $queue, $project, $pro_name, $max_job);

qsub($shell_boot, $dir_shell, $memory, $thread,
         $queue, $project, $pro_name, $max_job);