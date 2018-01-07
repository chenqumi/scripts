setwd('C:/Users/quan_chen/Desktop/Buckwheat/Admixture/result/')

k2 <- read.table("k2.xls",header = T)
k3 <- read.table("k3.xls",header = T)
k4 <- read.table("k4.xls",header = T)
k5 <- read.table("k5.xls",header = T)
#k6 <- read.table("k6.xls",header = T)
#k7 <- read.table("k7.xls",header = T)

sample <- k2[,1]
sam_name <- as.vector(sample)

k2_df <- k2[,c(3,4)]
k3_df <- k3[,c(3,4,5)]
k4_df <- k4[,c(3,4,5,6)]
k5_df <- k5[,c(3,4,5,6,7)]
#k6_df <- k6[,c(3,4,5,6,7,8)]
#k7_df <- k7[,c(3,4,5,6,7,8,9)]

k2_matrix <- t(as.matrix(k2_df))
k3_matrix <- t(as.matrix(k3_df))
k4_matrix <- t(as.matrix(k4_df))
k5_matrix <- t(as.matrix(k5_df))
#k6_matrix <- t(as.matrix(k6_df))
#k7_matrix <- t(as.matrix(k7_df))

#pdf("buckwheat_structure_K2-5_1.pdf")

par(mfrow = c(4,1),
    #mar = c(3,3,0.1,0),
    #mgp = c(3,0.1,0),
    cex.axis = 0.4,las = 2
    )

# =====================================================
par(pin=c(16,4), mar=c(0.5,3,0.5,0))
barplot(k2_matrix,col = c("#FF9900","#9900FF"),
        #names.arg = sam_name,
        space = 0, axes = FALSE,
        #border = NA
)
mtext("K=2",side=2,line = -1)

# =====================================================
par(pin=c(16,4), mar=c(0.5,3,0.5,0))
barplot(k3_matrix,col = c("#9900FF","#FF9900","#009933"),
        #names.arg = sam_name, 
        space = 0, axes = FALSE,
        #border = NA
)
mtext("K=3",side=2,line = -1)

# =====================================================
par(pin=c(16,4), mar=c(0.5,3,0.5,0))
barplot(k4_matrix,col = c("#4682B4","#FF9900","#9900FF","#009933"),
        #names.arg = sam_name, 
        space = 0, axes = FALSE,
        #border = NA
)
mtext("K=4",side=2,line = -1)

# =====================================================
par(pin=c(16,4), mar=c(4,3,0.5,0))
barplot(k5_matrix,col = c("#9900FF","#009933","#FF9900","#4682B4","red"),
        names.arg = sam_name, 
        space = 0, axes = FALSE,
        #border = NA
)
mtext("K=5",side=2,line = -1)

# =====================================================

#colnames(mtx) <- sam_name
#pdf("K7_2.pdf",height = 4,width = 16)
#par(cex.axis = 0.4,las = 2)
#k6_col c("#4682B4","red","#009933","#FF9900","#FFFF33","#9900FF")
#k7_col c("#4682B4","#009933","#9900FF","black","#FFFF33","red","#FF9900")

#dev.off()

