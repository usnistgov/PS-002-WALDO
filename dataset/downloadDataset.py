# Legal Disclaimer
# NIST-developed software is provided by NIST as a public service. 
# You may use, copy and distribute copies of the software in any medium,
# provided that you keep intact this entire notice. You may improve,
# modify and create derivative works of the software or any portion of
# the software, and you may copy and distribute such modifications or
# works. Modified works should carry a notice stating that you changed
# the software and should note the date and nature of any such change.
# Please explicitly acknowledge the National Institute of Standards and
# Technology as the source of the software.
# 
# NIST-developed software is expressly provided "AS IS." NIST MAKES NO
# WARRANTY OF ANY KIND, EXPRESS, IMPLIED, IN FACT OR ARISING BY
# OPERATION OF LAW, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTY
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT
# AND DATA ACCURACY. NIST NEITHER REPRESENTS NOR WARRANTS THAT THE
# OPERATION OF THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE, OR
# THAT ANY DEFECTS WILL BE CORRECTED. NIST DOES NOT WARRANT OR MAKE ANY 
# REPRESENTATIONS REGARDING THE USE OF THE SOFTWARE OR THE RESULTS 
# THEREOF, INCLUDING BUT NOT LIMITED TO THE CORRECTNESS, ACCURACY,
# RELIABILITY, OR USEFULNESS OF THE SOFTWARE.
# 
# You are solely responsible for determining the appropriateness of
# using and distributing the software and you assume all risks
# associated with its use, including but not limited to the risks and
# costs of program errors, compliance with applicable laws, damage to 
# or loss of data, programs or equipment, and the unavailability or
# interruption of operation. This software is not intended to be used in
# any situation where a failure could cause risk of injury or damage to
# property. The software developed by NIST employees is not subject to
# copyright protection within the United States.
# Title: A Python Script to download all the files for "Dataset of channels and received IEEE 802.11ay signals for sensing applications in the 60GHz band" 
# Author: Raied Caromi
# Contact: raied.caromi@nist.gov
# Requires: Python3
#%%
from pathlib import Path
import numpy as np
import os
import time
import datetime
import hashlib
from numpy.lib.function_base import append
import requests
import sys
import pandas as pd
#%%
def webSavePy(url, output_path):
    # MAX_RETRIES = 2
    # WAIT_SECONDS = 5
    # for i in range(MAX_RETRIES):
        timeOut=40
        try:
            req = requests.get(url, stream = True,timeout=timeOut)
            fileSizeIsKnown=False
            chunkSize=4*1024*1024
            if 'Content-length' in req.headers:
                fileSize=int(req.headers['Content-length'])
                fileSizeIsKnown=True
                if chunkSize>fileSize:
                    chunkSize=fileSize
            else:
                chunkSize=1024
            # progress=0.0
            # bar_len = 60
            # suffix=' Bytes Downloaded'
            with open(output_path, "wb") as myFile:
                for chunk in req.iter_content(chunk_size = chunkSize):
                    if chunk:
                        myFile.write(chunk)
                        # progress+=chunkSize
                        # if fileSizeIsKnown:
                        #     # if file size is known display text progress bar
                        #     progToFSize=min(progress/fileSize,1)
                        #     filled_len = int(round(bar_len * progToFSize))
                        #     percents = round(100.0 * progToFSize, 1)
                        #     bar = '=' * filled_len + '-' * (bar_len - filled_len)
                        #     suffix=' '+str(progress)+'/'+str(fileSize) +' Bytes Downloaded'
                        #     sys.stdout.write('[%s] %s%s ...%s\r' % (bar, percents, '%', suffix))
                        #     sys.stdout.flush()
                        # else:
                        #     sys.stdout.write('%s ...%s\r' % (progress, suffix))
                        #     sys.stdout.flush()
            # break
        except requests.exceptions.ConnectionError as errc:
            print ("\n Failed on file:",url,"\n Error Connecting:",errc)
            sys.exit(1)
        except requests.exceptions.Timeout as errt:
            print ("\n Failed on file:",url,"\n Timeout Error:",errt)
            sys.exit(1)
#%%
def checkFilesExists(fileList):
    fileExistsIndex=[]
    for fi in range(len(fileList)):
        if os.path.isfile(fileList[fi]):
            fileExistsIndex.append(fi)
    return fileExistsIndex
#%% Create save directory 
saveDir = '.'
if saveDir[-1]!='/':
    saveDir=saveDir+'/'

if not(os.path.exists(saveDir)):
    os.mkdir(saveDir)
#%% Get json record of the dataset
baseUrl="https://data.nist.gov/rmm/records/"
recordID="mds2-2417"
requestURL=baseUrl+recordID
resp = requests.get(requestURL)
if resp.status_code != 200:
    print ("\n Failed to get dataset record form",requestURL, " with code:",resp.status_code)
    print("\n",print(resp.json()))
    sys.exit(1)
else:
    components=resp.json()['components']

getAllBaseLinks=[]
getAllBaseSizes=[]
getAllBaseHashes=[]
for J in range(len(components)):
    for keys in components[J]:
        if keys=='downloadURL':
            getAllBaseLinks.append(components[J]['downloadURL'].replace("%20"," "))
        if keys=='size':
            getAllBaseSizes.append(components[J]['size'])
        if keys=='checksum':
            getAllBaseHashes.append(components[J]['checksum'])

getBaseLinks=[]
getBaseSizes=[]
getBaseHashesText=[]
baseFileToSave=[]
for I in range(len(getAllBaseLinks)):
    if not ('.sha256' in getAllBaseLinks[I]):
        getBaseLinks.append(getAllBaseLinks[I])
        getBaseSizes.append(getAllBaseSizes[I])
        getBaseHashesText.append(getAllBaseHashes[I]['hash'])
        idPlace=getAllBaseLinks[I].find('/'+recordID+'/')
        baseFileToSave.append(str(Path(saveDir+getAllBaseLinks[I][idPlace+len(recordID)+2:])))

readChunk=4*1024*1024
for J in range(len(getBaseLinks)):
        
        webSavePy(getBaseLinks[J], baseFileToSave[J])
        #get the hash from the file  
        sha256_hash = hashlib.sha256()
        with open(baseFileToSave[J],"rb") as fin:
            # Read and update hash string value in blocks of readChunk
            for byte_block in iter(lambda: fin.read(readChunk),b""):
                sha256_hash.update(byte_block)
                sha256_hash.hexdigest()

        if not(getBaseHashesText[J]==sha256_hash.hexdigest()):
            print("File: ",baseFileToSave[J], "Wrong Hash.. File Removed!")
            os.remove(baseFileToSave[J])

            print("Something is wrong! ",baseFileToSave[J], " failed to download. Exiting program")
            break
        else:
            if recordID in baseFileToSave[J]:
                indexFile=baseFileToSave[J]

# indexFile=recordID+'-filelisting.csv'

varNames=['filePath', 'fileSize_bytes', 'fileType', 'MIMEType', 'SHA_256Hash', 'downloadURL']
fileTable=pd.read_csv(indexFile,skiprows=5, header=None,delimiter=',',names=varNames)
#%%
downloadOption = input('Download option, \nEnter (A) for all data, (C) for channel data only, (S) for received signals only, or (V) for validation data only:')
downloadOption=downloadOption.upper()
if not(downloadOption=='A' or downloadOption=='C' or downloadOption=='S' or downloadOption=='V'):
    raise ValueError('Error. Input must be A, C, S, or V')   

if downloadOption=='A':
        desiredIndex=list(range(len(fileTable['filePath'])))
elif downloadOption=='C':
        desiredIndex=[]
        for I in range(len(fileTable['filePath'])):
            if not('rxSignal/' in fileTable['filePath'][I]):
                desiredIndex.append(I)
elif downloadOption=='S':
        desiredIndex=[]
        for I in range(len(fileTable['filePath'])):
            if not('qdChannel/' in fileTable['filePath'][I]):
                desiredIndex.append(I)
elif downloadOption=='V':
        desiredIndex=[]
        for I in range(len(fileTable['filePath'])):
            if ('validation/' in fileTable['filePath'][I]):
                desiredIndex.append(I)

getFilesOnly=(fileTable['downloadURL'][desiredIndex]).to_numpy()
getFilePathsOnly=(fileTable['filePath'][desiredIndex]).to_numpy()
getFilesHashesText=(fileTable['SHA_256Hash'][desiredIndex]).to_numpy()
getFilesSizes=(fileTable['fileSize_bytes'][desiredIndex]).to_numpy()

# %% calculate the total download size
totalSizeOfTheSetGB=np.sum(getFilesSizes)/pow(1024,3)
print("\n There are ",len(getFilesOnly), " files in the dataset with a total size of ",totalSizeOfTheSetGB," GB")

# %% create directory structure for the download
allDirs=[]
allFilesToSave=[]
getFilesOnlyNameOnly=[]
for K in range(len(getFilesOnly)):
    allFilesToSave.append(str(Path(saveDir+getFilePathsOnly[K])))
    allDirs.append(str(Path(getFilePathsOnly[K]).parent))
    getFilesOnlyNameOnly.append(Path(getFilePathsOnly[K]).name)
uniqueDirs=np.unique(allDirs).tolist()
allFilesToSave=np.array(allFilesToSave)
# %% create the directories 
for L in range(len(uniqueDirs)):
    os.makedirs(saveDir+uniqueDirs[L], exist_ok=True)
# %% check if files exist and verify them, if a file has a wrong hash, remove it
print("\n Check if files already exist...")

fileExistsIndex=checkFilesExists(allFilesToSave)
allFilesThatExist=np.isin(range(len(allFilesToSave)),fileExistsIndex,invert=False)
NumOfFilesExists=len(fileExistsIndex)
Count_already_exist_and_correct=0
getFilesOnlyExists=getFilesOnly[allFilesThatExist]
allFilesToSaveExists=allFilesToSave[allFilesThatExist]
getFilesHashesTextExists=getFilesHashesText[allFilesThatExist]

steps=100
bar_len = 60

if NumOfFilesExists>0:
    verifyFilesSteps=np.arange(1,NumOfFilesExists,max([int(NumOfFilesExists/steps),1]))
    print("\n",NumOfFilesExists," files already exist! Checking files integrity. This may take some time!")
    for M in range(NumOfFilesExists):
            #get the hash from the file 
            if M in verifyFilesSteps:
                progRatio=round(M/NumOfFilesExists,2)
                filled_len = int(round(bar_len * progRatio))
                percents = round(100.0 * progRatio, 1)
                bar = '=' * filled_len + '-' * (bar_len - filled_len)
                suffix=' files verified..'
                sys.stdout.write('[%s] %s%s ..%s\r' % (bar, percents, '%', suffix))
                sys.stdout.flush()

            sha256_hash = hashlib.sha256()
            with open(allFilesToSaveExists[M],"rb") as fin:
                # Read and update hash string value in blocks of readChunk
                for byte_block in iter(lambda: fin.read(readChunk),b""):
                    sha256_hash.update(byte_block)
                    sha256_hash.hexdigest()
            

            if getFilesHashesTextExists[M]==sha256_hash.hexdigest():
                Count_already_exist_and_correct+=1
            else:
                print( "File:",allFilesToSaveExists[M], "has wrong hash! .. File Removed!")
                os.remove(allFilesToSaveExists[M])
    print("\n",NumOfFilesExists," files were checked and ", Count_already_exist_and_correct , " files were correct.")

else:
    print("\n No file exists in the provided direcory:", saveDir)
#%%
#Check again correct files
fileExistsIndex=checkFilesExists(allFilesToSave)
getFilesSizesExists=getFilesSizes[allFilesThatExist]
files_exist_size=np.sum(getFilesSizesExists)

allFilesThatDontExist=np.isin(range(len(allFilesToSave)),fileExistsIndex,invert=True)
NumOfFilesUpdated=np.sum(allFilesThatDontExist)

getFilesOnlyUpdated=getFilesOnly[allFilesThatDontExist]
allFilesToSaveUpdated=allFilesToSave[allFilesThatDontExist]
getFilesHashesTextUpdated=getFilesHashesText[allFilesThatDontExist]
#%% download files that do no it exist in the directory

downloadedFilesSteps=np.arange(1,NumOfFilesUpdated,max([int(NumOfFilesExists/steps),1]))

start_time_tr = time.time()
count_downloaded=0
count_failed=0
max_count_failed_to_quit=10
listOfFailedDownloads=[]
print("\n Attempting to download ",NumOfFilesUpdated-Count_already_exist_and_correct, " files with a total size of ",totalSizeOfTheSetGB-files_exist_size/pow(1024,3),"GB!"
 ,"If script halts, run it again.")
for N in range(NumOfFilesUpdated):

        if N in downloadedFilesSteps:
            progRatio=round(N/NumOfFilesUpdated,2)
            filled_len = int(round(bar_len * progRatio))
            percents = round(100.0 * progRatio, 1)
            bar = '=' * filled_len + '-' * (bar_len - filled_len)
            suffix=' files downloaded..'
            sys.stdout.write('[%s] %s%s ..%s\r' % (bar, percents, '%', suffix))
            sys.stdout.flush()
        webSavePy(getFilesOnlyUpdated[N], allFilesToSaveUpdated[N])

        sha256_hash = hashlib.sha256()
        with open(allFilesToSaveUpdated[N],"rb") as fin:
            # Read and update hash string value in blocks of readChunk
            for byte_block in iter(lambda: fin.read(readChunk),b""):
                sha256_hash.update(byte_block)
                sha256_hash.hexdigest()
        
        if getFilesHashesTextUpdated[N]==sha256_hash.hexdigest():
            count_downloaded+=1
        else:
            print("File: ",allFilesToSaveUpdated[N], "Wrong Hash.. File Removed!")
            os.remove(allFilesToSaveUpdated[N])
            listOfFailedDownloads.append(getFilesOnlyUpdated[N])
            count_failed+=1
        if count_failed>=max_count_failed_to_quit:
            print("Something is wrong! ",max_count_failed_to_quit, " failed to download. Exiting program")
            break

print("\n Download time for",count_downloaded," files= %s hh:mm:ss ---" % datetime.timedelta(seconds=(time.time() - start_time_tr)))
print("\n",count_failed," files failed to download!")
print("\n Total number of the files in the dataset (newly downloaded and already exist)=", count_downloaded+Count_already_exist_and_correct)