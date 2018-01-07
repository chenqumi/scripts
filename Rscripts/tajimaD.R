setwd('C:/Users/quan_chen/Desktop/Rstudio/selection/tajima/')
library(ggplot2)
library(ggsci)

#读取数据
df <- read.table("xz",header = T)
#test <- c(seq(1:20))
#df$chr <- factor(df$chr, levels=test)
#df$start <- df$start/1e06

#画图-Genomewide
#pal <- c("#e32322","#f4e500","#2671b2","#008e5b","#f19101","#6d3889","#fdc60b","#ea621f","#c4037d","#444e99","#0696bb","#8cbb26")
#pal <- rainbow(91)
#scale_color_manual(values = pal)
ggplot(df)+
  #geom_bar(aes(x=start,y=Fst,colour=factor(chr)),size=0.5,stat="identity")+
  geom_bar(aes(x=BIN_START,y=TajimaD,colour=factor(CHROM)),size=0.05,stat = "identity")+
  facet_grid(.~CHROM,scales = 'free_x',space = 'free_x',switch='x')+
  #geom_hline(yintercept = thresold,size=0.3)+
  #geom_hline(yintercept = -1.673,size=0.3,linetype="dashed",color="#FF0000")+
  #geom_hline(yintercept = 2.556,size=0.3,linetype="dashed",color="#FF0000")+
  geom_hline(yintercept = 0,size=0.3)+
  #geom_hline(yintercept = -1,size=0.8)+
  #geom_vline(xintercept = 0,size=0.2,color="grey")+
  theme_bw()+
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
    #strip.text.x = element_text(size=10),
    strip.text.x = element_blank(),
    legend.position = "none",
    plot.title = element_text(hjust = 0.5,size=10,color="black"),
    axis.line.x = element_line(color = "black",size = 0.5),
    axis.line.y = element_line(color="black", size = 0.5))+
  labs(x="Scaffold",y="Tajima`D")+
  scale_x_continuous(expand=c(0,0))+
  scale_y_continuous(expand=c(0,0),limits = c(-6,6))+
  scale_color_manual(values=rep(c("#FF9900","#009933"),50))
ggsave("xz.tajima.pdf",dpi=300,height=8,width=15,units="cm")

