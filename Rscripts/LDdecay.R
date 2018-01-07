#setwd("C:/Users/quan_chen/Desktop")
setwd("C:/Users/quan_chen/Desktop/max800")
xz <- read.table("XZ.bin")
sgn <- read.table("SGN.bin")
ygc <- read.table("YGC.bin")
pdf("LDD.pdf")
plot(xz[,1]/1000,xz[,2],type="l",col="#009933",main="LD decay",xlab="Distance(Kb)",xlim=c(0,800),ylim=c(0.1,0.8),ylab=expression(r^{2}),bty="n")
lines(sgn[,1]/1000,sgn[,2],col="#FF9900")
lines(ygc[,1]/1000,ygc[,2],col="#9900FF")
legend("topright",c("XZ","SGN","YGC"),col=c("#009933","#FF9900","#9900FF"),cex=1,lty=c(1,1,1),bty="n")
dev.off()




setwd("C:/Users/quan_chen/Desktop/Rstudio/LDdecay/Haploview/dis800_noblock")
xz <- read.table("XZ.result", sep="\t",header=F)
ygc <- read.table("YGC.result", sep="\t",header=F)
sgn <- read.table("SGN.result", sep="\t",header=F)
colnames(xz) <- c('R2','dis')
colnames(ygc) <- c('R2','dis')
colnames(sgn) <- c('R2','dis')
#pdf("ldd.pdf")
plot(xz$dis,xz$R2,type="l",col="#009933",main="LD decay",xlab="Distance(Kb)",xlim=c(0,800),ylim=c(0,0.6),ylab=expression(r^{2}),bty="n")
lines(sgn$dis,sgn$R2,col="#FF9900")
lines(ygc$dis,ygc$R2,col="#9900FF")
legend("topright",c("XZ","SGN","YGC"),col=c("#009933","#FF9900","#9900FF"),cex=1,lty=c(1,1,1),bty="n")
#dev.off()



setwd("C:/Users/quan_chen/Desktop/Rstudio/LDdecay/Plink")
xz <- read.table("xz03.out",header=T)
ygc <- read.table("ygc03.out",header=T)
sgn <- read.table("sgn03.out",header=T)
plot(xz$dis,xz$R2,type="l",col="#009933",main="LD decay",xlab="Distance(Kb)",xlim=c(0,800),ylim=c(0,0.6),ylab=expression(r^{2}),bty="n")
lines(sgn$dis,sgn$R2,col="#FF9900")
lines(ygc$dis,ygc$R2,col="#9900FF")
legend("topright",c("XZ","SGN","YGC"),col=c("#009933","#FF9900","#9900FF"),cex=1,lty=c(1,1,1),bty="n")





setwd("C:/Users/quan_chen/Desktop/max800")
xz <- read.table("XZ.bin",header=T)
ygc <- read.table("YGC.bin",header=T)
sgn <- read.table("SGN.bin",header=T)
xz$Dist=xz$Dist/1000
ygc$Dist=ygc$Dist/1000
sgn$Dist=sgn$Dist/1000
plot(x=xz$Dist,y=xz$Mean_r^2,type="l",col="#009933")
lines(x=sgn$Dist,y=sgn$Mean_r^2,col="#FF9900")
lines(x=ygc$Dist,y=ygc$Mean_r^2,col="#9900FF")
legend("topright",c("XZ","SGN","YGC"),col=c("#009933","#FF9900","#9900FF"),cex=1,lty=c(1,1,1),bty="n")

main="LD decay",xlab="Distance(Kb)",xlim=c(0,800),ylim=c(0,0.8),ylab=expression(r^{2}),bty="n"






setwd("C:/Users/quan_chen/Desktop/max800")
library('ggplot2')
xz <- read.table("XZ.bin",header=T)
ygc <- read.table("YGC.bin",header=T)
sgn <- read.table("SGN.bin",header=T)
ggplot(data = xz)+
  geom_point(aes(x=xz$Dist,y=xz$r2),color = "#009933")+
  geom_point(aes(x=ygc$Dist,y=ygc$r2),color = "#9900FF")+
  geom_point(aes(x=sgn$Dist,y=sgn$r2),color="#FF9900")
