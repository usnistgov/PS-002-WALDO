...%% Legal Disclaimer
...% NIST-developed software is provided by NIST as a public service. 
...% You may use, copy and distribute copies of the software in any medium,
...% provided that you keep intact this entire notice. You may improve,
...% modify and create derivative works of the software or any portion of
...% the software, and you may copy and distribute such modifications or
...% works. Modified works should carry a notice stating that you changed
...% the software and should note the date and nature of any such change.
...% Please explicitly acknowledge the National Institute of Standards and
...% Technology as the source of the software.
...% 
...% NIST-developed software is expressly provided "AS IS." NIST MAKES NO
...% WARRANTY OF ANY KIND, EXPRESS, IMPLIED, IN FACT OR ARISING BY
...% OPERATION OF LAW, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTY
...% OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT
...% AND DATA ACCURACY. NIST NEITHER REPRESENTS NOR WARRANTS THAT THE
...% OPERATION OF THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE, OR
...% THAT ANY DEFECTS WILL BE CORRECTED. NIST DOES NOT WARRANT OR MAKE ANY 
...% REPRESENTATIONS REGARDING THE USE OF THE SOFTWARE OR THE RESULTS 
...% THEREOF, INCLUDING BUT NOT LIMITED TO THE CORRECTNESS, ACCURACY,
...% RELIABILITY, OR USEFULNESS OF THE SOFTWARE.
...% 
...% You are solely responsible for determining the appropriateness of
...% using and distributing the software and you assume all risks
...% associated with its use, including but not limited to the risks and
...% costs of program errors, compliance with applicable laws, damage to 
...% or loss of data, programs or equipment, and the unavailability or
...% interruption of operation. This software is not intended to be used in
...% any situation where a failure could cause risk of injury or damage to
...% property. The software developed by NIST employees is not subject to
...% copyright protection within the United States.
%% Title: A MATLAB Script to download all the files for "Dataset of channels and received IEEE 802.11ay signals for sensing applications in the 60GHz band" 
%% Author: Raied Caromi
%% Contact: raied.caromi@nist.gov
%% set save directory name
clear;clc;
saveDir = pwd; % Download to current dir, change if different dir is desired
%% Get json record of the dataset
baseUrl='https://data.nist.gov/rmm/records/';
recordID='mds2-2417';
requestURL=[baseUrl,recordID];
try
    resp = webread(requestURL);
    components=resp.components;
catch err
    fprintf('Failed to get dataset record form: %s \n',requestURL)
    fprintf('%s \n',err.message)
end
findDownloadURL=cellfun(@(x) isfield(x,'downloadURL'),components);
allWithDownloadURL=components(findDownloadURL);
%% parse 
%getAllLinks=cellfun(@(x)x.('downloadURL'), allWithDownloadURL,'un',0);
getAllLinks=cellfun(@(x)strrep(x.('downloadURL'),'%20',' '), allWithDownloadURL,'un',0);
getAllSizes=cellfun(@(x)x.('size'), allWithDownloadURL);
getAllHashes=struct2table(cellfun(@(x)x.('checksum'), allWithDownloadURL)).hash;
getfilesHashesIndex=cellfun(@(x) strcmp(x(end-6:end),'.sha256'),getAllLinks);
getFilesOnly=getAllLinks(~getfilesHashesIndex);
getFilesSizes=getAllSizes(~getfilesHashesIndex);
getFilesHashesLinks=getAllLinks(getfilesHashesIndex);
getFilesHashesText=getAllHashes(~getfilesHashesIndex);
idPlace=cellfun(@(x) strfind(x,recordID),getFilesOnly);
for J=1:numel(getFilesOnly)
    AllDirs{J,1}=fileparts(getFilesOnly{J}(idPlace(J)+length(recordID):end));
end
fullNoneRepeatedDirs=fullfile(saveDir,unique(AllDirs));
[~,ind]=sort(cellfun(@length,fullNoneRepeatedDirs));
fullNoneRepeatedDirs=fullNoneRepeatedDirs(ind);
%%
for I=1:numel(fullNoneRepeatedDirs)
    if ~exist(fullNoneRepeatedDirs{I}, 'dir')
        mkdir(fullNoneRepeatedDirs{I});
    end
end
allFilesToSave=fullfile(saveDir,cellfun(@(x) x(idPlace+length(recordID):end),getFilesOnly,'un',0));
allFilesThatExist=cellfun(@isfile,allFilesToSave);
countAlreadyExist=sum(allFilesThatExist);
totalSizeOfTheSetGB=sum(getFilesSizes)/1024^3;
fprintf('There are %d files in the dataset with a total size of %f GB \n', length(getFilesOnly),totalSizeOfTheSetGB)
%%
fprintf('Check if files already exist...\n')
countAlreadyExistAndCorrect=0;

if countAlreadyExist>0
    fprintf('%d files already exist! Checking files integrity. This may take some time! \n',countAlreadyExist)
    for K=1:numel(getFilesOnly)
        fileName=getFilesOnly{K}(idPlace(K)+length(recordID):end);
        fileToSave=fullfile(saveDir,fileName);
        if isfile(fileToSave)
            %Count_already_exist=Count_already_exist+1;
            fprintf('File: %s ... Already exists! Verifying its integrity! ',fileName);
            hash=GetFileHash(fileToSave);
            if strcmpi(hash,getFilesHashesText{K})
                fprintf('Hash ok! \n');
                countAlreadyExistAndCorrect=countAlreadyExistAndCorrect+1;
            else
                fprintf('Wrong hash.. deleting file! \n');
                delete(fileToSave)
            end
       end
    end
    fprintf('%d files were checked and %d files were correct. \n',countAlreadyExist, countAlreadyExistAndCorrect )
else
    fprintf('No file exist in the provided direcory: %s \n', saveDir)
end
%recount file sizes in case some were deleted in the check
allFilesToSave=fullfile(saveDir,cellfun(@(x) x(idPlace+length(recordID):end),getFilesOnly,'un',0));
allFilesThatExist=cellfun(@isfile,allFilesToSave);
if any(allFilesThatExist)
    files_exist_size_GB=sum(struct2table(cellfun(@dir,allFilesToSave(allFilesThatExist))).bytes)/1024^3;
else
    files_exist_size_GB=0;
end
%%
timeOut=20;
options = weboptions('Timeout',timeOut);
countDownloaded=0;
countFailed=0;
fprintf('Attempting to download %d files with a total size of %f GB! \n',length(getFilesOnly)-countAlreadyExistAndCorrect, totalSizeOfTheSetGB-files_exist_size_GB)
in = input('Do you want to continue (y/n)? ','s');
if strcmpi(in,'y')
    startTime=tic;
    for K=1:numel(getFilesOnly)
        fileName=getFilesOnly{K}(idPlace(K)+length(recordID):end);
        fileToSave=fullfile(saveDir,fileName);
        if ~isfile(fileToSave)
            fprintf('Downloading file:%s ... \n',fileName);
            outFile=websave(fileToSave,getFilesOnly{K},options);
            fprintf('File: %s was downloaded. Verifying its hash!',outFile);
            hash=GetFileHash(fileToSave);
            if strcmpi(hash,getFilesHashesText{K})
                fprintf('Hash ok! \n')
                countDownloaded=countDownloaded+1;
            else
                fprintf('Wrong Hash! file will be deleted... \n')
                delete(fileToSave);
                countFailed=countFailed+1;
            end
        end
    end
    elapsedTime=toc(startTime);
    fprintf('Download time for %d files= %s hh:mm:ss ---\n',countDownloaded,datestr(elapsedTime/(24*60*60),'HH:MM:SS'))
    fprintf('%d files failed to download! \n',countFailed)
    fprintf('Total number of the files in the dataset (newly downloaded and already exist)=%d \n', countDownloaded+countAlreadyExistAndCorrect)
else
    fprintf('Download script was terminated! \n');
end
%%
function hash=GetFileHash(fileNamePath)
mddigest   = java.security.MessageDigest.getInstance('SHA-256'); 

bufsize = 4*1024*1024;

fid = fopen(fileNamePath);

while ~feof(fid)
    [currData,len] = fread(fid, bufsize, '*uint8');       
    if ~isempty(currData)
        mddigest.update(currData, 0, len);
    end
end

fclose(fid);

hash = reshape(dec2hex(typecast(mddigest.digest(),'uint8'))',1,[]);

end
