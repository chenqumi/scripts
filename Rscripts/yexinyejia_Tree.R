setwd("C:/Users/quan_chen/Desktop")
library(ggtree)
library(ggsci)
library(ape)

tree <- read.nexus(file = 'y121')
#data(tree)
groupInfo <- split(tree$tip.label, gsub("-\\w+", "", tree$tip.label))
tree <- groupOTU(tree, groupInfo)
pal <- rainbow(26)
#pal <- c("#e32322","#f4e500","#2671b2","#008e5b","#f19101","#6d3889","#fdc60b","#ea621f","#c4037d","#444e99","#0696bb","#8cbb26","#e32322","#f4e500","#2671b2","#008e5b","#f19101","#6d3889","#fdc60b","#ea621f","#c4037d","#444e99","#0696bb","#8cbb26","#8cbb26")
ggtree(tree,layout = 'fan',aes(color=group),size=1)+
  #geom_text2(aes(subset=!isTip, label=node), hjust=-.3)+
  geom_tiplab(aes(angle=angle),offset=0.5,size=2)+
  #geom_tippoint(aes(color=group,angle=angle),size=2)+
  theme(legend.position = "right")+
  theme(legend.title=element_blank())+
  #geom_strip(taxa1='XZ-32',taxa2='SC-7',barsiz=2,offset = 10,color = "#2671b2") +
  #geom_strip(taxa1='XZ-20',taxa2='SC-7',barsiz=2,offset = 10,color = "#2671b2") +
  #geom_strip(taxa1='GZ-26',taxa2='GZ-27',barsiz=2,offset = 10,color = "#2671b2") +
  #geom_strip(taxa1='GZ-37',taxa2='XZ-11',barsiz=2,offset = 10,color = "#2671b2")+
  #geom_cladelabel( color='#ED0000FF',barsiz=2)+
  #geom_cladelabel(color='#925E9FFF',barsiz=2) +
  #geom_cladelabel(node=31, label="B", align=T, color='#42B540FF',offset=0.05, offset.text=0.01,barsiz=2)+
  #scale_shape_manual(values=sh)+
  scale_color_manual(values = pal)

ggsave("y121.pdf")
