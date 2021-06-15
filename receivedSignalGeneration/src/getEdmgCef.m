function y = getEdmgCef(Nsts,Ntx)
%GETEDMGCEF EDMG Channel Estimation Field (EDMG-CEF)
%
%   Y = GETEDMGCEF(Nsts,Ntx) generates the EDMG Channel Estimation Field
%   (CEF) time-domain signal for the EDMG transmission format given the
%   number of transmit stream Nsts and the number of transmit antennas Ntx
%
%   Y is the time-domain EDMG CE signal. It is a complex matrix of size
%   Ns-by-Ntx, where Ns represents the number of time-domain samples and
%   Ntx is the number of digital transmit antennas.

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
%   Copyright 2019-2021 NIST/CLT (steve.blandino@nist.gov)

%% Init params
golayLen = 128;

%% Get P matrix
[P, N_EDMG_CEF] = edmgCefConfig(Nsts);

%% Get Q matrix
QMat = getPreambleSpatialMap(Nsts,Ntx, 'Hadamard').';

%% Generate Ga for Gb for different stream indicies
Ga_Mat = cell(Nsts, 1);
Gb_Mat = cell(Nsts, 1);

Gu_Mat = cell(Nsts, 1);
Gv_Mat = cell(Nsts, 1);

CE_Subfield_Mat = cell(Nsts, N_EDMG_CEF);

for j = 1:Nsts
    % Get the corresponding Golay Sequence for stream (j).
    [Ga, Gb] = wlan11ayGolaySequence(golayLen, j);
    Ga_Mat{j} = Ga;
    Gb_Mat{j} = Gb;
    % Generate Gu and Gv matrix based on stream index.
    Gu_Mat{j,1} = [-Gb; -Ga; +Gb; -Ga];
    Gv_Mat{j,1} = [-Gb; +Ga; -Gb; -Ga];
    % Generate CEF Subfields
    for n = 1:N_EDMG_CEF
        if (n == 1)
            % Subfield Idx n = 1
            CE_Subfield_Mat{j,n} = [Gu_Mat{j,1}; Gv_Mat{j,1}; -Gb];
        else
            % Subfield Idx n >= 2
            CE_Subfield_Mat{j,n} = [-Ga; Gu_Mat{j,1}; Gv_Mat{j,1}; -Gb];
        end
    end
end

%% Generate CEF
CEF_Mat = cell(Ntx, N_EDMG_CEF);  
% Generate Subfield
CEF_Size = 0;
for n = 1:N_EDMG_CEF
    for i = 1:Ntx
        vector = zeros(numel(CE_Subfield_Mat{1,n}), 1);
        for j = 1:Nsts
            vector = vector + QMat(i,j) * P(j,n) * CE_Subfield_Mat{j,n};            
        end
        CEF_Mat{i, n} = vector;
    end
    CEF_Size = CEF_Size + numel(vector);
end

%% Prepare output
y = zeros(CEF_Size, Ntx);
for i = 1:Ntx
    y(:,i) = cat(1, CEF_Mat{i,1:end});
end
y = y/sqrt(Ntx);

end

