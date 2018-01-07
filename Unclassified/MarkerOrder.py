#chenqumi@20171019
#! /usr/bin/env python
# -*- coding: utf-8 -*-
import sys,os,re

if len(sys.argv) != 3:
    print("\nUsage: {} <OrderFile.lst> <data.call>".format(sys.argv[0]))
    sys.exit()

lst,data = sys.argv[1:3]

#
# ==============================================================
def Maxlikehood(filelst):
    
    with open(lst) as lst_fd:
        
        files = {}
        max_likelihood = 0
        
        for line in lst_fd:
            line = line.strip()
            cmd = "grep \"likelihood\" {}".format(line)
            tmp = os.popen(cmd)
            pattern = r".+LG.+(\d+).likelihood.{3}(\S+)\n"
            m = re.match(pattern,tmp.read())
            LG = m.group(1)
            max_tmp = m.group(2)
            print (LG,max_tmp)
            files[max_tmp] = line
            max_tmp = abs(float(max_tmp))
            #max_tmp = abs(float(tmp.read().split("=")[-1].strip()))

            if max_tmp > max_likelihood:
                max_likelihood = max_tmp
            
        file = files[str(-max_likelihood)]
        return file,LG,-max_likelihood
#
# ==============================================================
def Marker(data):

    with open (data) as fd:
        
        markers = []

        for line in fd:
            line = line.strip()
            if line.startswith("#") or line.startswith("CHR"):
                continue
            chrom,pos = line.split("\t")[:2]
            markerID = "{}_{}".format(chrom,pos)
            markers.append(markerID)

        return markers
#
# ==============================================================

def main():
    
    orderfile,LG,likelihood = Maxlikehood(lst)
    markers = Marker(data)

    with open (orderfile) as fd:

        if "sexAveraged=1" in fd.readline():
            
            SMap = open ("SexaveragedMap_LG{}.txt".format(LG),"w")
            SMap.write("#LG={}\tlikelihood={}\n".format(LG,likelihood))
            
            for line in fd:
                line = line.strip()
                if line.startswith("#"):
                    continue
                marker_index,position = line.split("\t")[:2]
                marker_index = int(marker_index) - 1
                SMap.write("{}\t{}\n".format(markers[marker_index],position))
        else:
            
            MMap = open ("MaleMap_LG{}.txt".format(LG),"w")
            FMap = open ("FemaleMap_LG{}.txt".format(LG),"w")
            MMap.write("#LG={}\tlikelihood={}\n".format(LG,likelihood))
            FMap.write("#LG={}\tlikelihood={}\n".format(LG,likelihood))
            
            for line in fd:
                line = line.strip()
                if line.startswith("#"):
                    continue
                marker_index,position_male,position_female = line.split("\t")[:3]
                marker_index = int(marker_index) - 1
                MMap.write("{}\t{}\n".format(markers[marker_index],position_male))
                FMap.write("{}\t{}\n".format(markers[marker_index],position_female))           
#
# ==============================================================
if __name__ == '__main__':
    main()