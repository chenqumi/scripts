# @szj^16Jul19
dd <- read.delim('format.4dtv.xls', as.is = T)
require('ggplot2')
png("4dtv_R.png",2000,1100,res=300)

per1 <- sapply(2:(nrow(dd) - 1), function(i) mean(dd$per[(i - 0.5):(i + 0.5)]))
dd1 <- cbind(dd[2:(nrow(dd) - 1), ], per1)

per2 <- sapply(2:(nrow(dd1) - 1), function(i) mean(dd1$per1[(i - 0.5):(i + 0.5)]))
dd2 <- cbind(dd1[2:(nrow(dd1) - 1), ], per2)

imax <- which.max(dd2$per2)
new_row <- c(name = dd2$name[imax], pos = mean(dd2[(imax - 1):(imax + 1), "pos"]), per2 = mean(dd2[(imax - 1):(imax + 1), "per2"]))
dd3 <- rbind(dd2[1:imax, c('name', 'pos', 'per2')], new_row, dd2[(imax + 1):nrow(dd2), c('name', 'pos', 'per2')])
Classify=dd2$name
ggplot(dd2, aes(x = pos, y = per2, group = Classify))+
  stat_smooth(aes(color = Classify), method = 'loess', se = F, span = 0.1) +xlab("4dTv distance (corrected for multiple substitutions)")+ylab("Percentage of gene pairs")+xlim(0,1.5) +
  theme_classic()+
  theme(axis.line.x = element_line(color="black"),
        axis.line.y = element_line(color="black"),
        legend.text = element_text(face = 'italic'))
dev.off()