## Joinmap和Lep-Map结果的比较  

### 更新日期  

2017/10/26  

### 方法  

对结果进行比较就是评价两个软件得到的marker排列顺序。

1. 不仅要对顺序不一致的marker进行计数
2. 还要评价不一致marker之间相差有多大  

所以，以其中一个结果的顺序为基准，记录另一个结果的实际顺序，计算其位置的方差和标准差；同时求得最大可能的方差和标准差，做相应比较。  

```python
# 比较seq1和seq2之间的差异程度

seq1_index = [0,1,2,3,4,5,6]
seq1 =       [1,2,3,4,5,6,7]
seq2 =       [5,3,1,2,7,6,4]
seq2_index = [4,2,0,1,6,5,3]

variance = ((4-0)**2 + (2-1)**2 + (0-2)**2 + (1-3)**2 + (6-4)**2 + (5-5)**2 + (3-6)**2)/7
# variance = 5.4286
# std = 2.3299

# 计算了方差的期望
def ExpectVariance(od_common):

    num = len(od_common)
    order = range(num)
    mean = [sum(order)/num for i in range(num)]

    index = 0
    sum_square = 0
    
    for i in mean:
        sum_square += (i-order[index])**2
        index += 1

    expectvariance = sum_square/num
    expectstd = math.sqrt(expectvariance)

    return expectvariance,expectstd

# 最大方差即两条序列完全相反时求得的方差
seq1 =   [1,2,3,4,5,6,7]
seq1_r = [7,6,5,4,3,2,1]

max_variance = 16

variance_ratio = variance/max_variance
```

### 数据处理  

上述方法是在两个序列等长的前提下进行的，如果不等长，可能需要考虑更多的因素。

在本脚本中，首先会取两序列的共有部分，再对共有部分进行比较  

### 使用方法  

```shell
# 路径：/p299/user/og03/chenquan1609/Resequencing/script/LepMAP  
python CompareOrder.py 

  Usage: CompareOrder.py <order1> <order2>
  
  # order文件中一个marker一行
```

