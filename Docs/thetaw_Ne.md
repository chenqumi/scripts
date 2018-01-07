
## 计算theta_watterson及有效群体大小Ne的推算  
### $\theta_w$计算公式：  
$$ \theta_w = \frac{K}{a_n}$$  
$$ a_n = \sum_{i=1}^{n-1} \frac{1}{i}$$  
K : 分离位点的个数，在蜜蜂的文献中，似乎认为SNP的个数就是分离位点的数目  
$a_n$ : 一个调整系数  
n : 所比较的序列条数，在群体重测序中即是群体个数  
### 计算步骤
1. vcftools 提取各亚群的样品并过滤，得到SNP位点即分离位点  
2. 计算$a_n$ 
   `sum([1/i for i in range(1,individual_num)])`
3. 计算得到$\theta_w$，在本项目中需要得到平均每个base的，$\theta_w$需要再除以reference的长度  
4. 根据公式计算有效群体大小  
   $$ \theta_w = 4N_e\mu $$  
   由于蜜蜂是haplodiploidy，所以系数为3；对于单倍体(haploid)则是2
