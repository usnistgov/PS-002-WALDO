%% Add paths
matlabFolder = fileparts(which(mfilename));
challengeFolder = fileparts(matlabFolder);
inputFolder = fullfile(challengeFolder, 'dataset/rxSignal');
addpath(genpath(challengeFolder));

%% Params
showPlot = 0;
snr = [-18 0 18];
chIdVec = 0:15577;

%% Constant
Nsts = 4;
Ntx  = 4;

%% Dependent Params
snrLen = size(snr,2);
inputSnrFolder = cell(snrLen,1);
for i = 1: snrLen
    inputSnrFolder{i} = fullfile(inputFolder, sprintf('snr%d',snr(i) ));
    mkdir(inputSnrFolder{i});
end

%% Get Tx signal
tx = getEdmgCef(Nsts,Ntx);
txLen = size(tx,1);

%% Load channel
for chId = chIdVec
    H =  getChannel(chId);
    chLen = size(H,3);
    cpi = size(H,4);
    rx = zeros(chLen+txLen-1,Nsts, cpi);
    rxNoisy = zeros(chLen+txLen-1,Nsts, cpi);
    for i = 1:cpi
        rx(:,:,i) = getMimoRx(tx,H(:,:,:,i));
    end
    for i = 1:snrLen
        rxNoisy = addRxNoise(rx, snr(i));
        outputFileName = fullfile(inputSnrFolder{i},sprintf('rxSigCh%d',chId));
        save(outputFileName, 'rxNoisy')
    end
end

if showPlot
    figure %#ok<UNRCH>
    plot(tx(:,1)), ylim([-2 2]);
    figure
    plot(abs(squeeze(H(1,1,:,1))));

end
