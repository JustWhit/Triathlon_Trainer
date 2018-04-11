import sklearn
import pandas as pd
import numpy as np
import statistics as stat
import peakutils
import os
import csv
import codecs
import matplotlib.pyplot as plt
import sys
import re
from scipy.stats import skew, kurtosis
from scipy.signal import savgol_filter as savgol

p=re.compile(r'\d+\.\d+')

def smoothData(C):
    Rheaders=['time','Ax','Ay','Az','Gx','Gy','Gz']
    df = pd.DataFrame(C,columns=Rheaders)
    for column in df.columns[1:]:
        smoothed = savgol(x=df[column],mode='interp', window_length=15,polyorder=1)
        df[column] = smoothed;
    
    return df.values.tolist()

def getGroundTruth(P_list, Activity_file):
    A_name=os.path.basename(Activity_file).split('_')[0]
    print(A_name)
    filename=A_name.rstrip() + '_gr.csv'
    with open(filename, 'r') as infile:
        read=csv.reader(infile)
        gr_list=list(read)

    G_list=[]
    for item in P_list:
##        x=[float(i) for i in p.findall(str(item))]
        x=[item[0],item[1]]
        maybe='transition'
        for row in gr_list:
            if x[0] > float(row[1]) and x[1] < float(row[2]):
                maybe=row[0]
                break
        G_list.append(maybe)
        
            
    return G_list, gr_list, A_name


def adjustTime(A_list):
    timestamp=float(A_list[0][0])
    for row in A_list:
        row[0]=float(row[0])-timestamp
        row[1]=float(row[1])-timestamp
    return A_list


def plotResults(E_list, A_list,gr_list, title):
    #Activity=pd.DataFrame(A_list, columns=headers)
    for row in gr_list:
        print(row)
    x=np.array([i[0] for i in A_list])
    plt.gca().set_prop_cycle(plt.cycler('color', ['blue','green','red']))
    plt.subplot(2,1,1)
    for i in range(1,4):
        plt.plot(x,[a[i] for a in A_list])
    plt.title(title + "'s Results")
    plt.ylabel('Accelerometer (m/s^2)')
    diff=0.0
    counter=0.0
    calc_list=map(list.__add__, E_list, gr_list)
    for row in calc_list:
        diff+= abs(float(row[1]) -float(row[4]))
        diff+=abs(float(row[2])-float(row[5]))
        counter+=2
    avg=diff/counter

    for i in E_list:
        ymin, ymax = plt.ylim()
        plt.axvline(float(i[1]), color='pink')
        plt.axvline(float(i[2]), color='pink')
        plt.text(float(i[1]), ymin, i[0].rstrip() + ' start', rotation='vertical', ha='right', va='bottom')
        plt.text(float(i[2]), ymin, i[0].rstrip() + ' stop', rotation='vertical', ha='right', va = 'bottom')
    for i in gr_list:
        plt.axvline(float(i[1]), color='red', linestyle='dashed')
        plt.axvline(float(i[2]), color='red', linestyle='dashed')
    plt.legend(['Ax','Ay','Az', 'predicted'], loc='upper right')

    plt.subplot(2,1,2)
    for i in range(4,7):
        plt.plot(x,[a[i] for a in A_list])
    xmin, xmax=plt.xlim()
    plt.ylabel('Gyroscope (rev/s)')
    plt.xlabel('time(s)')
    for i in E_list:
        ymin, ymax = plt.ylim()
        plt.axvline(float(i[1]), color='pink')
        plt.axvline(float(i[2]), color='pink')
        plt.text(float(i[1]), ymin, i[0].rstrip() + ' start', rotation='vertical', ha='right', va='bottom')
        plt.text(float(i[2]), ymin, i[0].rstrip() + ' stop', rotation='vertical', ha='right', va = 'bottom')
    for i in gr_list:
        plt.axvline(float(i[1]), color='red', linestyle='dashed')
        plt.axvline(float(i[2]), color='red', linestyle='dashed')
    plt.text(xmax,ymax, 'Det Acc:' +str(avg), va='top', ha='right', fontsize=10)
    plt.show()

def Process_Features(l, n):
    Rheaders=['time','Ax','Ay','Az','Gx','Gy','Gz']
    # For item i in a range that is a length of l,
    
    l_len=len(l)-n
    for i in range(0, (l_len),30):##range(0, len(l), n)
        progress= float(i)/l_len *100
        sys.stdout.write("Creating Vectors: %f%%   \r" % (progress) )
        sys.stdout.flush()
        RawChunk = pd.DataFrame(l[i:i+n],columns=Rheaders)
        #record beginning and end time
        b_time= RawChunk['time'].iloc[0]
        e_time = RawChunk['time'].iloc[-1]
        row=[[b_time,e_time]]
        #drop time stamps from data
        RawChunk=RawChunk.drop('time',1)
        cols=RawChunk.columns
        #convert data to float
        for col in cols:
            RawChunk[col]=RawChunk[col].astype(float)
        #extract features
        row.extend(getRMS(RawChunk))
        #row.extend(getMean(RawChunk))
        row.extend(getStanDev(RawChunk))
        #row.extend(getMedian(RawChunk))
        #row.extend(getMode(RawChunk))
        row.extend(getAvgPeakDistAmp(RawChunk))
        #row.extend(getSkewness(RawChunk))
        #row.extend(getKurtosis(RawChunk))
        yield row

def getRMS(df):
    row=[]
    temp=df**2
    for column in temp:
        rms=stat.mean(temp[column])
        rms=rms**(.5)
        row.append(rms)
    return row

def getMean(df):
    row=[]
    for column in df:
        mean=stat.mean(df[column])
        row.append(mean)
    return row
    
def getStanDev(df):
    row=[]
    for column in df:
        std=stat.stdev(df[column])
        row.append(std)
    return row

def getMedian(df):
    row=[]
    for column in df:
        median=stat.median(df[column])
        row.append(median)
    return row

def getMode(df):
    row=[]
    for column in df:
        mode=stat.mode(df[column])
        row.append(mode)
    return row

def getSkewness(df):
    row=[]
    for column in df:
        sk=skew(df[column])
        row.append(sk)
    return row

def getKurtosis(df):
    row=[]
    for column in df:
        kt=kurtosis(df[column])
        row.append(kt)
    return row

def getMagnitude(df):
    row=[]
    for column in df:
        mag=(sum(i**2 for i in column))**(0.5)

def getAvgPeakDistAmp(df):
    row=[]
    for column in df:
        indexes=peakutils.indexes(df[column], thres=0.02/max(df[column]), min_dist=2)
        
        if(len(indexes)>1):
            dist=[j-i for i, j in zip(indexes[:-1], indexes[1:])]
            avgDist=stat.mean(dist)
        else:
            avgDist=-1
        if(len(indexes)>2):
            stdDist=stat.stdev(dist)
        else:
            stdDist=-1

        Amp=[]
        for point in indexes:
            Amp.append(df[column].iloc[point])
        if(len(Amp)>=1):
            avgAmp=stat.mean(Amp)
        else:
            avgAmp=-1
        if(len(Amp)>1):
            stdAmp=stat.stdev(Amp)
        else:
            stdAmp=-1
        row.extend([stdDist,avgAmp,stdAmp])##avgDist  removed from result
        
    return row





    

def getTrainingData(path):
    T_list=[]
    Actual=[]
    for file in os.listdir(path):
        filepath=os.path.join(path, file)
        if(os.path.splitext(file)[1]=='.csv'):
            classification= os.path.splitext(file)[0]
            with open(filepath, 'r') as infile:
                read=csv.reader(infile)
                T_list.extend(list(read))
                count=len(T_list)-len(Actual)
                for i in range(count):
                    Actual.append(classification)
##    for row in T_list:
##        del row[0]
    
    with open('./test.csv', 'w') as testfile:
        test_list=list(zip(Actual,T_list))
        write=csv.writer(testfile)
        for item in test_list:
            write.writerow(item)       

    return Actual, T_list

def Process_Activity(R_list):
    firstStart=0
    firstStop=0
    secondStart=0
    secondStop=0
    thirdStart=0
    thirdStop=0
    first='NA'
    second='NA'
    third='NA'
    activities=['run','bike','swim']## add 'swim'
    RR_list=R_list[::-1]
    Ccounter=0 #current counter
    Tcounter=0 #transition counter
    Ncounter=0 #possible next counter
    Bcounter=0 #stepback if next erroneous
    possibleN='' #possible next activity

    for row in R_list:
        if first == 'NA':
            if row[0] in activities:
                if Ncounter>3 and possibleN==row[0]:
                    first=row[0]
                    Ccounter=Ncounter
                    Ncounter=0
                    possibleN=''
                    
                elif possibleN==row[0]:
                    Ncounter=Ncounter+1
                else:
                    firstStart=row[1]
                    possibleN=row[0]
                    Ncounter = 1
        elif second == 'NA':
            if row[0] == first:
                if Tcounter<10:
                    firstStop=row[2]
                    secondStart=0
                    Tcounter=1
                elif Ccounter>3:
                    firstStop=row[2]
                    secondStart=0
                    Tcounter=0                   
                Ccounter = Ccounter+1
                possibleN=''
                Ncounter=0
            elif row[0] in activities:
                if Ncounter>4 and possibleN==row[0]:
                    second=row[0]
                    Ccounter=Ncounter
                    Ncounter=0
                    possibleN=''
                    
                elif possibleN==row[0]:
                    Ncounter=Ncounter+1
                elif Tcounter>15 and row[0]!=first:
                    secondStart=row[1]
                    possibleN=row[0]
                    Ncounter = 1
            else:
                Ccounter=0
                Tcounter= Tcounter+1
        elif third == 'NA':
            if row[0] == second:
                if Tcounter<10:
                    secondStop=row[2]
                    thirdStart=0
                    Tcounter=1
                if Ccounter>3:
                    secondStop=row[2]
                    thirdStart=0
                    Tcounter=0
                possibleN=''
                Ncounter=0
                Ccounter= Ccounter+1
            elif row[0] == first and secondStop==0:
                if Bcounter>4:
                    second='NA'
                    secondStart=0
                    Bcounter=0
                else:
                    Bcounter=Bcounter+1
            elif row[0] in activities:
                if Ncounter>4 and possibleN==row[0]:
                    third=row[0]
                    Ccounter=Ncounter
                    Ncounter=0
                    possibleN=''
                    print(second, secondStop)
                    print(third, thirdStart)
                elif possibleN==row[0]:
                    Ncounter=Ncounter+1
                elif Tcounter>15 and row[0]!=second:
                    thirdStart=row[1]
                    possibleN=row[0]
                    Ncounter = 1
            else:
                Ccounter=0
                Tcounter= Tcounter+1               
                
        elif row[0] == third:
            if Tcounter<10:
                thirdStop=row[2]
                Tcounter=1
            if Ccounter>8:
                thirdStop=row[2]
                Tcounter=0                   
            Ccounter= Ccounter+1
        elif row[0] == second and thirdStop==0:
            if Bcounter>4:
                third='NA'
                thirdStart=0
                Ccounter=Bcounter
                Bcounter=0
            else:
                Bcounter=Bcounter+1
        else:
            Ccounter=0
            Tcounter= Tcounter+1            

    print(first, firstStart)
    print(first, firstStop)
    print(second, secondStart)
    print(second, secondStop)
    print(third, thirdStart)
    print(third, thirdStop)
    if thirdStop!=0:
        return[[first, firstStart, firstStop],[second, secondStart, secondStop],[third, thirdStart, thirdStop]] 
    if secondStop!=0:
        return[[first, firstStart, firstStop],[second, secondStart, secondStop]]
    
    return[[first, firstStart, firstStop]]
