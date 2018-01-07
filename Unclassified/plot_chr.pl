#chenqumi@20170425
use warnings;
use strict;
use File::Basename;
use FindBin qw($Bin);
use Cwd qw(abs_path getcwd);

my ($g1,$g2,$g1_n,$g2_n,$fst,$threshold,$pi1,$pi2) = @ARGV;
die "perl $0 I:<group1.region.merge> <group2> <g1_name> <g2_name> <fst> <fst_threshold> <pi_threshold1> <pi_threshold2>" if (@ARGV==0);
#
# comfirm selected Chrom
#=======================
my %hash;
&plot($g1);
&plot($g2);
#
# put Chrom name in a vector
#===========================
my @arr;
foreach my $k (keys %hash) {
	my $vector = "\"$k\"";
	push (@arr,$vector);
}

my$vector = join(",",@arr);
$vector = "c\($vector\)\n";
#
# deal fst file
#===========================
my $cwd = getcwd();
$fst = abs_path($fst);
`grep -v "#" $fst > $cwd/$g1_n\_$g2_n.log`;
#
# R script
#===========================
open R,">script.R" or die $!;
print R
'library(ggplot2)
library(ggsci)
';
print R
"\n# read data
df <- read.table(\"$cwd/$g1_n\_$g2_n.log\",header = F)";
print R
'
colnames(df) <- c("num","chr","start","end","Piratio","Fst")
df$start <- df$start/1e06
';
print R 
"# plot fst
for (i in $vector)";
print R
'
{
	dfi <- df[which(df$chr==i),]
  	ggplot(dfi)+
    	geom_line(aes(x=start,y=Fst),size=0.4)+
    	#geom_hline(yintercept = 0,size=0.3,linetype="dashed")+
    	#geom_hline(yintercept = -0.5,size=0.3,linetype="dashed")+';
print R "\n\tgeom_hline(yintercept = $threshold,size=0.3,linetype=\"dashed\")+\n";
print R
'    	theme_bw() +
    	theme(
      		axis.text.x = element_text(color = "black",size=7),
      		axis.text.y = element_text(color = "black",size=7),
      		axis.title = element_text(size=7),
      		panel.border = element_blank(),
      		panel.grid =element_blank(),
      		panel.background = element_rect(fill="white"),
      		legend.position = "none",
      		axis.line.y = element_line(color="black", size = 0.5),
      		axis.line.x = element_line(color="black", size = 0.5),
      		plot.title = element_text(hjust = 0.5,size=7,color="black"))+
		labs(x=paste(i,"(Mb)",sep=""),y=expression(paste(italic("F"),""[ST])),';
print R
"\n\t\ttitle=expression(paste(italic(\"F\"),\"\"[ST],\" between \",\"$g1_n\",\" and \",\"$g2_n\")))+\n";
print R
'		#scale_x_continuous(expand=c(0,0),breaks=seq(0,max(dfi$start)+1,5))+
    	scale_y_continuous(expand=c(0,0),limits = c(0,1))
  	Filename <- paste(i,".fst.png",sep="")  
  	ggsave(Filename,dpi=600,height=8,width=15,units="cm")
}';
print R
"\n\n#plot ln ratio
for (i in $vector)";
print R
'
{
	dfi <- df[which(df$chr==i),]
	ggplot(dfi)+
    	geom_line(aes(x=start,y=Piratio),size=0.4)+
';
print R
"\t\tgeom_hline(yintercept = $pi1,size=0.3,linetype=\"dashed\")+
\t\tgeom_hline(yintercept = $pi2,size=0.3,linetype=\"dashed\")+
";
print R
'	theme_bw()+
	theme(
		axis.text.x = element_text(color = "black",size=7),
		axis.text.y = element_text(color = "black",size=7),
		axis.title = element_text(size=7),
		panel.border = element_blank(),
		panel.grid =element_blank(),
		panel.background = element_rect(fill="white"),
		legend.position = "none",
		axis.line.y = element_line(color="black", size = 0.5),
		axis.line.x = element_line(color="black", size = 0.5),
		plot.title = element_text(hjust = 0.5,size=7,color="black"))+
	labs(x=paste(i," (Mb)",sep=""),y="ln ratio",';
print R
"
\t\ttitle=expression(paste(\"ln ratio (\",theta[pi~$g1_n],\"/\",theta[pi~YGC],\")\",sep = \"\")))
";
print R
'	Filename <- paste(i,".piratio.png",sep="")  
	ggsave(Filename,dpi=600,height=8,width=15,units="cm")
}
';
close R;
#
# fuction
#===========================
sub plot
{
	my$file = shift;
	open FI,"$file" or die $!;
	while (<FI>) {
		chomp;
		next if (/^#/);
		my$chr = (split)[1];
		$hash{$chr} += 1; 
	}
	close FI;
}

