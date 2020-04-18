function C = getEpochData(obj,eventName)
% C = getEpochData(obj,eventName)
% 
% Returns a 1xM cell array with M events. Each cell contains a Nx1 vector
% aligned to the event onset and windowed by timeWindow.


narginchk(2,2);


% t = tic;

wsmp = obj.trialSamplesVector;
wsmp = wsmp(:);

sons = single(round(obj.Fs*obj.Events.(eventName).onsets));
sons = sons(:)';

wsmp = wsmp+sons;
wsmp(wsmp<1|wsmp>length(obj.samples)) = nan;

C = nan(size(wsmp));
idx = ~isnan(wsmp);
C(idx) = obj.samples(wsmp(idx));

% fprintf('lfp.Waveform.getEpochData runtime: %0.2f s\n',toc(t));













