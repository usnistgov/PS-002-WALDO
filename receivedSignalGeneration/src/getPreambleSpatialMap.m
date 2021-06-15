function normQ = getPreambleSpatialMap(numSTS,numTx,mapping)
%GETPREAMBLESPATIALMAP EDMG spatial mapping matrix%
%
%   Q = GETPREAMBLESPATIALMAP(numSTS,numTx,mapping) return the 
%   numTx x numSTS spatial mapping matrix Q, being numTx the number of tx
%   digital antennas and numSTS the number of space-time streams.
%   mapping is the type of spatial mapping matrix specified as 
%  'Hadamard', 'Fourier' or 'Direct'.

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

switch mapping
    case 'Hadamard'
        Q = hadamard(8);
        normQ = Q(1:numSTS, 1:numTx)/sqrt(numTx).';
    case 'Fourier'
        [g1, g2] = meshgrid(0:numTx-1, 0:numSTS-1);
        normQ = exp(-1i*2*pi.*g1.*g2/numTx)/sqrt(numTx).';
    case 'Direct'
        assert(numTx==numSTS, 'Direct precoding only possible if Nsts = Ntx');
        normQ = eye(numTx);
    otherwise
        error('mappingType is incorrect.');
end

end
