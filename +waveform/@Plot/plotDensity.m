function h = plotDensity(obj,ax,varargin)
% h = plotDensity(obj,ax)

if nargin < 2, ax = []; end

if nargin > 2 && isstruct(varargin{1})
    obj.varStruct = varargin{1};
end

P = obj.plotOptions;

M = obj.getEpochDataByValue(obj.varStruct);

if size(M,1) == 1, M = M'; end

M = cellfun(@transpose,M,'uni',0);
[ny,nx] = size(M);


% % Normalize
ind = ~cellfun(@isempty,M);
tM  = cell2mat(M(ind));
my  = max(max(abs(tM))); clear tM
M   = cellfun(@(a) P.ampScale*a./my,M,'uni',0);

bx = linspace(P.timeWindow(1),P.timeWindow(2),length(M{1}));
by = linspace(-1,1,15);

nt = length(bx);

py = 0:length(by):length(by)*(ny-1);
px = 0:nt:nt*(nx-1)+nx;

D = [];
for i = 1:ny
    for j = 1:nx
        if isempty(M{i,j}), continue; end
        for xi = 1:nt
            for yi = 1:length(by)-1
                ind = M{i,j}(:,xi) >= by(yi) & M{i,j}(:,xi) < by(yi+1);
                D(py(i)+yi,px(j)+xi) = mean(ind);
            end
        end
    end
end

% D = smoothdata(D);

h.imageHandle = imagesc(ax,D);
ax.YDir = 'normal';
axis(ax,'tight');

cm = hot;
cm(1:4,:) = 0;
% cm = flipud(gray);
colormap(ax,cm);


if nx == 1
    ax.XAxis.TickValues = linspace(0,nt,7);
    ax.XAxis.TickLabels = round(1000*linspace(bx(1),bx(end),10),1);
    ax.XAxis.TickLabelRotation = 0;
    ax.XAxis.Label.String = 'time (ms)';
else
    ax.XAxis.TickValues = px;
    ax.XAxis.TickLabels = round(obj.event.(obj.xVar).unique,1);
    ax.XAxis.TickLabelRotation = 45;
    ax.XAxis.Label.String = obj.xVar;
end
ax.XAxis.TickLabelFormat = '%0.1f';

ax.YAxis.TickValues = py;
ax.YAxis.TickLabels = round(obj.event.(obj.yVar).unique,1);
ax.YAxis.TickLabelFormat = '%0.1f';
ax.YAxis.Label.String = obj.yVar;
ax.Title.String = '';


lfp.WaveformPlot.applyPlotOptions(P,ax);
