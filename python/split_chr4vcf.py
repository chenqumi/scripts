#!/usr/bin/env python
# -*- coding: utf-8 -*-
# chenqumi@20170604
import sys,re,os,getopt

# Usage
#==============================
h_info = '''

Usage: python {} \n
  -vcf|v: vcf file                                        [str]
  -cutoff|c: rm chr.vcf which length lt cutoff,unit is kb [NULL]

'''.format(os.path.basename(sys.argv[0]))

def usage():
	global h_info
	print(h_info)
	sys.exit()

# global paras
#===============================
lst = []
pre_scaff = ""
delet_chr = {}

if len(sys.argv) == 1:
	usage()
try:
	opts,args = getopt.getopt(sys.argv[1:],"hv:c:",["help","vcf=","cutoff="])
	#print (opts)
except getopt.GetoptError:
	usage()

for opt,arg in opts:
	#global vcf,cutoff
	if opt in ("-h","--help"):
		usage()
	elif opt in ("-v","--vcf"):
		vcf = arg
	elif opt in ("-c","--cutoff"):
		cutoff = arg

#parse_args()
if "cutoff" in locals().keys():
	cutoff = int(cutoff) * 1000
	
# group each chrom
#==============================
def parse():
	global lst
	if len(lst) == 0:
		return
	out = pre_scaff + ".vcf"

	with open (out,"w") as OT:
		for ele in lst:
			OT.write("{}\t{}\n".format(pre_scaff,ele))
		lst = []

# save dict
#===============================
def regex(line):
	if line.startswith("##contig"):
		m = re.match(r'\S+ID=(\S+),\w+=(\d+)>',line)
		chrom,length = m.groups()
		length = int(length)
		if length < cutoff: delet_chr[chrom] = 1

# main fuction
#==============================
def main():
	with open (vcf,"r") as VCF:
		for line in VCF:
			#if re.match(r'#+',line): 
			# samplely use startswith,not regex
			if line.startswith("#"):
				with open ("head","a") as HD:
					HD.write(line)
				if "cutoff" in globals().keys():
					regex(line)
			else:
				line = line.rstrip()
				# note para 1
				scaff,info = line.split("\t",1) 
				global pre_scaff
				if scaff != pre_scaff:parse()
				lst.append(info)
				pre_scaff = scaff
		parse()
#
#================================
if __name__ == '__main__':
	main()

# rm cutoff vcf
#===========================
for i in delet_chr:
	cmd = "rm {}.vcf".format(i)
	os.system(cmd)
