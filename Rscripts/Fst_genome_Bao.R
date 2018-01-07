setwd('C:/Users/quan_chen/Desktop/test/xz_ygc')
library(ggplot2)
library(ggsci)

#读取数据
df <- read.table("XZ_YGC.piratio.fst",header = T)
#colnames(df) <- c("Chr","Start","End","Num","W","IND_TRJ","TEJ_TRJ")
#df <- df[which(df$Fst>=0),]
test <- c(seq(1:12))
df$chr <- factor(df$chr, levels=test)
df$start <- df$start/1e06
#df$Fst <- df$TEJ_TRJ-df$IND_TRJ

#计算全基因组阈值
h2 <- hist(df$Fst,breaks=1000)
plot(ecdf(df$Fst),axes =T,ylab = "Cumulative",lwd=2)

t <- ecdf(df$Fst)
inv_ecdf <- function(f){ 
  x <- environment(f)$x 
  y <- environment(f)$y 
  approxfun(y, x) 
} 

g <- inv_ecdf(t) 
thresold <- g(0.95) 

#画图-Genomewide
ggplot(df)+
  geom_line(aes(x=Start,y=Fst,color=Chr_n),size=0.5)+
  facet_grid(~Chr_n,scale="free_x",space="free_x",switch='x') +
  #geom_hline(yintercept = thresold,size=0.3)+
  geom_hline(yintercept = -0.5,size=0.3,linetype="dashed")+
  geom_hline(yintercept = 0.5,size=0.3,linetype="dashed")+
  geom_hline(yintercept = 0,size=0.3,linetype="dashed")+
  geom_hline(yintercept = -1,size=0.8)+
  geom_vline(xintercept = 0,size=0.2,color="grey")+
  theme_bw() +
  theme(
    axis.text.x = element_blank(),
    axis.text.y = element_text(color = "black",size=8),
    axis.title = element_text(size=12),
    axis.ticks.x = element_blank(),
    panel.border = element_blank(),
    panel.spacing.x = unit(0,"lines"),
    panel.grid =element_blank(),
    panel.background = element_rect(fill="white"),
    strip.background = element_blank(),
    strip.text.x = element_text(size=10),
    legend.position = "none",
    plot.title = element_text(hjust = 0.5,size=10,color="black"),
    axis.line.y = element_line(color="black", size = 0.8))+
  labs(x="Chromosome",y=expression(paste(Delta,italic("F"),""[ST])),
       title=expression(paste(Delta,italic("F"),""[ST]," between ",italic("tropical japonica-temperate japonica")," and ",
                              italic("indica-tropical japonica")," based on RiceVarMap dataset")))+
  scale_x_continuous(expand=c(0,0))+
  scale_y_continuous(expand=c(0,0),limits = c(-1,1),breaks=seq(-1,1,0.5))+
  scale_color_manual(values=rep(c("#EEA236FF","#357EBDFF"),6))
# scale_color_manual(values=rep(c("#EC5F67","#FAC863","#99C794","#6699CC"),3))
ggsave("delta_fst_IND_TRJ_Genomewide_Fst.png",dpi=600,height=8,width=20,units = "cm")

#画图-分染色体
for (i in 1:12)
{
  dfi <- df[which(df$chr==i),]
  ggplot(dfi)+
    geom_line(aes(x=start,y=Fst),size=0.4)+
    geom_hline(yintercept = 0,size=0.5,linetype="dashed")+
    geom_hline(yintercept = -0.5,size=0.3,linetype="dashed")+
    geom_hline(yintercept = 0.5,size=0.3,linetype="dashed")+
    geom_hline(yintercept = 0,size=0.3,linetype="dashed")+
    theme_bw() +
    theme(
      axis.text.x = element_text(color = "black",size=10),
      axis.text.y = element_text(color = "black",size=10),
      axis.title = element_text(size=12),
      panel.border = element_blank(),
      panel.grid =element_blank(),
      panel.background = element_rect(fill="white"),
      legend.position = "none",
      axis.line.y = element_line(color="black", size = 0.8),
      axis.line.x = element_line(color="black", size = 0.8),
      plot.title = element_text(hjust = 0.5,size=7,color="black"))+
    labs(x=paste("Chromosome ",i,"(Mb)",sep=""),y=expression(paste(Delta,italic("F"),""[ST])),
         title=expression(paste(Delta,italic("F"),""[ST]," between ",italic("tropical japonica-temperate japonica")," and ",
                                italic("indica-tropical japonica")," based on RiceVarMap dataset")))+
    scale_x_continuous(expand=c(0,0),breaks=seq(0,max(dfi$Start)+1,5))+
    scale_y_continuous(expand=c(0,0),limits = c(-1,1),breaks=seq(-1,1,0.5))
  FileName <- paste("delta_TRJ_TEJ_IND_TRJ_Chromosome_",i, "_Fst.png", sep = "")
  ggsave(FileName,dpi=600,height=8,width=15,units="cm")
}









