from Tri_Functions import *
import pandas
from sys import argv
import csv
import re
import os


Activity_file=argv[1]
P_list=[]

p=re.compile(r'\d+\.\d+')
filepath = './processed'
filename = os.path.join(filepath,Activity_file)

with open(filename, 'r') as infile:
    read = csv.reader(infile)
    P_list = list(read)

E_list = Process_Activity(P_list)

filename='Activity_Definitions_'.rstrip() + Activity_file

with open(filename, 'w')as outfile:
    write=csv.writer(outfile)
    for item in E_list:
        write.writerow([item])
