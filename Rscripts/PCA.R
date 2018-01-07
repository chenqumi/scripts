setwd("C:/Users/quan_chen/Desktop/Rstudio/bw168/PCA")
library("ggplot2")
df <- read.table('vector1_2',header = F)
p1 <- df[,2]
p2 <- df[,3]
group <- df[,1]
df2 <- data.frame(x=p1,y=p2)

col <- c("#FF9900","#009933","#9900FF")

ggplot(data=df2,mapping = aes(x=x,y=y,color = group)) +
  geom_point(size=0.5)+
  coord_fixed(ratio = 1/2)+
  scale_x_continuous(limits = c(-0.15,0.1))+
  labs(x="PC1",y="PC2")+
  theme_classic()+
  theme(
    #plot.title = element_text(hjust = 0.5,size = 8),
    #panel.grid =element_blank(),
    axis.text = element_text(size = 8,color = "black"),
    axis.line = element_line(size = 0.5),
    axis.title = element_text(size = 8),
    legend.title = element_blank(),
    legend.position = c(0.9,0.2),
    #legend.position = "right",
    legend.text = element_text(size = 5)
  )+
  scale_color_manual(values = col)

#ggsave("pca200.pdf")
ggsave("bw168_pca_test.png",dpi=600,height=8,width=15,units="cm")    
