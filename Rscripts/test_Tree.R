setwd("C:/Users/quan_chen/Desktop")
library(ggtree)
library(ggsci)
library(ape)

df <- read.table('bw_sam171.lst',header = T)
#df <- read.table('bw_sam200.lst',header = T)
row.names(df) <- NULL
tree <- read.nexus(file = 'bw171_tree')
#tree <- read.nexus(file = 'bw200_tree')
p <- ggtree(tree,layout = "fan",aes(color=Group),size=0.8)
#print(df)
P <- p %<+% df +
  geom_tiplab(aes(angle=angle,color=Group),size=2,offset=1.5)
  #geom_tippoint(aes(size=0.7,color=Group),alpha=0.25)
P+theme(legend.position = "right")
ggsave("bw171.pdf")
