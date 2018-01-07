setwd('C:/Users/quan_chen/Desktop')
df <- read.table("stat.txt", header = TRUE)
dcols <- densCols(df, colramp=colorRampPalette(c("black", "white")), nbin = 1000)
df$dens <- col2rgb(dcols)[1,] + 1L
cols <- colorRampPalette(c("#000099", "#00FEFF", "#45FE4F", "#FCFF00", "#FF9400", "#FF3100"), space = "Lab")(256)
df$col <- cols[df$dens]
png("GC_depth.png", width = 20, height = 18, units = "cm", res = 300)
par(lwd=2,cex=1.5)
plot(avgDepth ~ GCpercent, data=df[order(df$dens),], col=col, ylab="Average depth (X)", xlab="GC content (%)", lwd = 0.5, pch = 20, ylim = c(0,150), xlim = c(10,80))
dev.off()
