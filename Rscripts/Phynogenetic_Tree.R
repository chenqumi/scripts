setwd("C:/Users/quan_chen/Desktop/Rstudio/bw168/Tree")
library(ggtree)
library(ggsci)
library(ape)
# read group.lst
df <- read.table('bw168.lst',header = T)
xz <- read.table('xz.lst',header = T)
ygc <- read.table('ygc.lst',header = T)
sgn <- read.table('sgn.lst',header = T)
 
groupInfo <- list(xz,ygc,sgn)

df1 <- df[which(df$Group=="YGC"),]
a <- as.vector(df1$Sample)
df2 <- df[which(df$Group=="SGN"),]
b <- as.vector(df2$Sample)
df3 <- df[which(df$Group=="XZ"),]
c <- as.vector(df3$Sample)

groupInfo <- list("YGC"=a,"SGN"=b,"XZ"=c)

# read tree
tree <- read.nexus(file = 'tree168')
tree <- groupOTU(tree,groupInfo)

col <- c("#FF9900","#009933","#9900FF")

ggtree(tree,layout = "fan",aes(color=group),size=0.5)+
  geom_tiplab(aes(angle=angle,color=group),size=1.2,offset=1)+
  theme(legend.position = "right",legend.title = element_blank(),legend.text = element_text(size=5))+
  #geom_strip(taxa1='XZ-32',taxa2='XZ-4',barsiz=1.5,offset = 8,color = "#009933") +
  #geom_strip(taxa1='SC-19',taxa2='HB-8', barsiz=1.5,offset = 8,color = "#9900FF") +
  #geom_strip(taxa1='SNX-5',taxa2='SNX-14', barsiz=1.5,offset = 8,color = "#FF9900") +
  #geom_strip(taxa1=1,taxa2=39,label = "SGN",angle=18,barsiz=1.5,offset = 3,offset.text = 4, color = "#FF9900",hjust = 1,fontsize = 3.6) +
  #geom_strip(taxa1=40,taxa2=105,label = "YGC",angle=55,barsiz=1.5,offset = 3,offset.text = 4, color = "#9900FF",hjust = 1,fontsize = 3.6) +
  #geom_strip(taxa1=106,taxa2=120,label = "XZ",angle=295,barsiz=1.5,offset = 3,offset.text = 4, color = "#009933",hjust = 0.5,fontsize = 3.6) +
  scale_color_manual(values = col)
ggsave("bw168_4.png",dpi=600,height=8,width=15,units="cm")
