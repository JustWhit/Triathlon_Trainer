from Tri_Functions import *
import pandas
from sys import argv
import csvimport re
import os


Activity_file=argv[1]
P_list=[]

p=re.compile(r'\d+\.\d+')

with open(Activity_file, 'r') as infile:
    read = csv.reader(infile)
    P_list = list(read)

E_list = Process_Activity(R_list)

filename='Activity_Definitions_'.rstrip() + Activity_file

with open(filename, 'w')as outfile:
    write=csv.writer(outfile)
    for item in E_list:
        write.writerow([item])
