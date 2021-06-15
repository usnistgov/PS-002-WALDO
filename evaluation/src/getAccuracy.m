function accuracy = getAccuracy(resFileName, gtFileName)
%GETACCURACY Accuracy ML results
%   A = GETACCURACY(filename) returns the accuracy of the ML result defined
%   in filename.

%--------------------------Software Disclaimer-----------------------------
%
% NIST-developed software is provided by NIST as a public service. You may
% use, copy and distribute copies of the software in any medium, provided
% that you keep intact this entire notice. You may improve, modify and
% create derivative works of the software or any portion of the software,
% and you  may copy and distribute such modifications or works. Modified
% works should carry a notice stating that you changed the software and
% should note the date and nature of any such change. Please explicitly
% acknowledge the National Institute of Standards and Technology as the
% source of the software.
%
% NIST-developed software is expressly provided "AS IS." NIST MAKES NO
% WARRANTY OF ANY KIND, EXPRESS, IMPLIED, IN FACT OR ARISING BY OPERATION
% OF LAW, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTY OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT AND
% DATA ACCURACY. NIST NEITHER REPRESENTS NOR WARRANTS THAT THE OPERATION OF
% THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE, OR THAT ANY DEFECTS
% WILL BE CORRECTED. NIST DOES NOT WARRANT OR MAKE ANY REPRESENTATIONS
% REGARDING THE USE OF THE SOFTWARE OR THE RESULTS THEREOF, INCLUDING BUT
% NOT LIMITED TO THE CORRECTNESS, ACCURACY, RELIABILITY, OR USEFULNESS OF
% THE SOFTWARE.
%
% You are solely responsible for determining the appropriateness of using
% and distributing the software and you assume all risks associated with
% its use, including but not limited to the risks and costs of program
% errors, compliance with applicable laws, damage to or loss of data,
% programs or equipment, and the unavailability or interruption of
% operation. This software is not intended to be used in any situation
% where a failure could cause risk of injury or damage to property. The
% software developed by NIST employees is not subject to copyright
% protection within the United States.
%
%   Copyright 2021 NIST/CLT (steve.blandino@nist.gov)

%% Local params
wc = 0.4;
wl = 0.6;

%% Load ground truth
fileID = fopen(gtFileName);
C = textscan(fileID,'%s' );
fclose(fileID);
groundTruth =  C{1};

%% Load ML results
fileID = fopen(resFileName);
C = textscan(fileID,'%s' );
fclose(fileID);
results =  C{1};

%% Counting accuracy
countingGt = cellfun(@length, groundTruth);
countingRes = cellfun(@length, results);
% NMSE = mean(abs(countingGt-countingRes).^2./countingGt.^2);
countingAccuracy = sum(countingGt((countingGt-countingRes) == 0)/sum(countingGt));

%% Localization accuracy
localization = cellfun(@perms, groundTruth, 'UniformOutput', false);
localizationAccuracy = sum(cellfun(@(x,y) evalLoc(x,y), localization,results)/sum(countingGt));

%% Compute accuracy
accuracy = wc*countingAccuracy+wl*localizationAccuracy;

end

function z= evalLoc(x,y)
z = length(y)*any(ismember(x, y, 'rows'));
end