#!/usr/bin/perl
#================================================
#
#         Author: piemon
#          Email: shichunwei@1gene.com.cn
#         Create: 2016-12-12 17:01:37
#    Description: -
#
#================================================
use strict;
use warnings;
use File::Basename;
use Cwd "abs_path";
use Getopt::Long;

my ($snpindex,$outdir,$delta,$sample1,$sample2,$reverse,$scatter,$threshold);
GetOptions(
    'index|i=s' => \$snpindex,
    'outdir|o=s' => \$outdir,
    'delta|d=s' => \$delta,
    'sample1|s1=s' => \$sample1,
    'sample2|s2=s' => \$sample2,
    'reverse|r+' => \$reverse,
    'scatter|s+' => \$scatter,
    'threshold|t=s' => \$threshold, 
);
my $usage=<<U;
	usage:
		-index|i: snpindex file created by BSA_index2slidewindows.pl[required]
		-delta|d: delta file[required]
		-threshold|t: threshold value.[required]
		-sample1|s1: sample1 flag. the order should be the same as snpindex file. default is S.
		-sample2|s2: sample2 flag. default is R.
		-outdir|o: outfile directory.
		-reverse|r: if exists, change the orientation of delta snp-index.
		-scatter|s: if exists, add scatter into the picture.
	eg:
		perl BSA_slidewindows_draw.pl -i snpindex.txt -d delta.txt -t 0.5 -s -r	
U
if ($snpindex and $delta and $threshold){
	print "analysis start...\n";
}
else{
	print $usage and exit;
}

$snpindex = abs_path($snpindex);
$delta = abs_path($delta);
$outdir ||= './';
$outdir = abs_path($outdir);
$sample1 ||= 'S';
$sample2 ||= 'R';

open T,'>',"$outdir/slidewindows.R" or die $!;
my $delta_SnpIndex = "delta_SnpIndex";
if ($reverse){
	$delta_SnpIndex = "0-delta_SnpIndex";
}
my $script =<<U;
setwd('$outdir')
df<-read.table('$snpindex',header=T)
ef<-read.table('$delta',header = T)
library('ggplot2')
require(grid)
require(ggplot2)
# axis
axis_theme<-theme(
  axis.title=element_text(
    #family=NULL,
    face = "bold", #字体("plain", "italic", "bold", "bold.italic")
    colour = "red", #字体颜色
    size = 10,#字体大小
    hjust = .5, #调整轴标题1：纵轴靠上，横轴靠右；0.5居中；0：纵轴靠下，横轴靠左
    vjust = .5, #1：靠图边框；0靠近轴线；.5居中
    angle = 0 #为什么只对横轴标题有作用？
  ),
  axis.title.x=element_text(colour="black"),#x轴标题设置，优先级高于axis.title
  axis.title.y=element_text(colour="black"),#同上
  axis.text=element_text(colour="black"),#设置坐标轴刻度数字
  axis.text.x=element_text(colour="black"),#优先级高于aixis.text
  axis.text.y=element_text(colour="black"),#同上
  axis.ticks=element_line(#坐标轴刻度线的设置
    colour="red",
    size=.5,
    linetype=1,
    lineend=1),
  axis.ticks.x=element_line(colour="black"),#优先级高于axis.ticks
  axis.ticks.y=element_line(colour="black"),#同上
  axis.ticks.length=unit(.4,"lines"),#设置刻度线的高度
  axis.ticks.margin=unit(.4,"cm"),#设置刻度数字与刻度线的距离
  axis.line=element_line(#设置轴线
    colour="red"),
  axis.line.x=element_line(colour="black"),#设置x轴线，优先于axis.line
  axis.line.y=element_line(colour="black"))#类似axis.line.x

# without points 
a<-ggplot(df)+
  geom_line(aes(x=RealPos,y=W\_SnpIndex),df) +
  facet_grid(.~Chromosome, scales = "free") + 
  ylab('$sample1\_SNP-index')+xlab('')+
  theme(panel.background = element_rect(fill = "white"))+axis_theme

b<-ggplot(df)+
  geom_line(aes(x=RealPos,y=M\_SnpIndex),df) +
  facet_grid(.~Chromosome, scales = "free") + 
  ylab('$sample2\_SNP-index')+xlab('')+
  theme(panel.background = element_rect(fill = "white"))+axis_theme

c<-ggplot(df)+
  geom_line(aes(x=RealPos,y=$delta_SnpIndex),df) +
  ylab(expression(paste(Delta,"SNP-index($sample1-$sample2)"))) +xlab('Position')+
  facet_grid(.~Chromosome, scales = "free")+
  geom_line(aes(x=RealPos,y=$threshold,color=I('red')),df) +
  theme(panel.background = element_rect(fill = "white"))+axis_theme\n
U
print T $script;


$script=<<U;
# with points 
a<-ggplot(ef)+geom_point(aes(x=Pos,y=W_snpindex,color=I("pink")),size=0.5,position="jitter")+
  geom_line(aes(x=RealPos,y=W_SnpIndex),df) +
  facet_grid(.~Chromosome, scales = "free") + 
  ylab('$sample1\_SNP-index')+xlab('')+
  theme(panel.background = element_rect(fill = "white"))+axis_theme

b<-ggplot(ef)+geom_point(aes(x=Pos,y=M_snpindex,color=I("pink")),size=0.5,position="jitter")+
  geom_line(aes(x=RealPos,y=M_SnpIndex),df) +
  facet_grid(.~Chromosome, scales = "free") + 
  ylab('$sample2\_SNP-index')+xlab('')+
  theme(panel.background = element_rect(fill = "white"))+axis_theme

c<-ggplot(ef)+geom_point(aes(x=Pos,y=$delta_SnpIndex,color=I("pink")),size=0.5,position="jitter")+
  geom_line(aes(x=RealPos,y=$delta_SnpIndex),df) +
  ylab(expression(paste(Delta,"SNP-index"))) +xlab('Position')+
  geom_line(aes(x=RealPos,y=$threshold,color=I('red')),df)+
  facet_grid(.~Chromosome, scales = "free")+
  theme(panel.background = element_rect(fill = "white"))+axis_theme\n
U
print T $script if ($scatter);

$script =<<U;
# output 
png(filename="changmi.png",width = 960,height = 720)
grid.newpage()  ##新建页面
pushViewport(viewport(layout = grid.layout(3,1))) ####将页面分成2*2矩阵
vplayout <- function(x,y){
  viewport(layout.pos.row = x, layout.pos.col = y)
}
print(a, vp = vplayout(1,1))
print(b, vp = vplayout(2,1))
print(c, vp = vplayout(3,1))
dev.off()
U
print T $script;

#system("/nfs2/pipe/Re/Software/bin/Rscript $outdir/slidewindows.R");
#system("rm $outdir/slidewindows.R");
