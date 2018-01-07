# Admixture使用及作图

## 更新日期

2017/9/13

## 软件使用

路径：/p299/user/og03/chenquan1609/Resequencing/script/Admixture

`perl admixture.pl <plink_bed_file> <K>  `

输入为plink的bed文件，K为计算的最大群体数，会得到2-K个结果。

`grep -h CV *.out`得到ΔK值，可使用deltaK.R脚本作图



## 作图

可使用struc.py脚本合并所有.Q文件，然后用pandas排序，导出结果后用buckwheat_structure_2.R作图；

也可以合并.Q文件后用excel排序。

作图脚本会将所有K的结果画到一张画布上。