setwd("C:/Users/quan_chen/Desktop")
T <- venn.diagram(list(A=A,B=B,C=C),filename = NULL,lwd=1,lty=2,col=c('#33FFFF','#FF0033','#FFFF33'),fill = ('#33FFFF','#FF0033','#FFFF33'),cat.col = ('#33FFFF','#FF0033','#FFFF33'),reverse = TRUE)
grid.draw(T)

T <- draw.triple.venn(area1 = 115010,area2 = 137569,area3 = 125551
,n12 = 98982,n23 = 114897,n13 = 91413,n123 = 87017
,category = c('XZ','YGC','SGN')
,col=c('#0099FF','#CC33FF','#00FF66')
,fill = c('#0099FF','#CC33FF','#00FF66')
,cat.col = c('#0099FF','#CC33FF','#00FF66'),reverse = TRUE)
grid.draw(T)
