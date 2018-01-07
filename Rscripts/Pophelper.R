setwd('C:/Users/quan_chen/Desktop/Rstudio/admix')
library('pophelper')

# read all the files in dir 
afiles <- list.files('C:/Users/quan_chen/Desktop/Rstudio/admix',full.names = T)

# transfer all files(afiles) to a list ()
alst <- readQ(files = afiles)

# read file containing individual and group info
indvs <- read.table("C:/Users/quan_chen/Desktop/Rstudio/group.info",header = F,stringsAsFactors=F)

# adding indvidual info to all Q matrix files
if(length(unique(sapply(alst,nrow)))==1) alst <- lapply(alst,"rownames<-",indvs$V2)

# extract group info
group_info <- indvs[,1,drop=F]

# K values
#spnames <- paste0("K=",c(10,2,3,4,5,6,7,8,9))
kvalue <- c("K=10","K=2","K=3","K=4","K=5","K=6","K=7","K=8","K=9")

# color
gpcolor = c("#009933","#FF9900","#9900FF","#0099FF","#FF0033","#FFFF00","navy")


  plotQ(
    alst[1:3], ordergrp = T, grplab = group_info, subsetgrp = c("XZ","YGC","SGN"),
    clustercol = gpcolor,
    width=20, height = 3, indlabsize=3, indlabvjust=1, showindlab = F, useindlab = T,
    #splab=kvalue[i]
    showsp = F,
    linesize = 3, linealpha = 0.2,grplabpos = 0.7,  pointcol = "white", pointsize = 3,
    divsize = 0.4
  )



#distructExport(alst[2])

#plotQMultiline(
#  alst[2:5],grplab = group_info,ordergrp = T,subsetgrp = c("XZ","YGC","SGN"),
#  sortind = "all", width=20, indlabsize=3, indlabvjust=1,showindlab = F,useindlab = T,
#  spl = 168,height = 5
#)

#tabedq <- tabulateQ(alst)
#sumedq <- summariseQ(tabedq)