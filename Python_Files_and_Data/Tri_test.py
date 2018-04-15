from Tri_Functions import *
import numpy as np
import pandas as pd
from sys import argv
import csv
import re
import os


Activity_file=argv[1]
P_list=[]

p=re.compile(r'\d+\.\d+')
filepath = './processed/400_TrainingSet15APR/Model_Predictions'
filename = os.path.join(filepath,Activity_file)

with open(filename, 'r') as infile:
    read = csv.reader(infile)
    P_list = list(read)

E_list = Process_Activity(P_list)
#E_df = pd.DataFrame(E_array)

filename='Activity_Definitions_'.rstrip() + Activity_file

##E_df.to_csv(filename, header = 'none')

with open(filename, 'w')as outfile:
    write=csv.writer(outfile)
    write.writerows(E_list)
##
##E_array.tofile(filename,sep = ',')
