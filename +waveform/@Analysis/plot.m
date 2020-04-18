function h = plot(obj,ax,analysisType,plotType)
% h = plotAnalysis(obj,[ax],[analysisType],[plotType]);
%
% Additional inputs, analysisType and plotType, override those specified in
% WaveformAnalysis.Waveform.AnalysisPlotOptions

P = obj.plotOptions;

if nargin < 2 || isempty(ax), ax = gca; end
if nargin < 3 || isempty(analysisType), analysisType = P.analysisType; end
if nargin < 4 || isempty(plotType), plotType = P.plotType; end

Z = obj.(analysisType);

if numel(Z) == length(Z)
    % can only do a line plot
    hold(ax,'on');
    h = plot(ax,obj.yVals,Z,'-o','linewidth',2,'markersize',10, ...
        'color',P.getChannelLineColor(obj.Waveform.channel));
    hold(ax,'off');
else
    switch plotType
        case 'imagesc'
            X = obj.xVals;
            Y = obj.yVals;
            ax.XAxis.Scale = 'linear'; % Must be linear
            h = imagesc(ax,X,Y,Z');

        otherwise
            [Y,X] = meshgrid(obj.yVals,obj.xVals);
            h = feval(plotType,ax,X,Y,Z);
    end

end

P.applyPlotOptions(P,ax);

axis(ax,'tight');










