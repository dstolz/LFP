function [W,Fs] = getWaveformData(obj,channel,timeWindow,streamName)
% [W,Fs] = getWaveformData(obj,channel,[timeWindow],[streamName])

narginchk(2,4);

if nargin < 3 || isempty(timeWindow), timeWindow = [0 0]; end
if nargin < 4 || isempty(streamName), streamName = obj.streamName; end

% t = tic;

obj.actXTT.SetGlobalV('WavesMemLimit',10^9);
obj.actXTT.ResetFilters;


obj.actXTT.SetGlobals(sprintf('Channel=%d; T1=%0.9f; T2=%0.9f', ...
    channel,timeWindow(1),timeWindow(2)));

W  = obj.actXTT.ReadWavesV(streamName);
Fs = obj.actXTT.ParseEvInfoV(0,1,9);

% fprintf('lfp.TDT.getWaveformData runtime: %0.2f s\n',toc(t));
