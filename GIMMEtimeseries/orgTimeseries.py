## Aggregate CFMT Files
#  Daniel Elbich
#  10/2/18

#  Readings in CFMT Files and exports aggregated summary file.
#
#  Update - 10/3/18
#  Added histogram function to plot bins of scores. Saves as PDF in same directory as output file
#

import os
import csv
import fnmatch
import sys

# Get argument path from command line
for arg in sys.argv[1]:
    datapath = arg

for arg in sys.argv[2]:
    series = arg

# Find folder of text files
try:
    datapath
except NameError:
    listOfFiles = os.listdir(os.getcwd())
    os.mkdir()
    print "went here"
    print (os.getcwd())
else:
    print "went there"
    os.chdir(datapath)
    listOfFiles = os.listdir(datapath)
    os.mkdir(datapath "/output")

try:
    series
except NameError:
    print "went here series"
else:
    print "went there series"
    os.mkdir(datapath "/output")

pattern = "*.txt"
i=0
finalListOfFiles={}
print ("Files found:")
for entry in listOfFiles:
    if fnmatch.fnmatch(entry, pattern):
        print (entry)
        finalListOfFiles[i]=entry
        i += 1

for files in finalListOfFiles:
    txtfile=open(finalListOfFiles[files],"r")
    data = txtfile.readlines()
    i=0
    words={}
    
    for line in data:
        words[i] = line.split()
        i += 1
    
    #Start at where Block 1 should start
    index = 9
    
    #Create task indices
    startIndex=[index,index+23,index+58,index+87]
    endIndex=[index+18,index+53,index+82,index+117]
    
    #Identify type of cambridge task
    taskcheck=finalListOfFiles[files].find("Car")
    if taskcheck>=0:
        taskname="Car_Cambridge"
    else:
        taskcheck2=words[6][0].find("pTrial_1.jpg")
        if taskcheck2>=0:
            taskname="Female_Cambridge"
        else:
            taskname="Male_Cambridge"
    
    #Header information
    subjID=words[2][1]
    date=words[1][1]
    shortFormAccuracy=int(words[endIndex[0]+2][0])+int(words[endIndex[1]+2][0])+int(words[endIndex[2]+2][0])
    shortFormAccuracyPercent=(shortFormAccuracy / float(72)) * 100
    longFormAccuracy=int(words[endIndex[0]+2][0])+int(words[endIndex[1]+2][0])+int(words[endIndex[2]+2][0])+int(words[endIndex[3]+2][0])
    longFormAccuracyPercent=(longFormAccuracy / float(102)) * 100
    
    #Find correct RT
    j=0
    k=0
    blockRT={}
    deleteCount={}
    for j in range(0,4):
        tempRT=0
        count=0
        k_final=int(endIndex[j])-int(startIndex[j])
        for k in range(0,int(endIndex[j])-int(startIndex[j])):
            tempRT += int(words[int(startIndex[j]+k)][2])
            if int(words[int(startIndex[j]+k)][5]) == 0:
                tempRT -= int(words[int(startIndex[j]+k)][2])
                count += 1
        blockRT[j]=tempRT
        deleteCount[j]=count
    
    #Calculate average correct RT
    block1RT=float(blockRT[0])/(18-deleteCount[0])
    block2RT=float(blockRT[1])/(30-deleteCount[1])
    block3RT=float(blockRT[2])/(24-deleteCount[2])
    block4RT=float(blockRT[3])/(30-deleteCount[3])
    shortFormTotalCorrectRT=(float(blockRT[0])+float(blockRT[1])+float(blockRT[2]))/(102 - deleteCount[0] + deleteCount[1] + deleteCount[2])
    longFormTotalCorrectRT=(float(blockRT[0])+float(blockRT[1])+float(blockRT[2])+float(blockRT[3]))/(102 - deleteCount[0] + deleteCount[1] + deleteCount[2] + deleteCount[3])
    
    #Fill in output
    row[files]=[subjID,date,shortFormAccuracy,shortFormAccuracyPercent,longFormAccuracy,longFormAccuracyPercent,block1RT,block2RT,block3RT,block4RT,shortFormTotalCorrectRT,longFormTotalCorrectRT,int(words[endIndex[0]+2][0]),int(words[endIndex[1]+2][0]),int(words[endIndex[2]+2][0]),int(words[endIndex[3]+2][0]),deleteCount[0],deleteCount[1],deleteCount[2],deleteCount[3]]
    
#Write output
dataacc={}
with open('exportCFMTOutput.csv', 'wb') as csvfile:
    spamwriter = csv.writer(csvfile, delimiter=',')
    spamwriter.writerow(outputHeader)
    for i in row:
        spamwriter.writerow(row[i])
        dataacc[i]=row[i][5]


