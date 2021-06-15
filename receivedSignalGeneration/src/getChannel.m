function H =getChannel(id)

filename = sprintf('qdOutput%d.json', id);
fid = fopen(filename);
totTime = 128;
nLines = 1;

rawChannel = struct('tx', cell(1,nLines), ...
    'rx', cell(1,nLines), ...
    'paaTx', cell(1,nLines), ...
    'paaRx', cell(1,nLines), ...
    'delay', cell(1,nLines), ...
    'gain', cell(1,nLines), ...
    'phase', cell(1,nLines), ...
    'aodEl', cell(1,nLines), ...
    'aodAz', cell(1,nLines), ...
    'aoaEl', cell(1,nLines), ...
    'aoaAz', cell(1,nLines) ...
    );
while ~feof(fid)
    tline = fgetl(fid);
    rawChannel(nLines) = jsondecode(tline);
    nLines = nLines+1;
end
fclose(fid);
M =  max([rawChannel.paaTx])+1; % Tx antennas
N = max([rawChannel.paaRx])+1;  %Rx antennas
firstMpcDelay = min(reshape([rawChannel.delay], [], 1));
lastMpcDelay = max(reshape([rawChannel.delay], [], 1));

fs = 1.76e9;
ovs = 1;
sampTime = 1/(ovs*fs);
startInterp = firstMpcDelay-10*sampTime;
endInterp = lastMpcDelay+10*sampTime;
ts = (startInterp:sampTime:endInterp);
ns = length(ts);

txId = 0;
rxId = 1;
dlId = [rawChannel.tx] == txId & [rawChannel.rx] == rxId;
gainInt = zeros(N,M, ns, totTime);

for m = 1:M
    for n =1:N
        chId = (dlId & [rawChannel.paaTx] == m-1 & [rawChannel.paaRx] == n-1);
        ch = rawChannel(chId);
        for t = 1:totTime
            delay = ch.delay(t,:);
            complexGain  = 10.^(ch.gain(t,:)/20).*exp(1j*ch.phase(t,:));
            [Ts,T] = ndgrid(ts,delay);
            gainInt(n, m, :,t)= sinc((Ts - T)*fs*ovs)*complexGain(:);
        end
    end
end

% Normalize
nrm = sqrt(sum(sum(sum(abs(gainInt).^2)))/(M*N));
H = gainInt./nrm;
end