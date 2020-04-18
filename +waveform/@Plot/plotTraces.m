function H = plotTraces(obj,ax,varargin)
% h = plotTraces(obj,ax)

if nargin < 2, ax = gca; end


P = obj.plotOptions;

H = obj.plotH;

maxY = [];



flag.newTraces = isempty(H) || ~isfield(H,'linesIndivTraces') || ~ishandle(H.linesIndivTraces) || ~H.linesIndivTraces.isvalid;
flag.newMeans  = isempty(H) || ~isfield(H,'lineMeanTraces')   || ~ishandle(H.lineMeanTraces)   || ~H.lineMeanTraces.isvalid;
flag.newOnsets = isempty(H) || ~isfield(H,'onsetMarkers')     || ~ishandle(H.onsetMarkers)     || ~H.onsetMarkers.isvalid;

if flag.newTraces
    H.linesIndivTraces = line(ax,nan,nan,'linestyle','-','linewidth',0.5, ...
        'color',[0.6 0.6 0.6]);
end

if flag.newMeans
    H.lineMeanTraces = line(ax,nan,nan,'color',P.getChannelLineColor(obj.channel), ...
        'linewidth',2);
end

if flag.newOnsets
    H.onsetMarkers = line(ax,nan,nan,'marker','.','color',[0 0 0 0.75], ...
        'linestyle','none','markersize',1);
end



% INDIVIDUAL TRACES
if P.maxTraces
    M = obj.getEpochDataByValue(obj.varStruct);
    M = cellfun(@transpose,M,'uni',0);
    
    [mX,mY,~,acc] = vectorize_plot(obj,M);
    
    H.linesIndivTraces.XData = mX(:);
    H.linesIndivTraces.YData = mY(:);
else
    H.linesIndivTraces.XData = nan;
    H.linesIndivTraces.YData = nan;
end








% MEAN TRACE
mM = obj.getMeanWaveform;

if P.maxTraces, maxY = acc.maxY; end % kludgey

[mX,mY,onsetXY,acc] = vectorize_plot(obj,mM,maxY);

H.lineMeanTraces.XData = mX;
H.lineMeanTraces.YData = mY;



% Stimulus onset markers
H.onsetMarkers.XData = onsetXY(1,:);
H.onsetMarkers.YData = onsetXY(2,:);





axis(ax,'tight');

if numel(obj.xVals) > 1
    ax.XAxis.TickValues = unique(acc.px);
    ax.XAxis.TickLabels = round(obj.xVals,1);
    ax.XAxis.TickLabelRotation = 45;
    ax.XAxis.Label.String = obj.xVar;
end
ax.XAxis.TickLabelFormat = '%0.1f';

ax.YAxis.TickValues = unique(acc.py);
ax.YAxis.TickLabels = round(obj.yVals,1);
ax.YAxis.TickLabelFormat = '%0.1f';
ax.YAxis.Label.String = obj.yVar;
ax.Title.String = '';

waveform.Plot.applyPlotOptions(P,ax);

ax.XAxis.Scale = 'linear'; % force to be linear X scaling






function [mX,mY,onsetXY,acc] = vectorize_plot(obj,M,maxY)
if nargin < 3, maxY = []; end

P = obj.plotOptions;

nx = numel(obj.xVals);
ny = numel(obj.yVals);


tvec = obj.trialTimeVector';
nt = length(tvec);

tons = find(tvec>=0,1);

ind = cellfun(@isempty,M);
M(ind) = [];

px = 0;
py = 0:ny-1;

if nx > 0
    [py,px] = meshgrid(0:ny-1,0:nt:nt*(nx-1));
    py(ind) = [];
    px(ind) = [];
end


if isempty(maxY)
    if P.normalizeAmp
        % Normalize
        maxY = max(cellfun(@(a) max(abs(a(:))),M));
    else
        maxY = 0.001;
    end
end

M = cellfun(@(a) P.ampScale*a./maxY,M,'uni',0);

nm = cellfun(@(a) size(a,1),M);
if P.maxTraces > 0
    nw = min(P.maxTraces,nm);
else
    nw = ones(size(nm));
end

ind = nw == 0;
nw(ind) = [];
M(ind)  = [];

onsetXY = nan(2,numel(M));

mX = nan(nt*numel(M)+numel(M),max(nw),'single');
mY = mX;

k = 1;
for i = 1:numel(M)
    if px == 0
        onsetXY(:,i) = [tvec(1); py(i)];
    else
        onsetXY(:,i) = [px(i)+tons-1; py(i)];
    end

    if px == 0
        mX(k:k+nt-1,1:nw(i)) = repmat(tvec,1,nw(i));
    else
        mX(k:k+nt-1,1:nw(i)) = repmat((px(i):px(i)+nt-1)',1,nw(i));
    end
    mY(k:k+nt-1,1:nw(i)) = M{i}(nm(i)-nw(i)+1:nm(i),:)'+py(i);

    k = k + nt + 1; % 1 sample gap between traces
end


acc.maxY = maxY;
acc.px   = px;
acc.py   = py;
acc.tons = tons;
acc.tvec = tvec;


