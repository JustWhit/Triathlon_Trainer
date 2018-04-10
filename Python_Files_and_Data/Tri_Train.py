from Tri_Functions import *
import pandas
from sys import argv
import os
import csv

raw_folder=argv[1]
classification=argv[2].rstrip()

for file in os.listdir(raw_folder):
    
    if file.endswith(classification + ".csv"):
        pathfile = os.path.join(raw_folder,file)
        with open(pathfile, 'r') as infile:
            read = csv.reader(infile)
            A_list = list(read)

        A_list = sorted(A_list, key=lambda x: x[0])
        S_list = smoothData(A_list)
        print('processing file')

        P_list = list(Process_Features(S_list, 90))

        path = './training_data'
        filename=classification + '.csv'
        filepath=os.path.join(path, filename)

        if os.path.exists(filepath):
            with open(filepath, 'r') as infile:
                read=csv.reader(infile)
                A_list= list(read)
                P_list.extend(A_list)

        with open(filepath, 'w') as outfile:
            write = csv.writer(outfile)
            for item in P_list:
                write.writerow(item)


##os.system('say "All Done"')
