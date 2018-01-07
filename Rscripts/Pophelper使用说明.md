# Pophelper使用说明

软件包说明[pophelper](http://royfrancis.github.io/pophelper/)

Structure结果作图费时费力，目前测试的一些软件和网站也不能完美解决这个问题。[Distuct](https://web.stanford.edu/group/rosenberglab/distruct.html)要求的格式比较复杂，应该是为支持Structure这个软件开发的。

pophelper包也存在一些问题：“K=2”标签的方向不能更改；排序时选择较少，在多个Q矩阵排序时，只能针对最小的矩阵排序(如K从2到7，只能依据Q1、Q2、all排序)。

该包并不支持Frappe(流程使用的软件)运行后的格式，解决方法：1).使用admixture软件 2). 将Frappe结果转换为admixture的格式。下面以admixture(我们应该也只会使用Frappe和admixture)为例作说明：

```R
# 主要提供两种文件：1.admixture运行的结果Q文件 2.记录样本和分组信息的文件(下面的例子中，第一列为样品名称，第二列为样品所在分组)

library('pophelper')

# read all the files in dir
# 使用list.files()一次性将目录下的所有Q文件读入，所以该目录下应该只存放Q文件，
# group.lst另外放一个目录，应该会有更好的解决方法，不过以我目前R的水平只能这么做了
afiles <- list.files('C:/Users/quan_chen/Desktop/Rstudio/admixture',full.names = T)

# transfer all files(afiles) to a list ()
# 使用包中readQ()函数将所有Q文件存入一个list，就是建立了一个高维数据类型
alst <- readQ(files = afiles)

# read file containing individual and group info
indvs <- read.table("C:/Users/quan_chen/Desktop/Rstudio/group.lst",header = F,stringsAsFactors=F)

# adding indvidual info to all Q matrix files
# 将样本信息对应到每一个Q文件
if(length(unique(sapply(alst,nrow)))==1) alst <- lapply(alst,"rownames<-",indvs$V1)

# extract group info
group_info <- indvs[,2,drop=F]

# K values
# spnames <- paste0("K=",c(10,2,3,4,5,6,7,8,9))
# 自定义strip panel的标签
kvalue <- c("K=10","K=2","K=3","K=4","K=5","K=6","K=7","K=8","K=9")

# color
gpcolor = c("#009933","#FF9900","#9900FF","#0099FF","#FF0033","#FFFF00","navy")

# 对2-7的Q文件作图
for (i in 2:7){
  plotQ(
    alst[i], ordergrp = T, grplab = group_info, subsetgrp = c("XZ","YGC","SGN"), sortind = "all",
    clustercol = gpcolor,
    width=20, height = 3, indlabsize=3, indlabvjust=1, showindlab = F, useindlab = T,
    #splab=kvalue[i]
    showsp = F,
    linesize = 3, linealpha = 0.2,grplabpos = 0.7,  pointcol = "white", pointsize = 3,
    divsize = 0.4
  )
}
# ordergrp = T 样品按分组信息排列
# subsetgrp 设定各组的排列顺序
# sortind 对各样本的排序方式

```

使用循环的方式依次作图，各成分上色会有问题，最好是按K分别作图，分别填充颜色。



## 个人思考

使用高维数据结构存储Q矩阵的结果，对组内结果可以按任意Q列进行排序，其他K值Q矩阵顺序随之同步变换。同时能够实现Q值列的变换。

pandas和R应该都能实现类似的功能



使用说明：

```python
Usage:
    
    python get_info.py <SampleInfo> <CancerType>

example:
    
    nohup python get_info.py sampleinfo cancertype &
    
# 两个命令行参数均是输出文件
#
# SampleInfo文件记录了原始数据对应的样品类型，
# 对于其他未识别的数据会写入其他文件中：
# HD           --  标准品
# Unknown      --  未知类型
# Unrecognized --  未识别(数据命名不符合规范的样品)
# SampleInfo文件格式示例：
OG160250056     Control
OG160250056     Normal
OG160250056     Tumor
# 随后会将得到的样品编号在数据库中查找，匹配对应的癌种信息，记录在CancerType中，格式示例：
OG160200043     肺癌    Lung Carcinoma
OG160250016     肝癌    Hepatocellular Carcinoma
OG160250028     肝癌    Hepatocellular Carcinoma
OG160250053     食管癌  Esophageal Carcinoma
```

