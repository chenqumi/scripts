#chenqumi@20170630
#! /usr/bin/env python
# -*- coding: utf-8 -*-
import sys,os,re
#import pandas as pd

if len(sys.argv) ==1:
    print("\nUsage: {} <group.info> <Qfiles.lst>".format(sys.argv[0]))
    sys.exit()

GroupInfo,Qfiles = sys.argv[1:3]
#
# =============================================================
def Combine_GroupInfo_Qfiles(GroupInfo,Qfiles):
    # paste GroupInfo all Qfiles > test
    with open(Qfiles) as Q:
    
        cmd_paste = "paste {}".format(GroupInfo)
    
        for line in Q:
            cmd_paste += " {}".format(line.strip())
    
        cmd_paste += " > tmp"
    
    os.system(cmd_paste)

    # cat head tmp > result.Q 
    head = Parse_Qfiles(Qfiles)
    #os.system("echo {} > head".format(head))
    #cmd_cat = "cat {} tmp > result.Q".format(head)
    #os.system("cat head tmp > result.Q")

    with open("result.Q","w") as RQ:
        RQ.write(head+"\n")
        with open ("tmp") as TP:
            for line in TP:
                RQ.write(line)
#
# =============================================================
def Parse_Qfiles(Qfiles):
    with open(Qfiles) as Q:
        
        k_lst = []
        
        for line in Q:
            filename = os.path.basename(line.strip())
            m = re.match(r"\S+\.(\d+)\.Q",filename)
            k_value = m.group(1)
            k_lst.append(int(k_value))

        global q_lst
        q_lst = []
        for k in k_lst:
            q = ["K{}_Q{}".format(k,i+1) for i in range(k)]
            q_join = " ".join(q)
            q_lst.append(q_join)

        
        head = "sample group {}".format(" ".join(q_lst))

        return head


#
# =============================================================
def Parse_DataFrame(df):
    pass

#
# =============================================================
def Split_Q():
    cmd_csv = ""
    cmd_tab = ""
    for i in q_lst:
        m = i.split()
        k = m[0].split("_")[0].split("K")[1]
        
        filename_c = "result.{}.Q.csv".format(k)
        filename_t = "result.{}.Q".format(k)
        cmd_tab += "sortdf[{}].to_csv(\"{}\",index=False,header=False,sep='\\t')\n".format(m,filename_t)
        
        m.insert(0,"sample")
        m.insert(1,"group")
        cmd_csv += "sortdf[{}].to_csv(\"{}\",index=False)\n".format(m,filename_c)

    cmd_tab += 'sortdf[["sample","group"]].to_csv("group.info",index=False,header=False,sep="\\t")\n'

    return (cmd_csv,cmd_tab)


#
# =============================================================
def main():
    # gen result.Q 
    Combine_GroupInfo_Qfiles(GroupInfo,Qfiles)

    # parse_df
    cmd = '''
import pandas as pd
% matplotlib inline
df = pd.read_table("result.Q", sep="\s+")
sortdf = df.sort_values(["group","K4_Q3"])
sortdf.plot(kind="bar", stacked=True)
sortdf.to_excel("sort.xlsx")
'''
    
    cmd_csv,cmd_tab = Split_Q()

    with open ("check_sort_in_pandas.py","w") as py:
        py.write("{}\n{}\n{}".format(cmd,cmd_csv,cmd_tab))

#
# =============================================================
if __name__ == '__main__':
    main()
