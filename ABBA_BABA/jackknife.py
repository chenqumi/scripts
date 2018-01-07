#chenqumi@20171212
#! /usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import division
import math
from scipy import stats

#
# ==========================================
def variance(lst):
    
    mean = sum(lst)/len(lst)

    tmp = 0
    for i in lst:
        tmp += (i-mean)**2

    var = tmp/(len(lst)-1)
    
    return var

#
# ==========================================
class jackknife(object):
    
    def __init__(self,dstat,content):
        self.dstat = float(dstat)
        self.content = content
        self.num = len(content)
    '''
    def var(self):
        jack = []
        for i in range(self.num):
            # tmp have to be a copy of content,
            # otherwise, content will be changed
            tmp = self.content[:] 
            tmp.pop(i)
            jacked = math.sqrt(variance(tmp)*(self.num))
            jack.append(jacked)

        return jack
    '''
    def jack(self):
        jacked = []
        # jack is a nested list
        for i in range(self.num):
            tmp = self.content[:]
            tmp.pop(i)
            jacked.append(tmp)
        
        return jacked
    
    def pseudo(self):
        pseudoed = []
        
        for i in self.jack():
            # dpseudo = dstat*N - mean(jacked)*(N-1)
            dpseudo = self.dstat*self.num - sum(i)/len(i)*(self.num-1)
            pseudoed.append(dpseudo)

        return pseudoed

    def pvalue(self):
        # stderr = sqrt(var(dpseudo)/N)
        stderr = math.sqrt(variance(self.pseudo())/self.num)
        z = self.dstat/stderr
        z_tmp = -abs(z)
        p = 2*(stats.norm.cdf(z_tmp))

        return p,z,stderr

#
# ==========================================
def main():
    pass

#
# ==========================================
if __name__ == '__main__':
    main()