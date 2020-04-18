function h = plotAnalysis(obj,ax,analysisType,plotType)
% h = plotAnalysis(obj,[ax],[analysisType],[plotType]);
%
% Additional inputs, analysisType and plotType, override those specified in
% WaveformAnalysis.Waveform.AnalysisPlotOptions

P = obj.analysisPlotOptions;

if nargin < 2 || isempty(ax), ax = gca; end
if nargin < 3 || isempty(analysisType), analysisType = P.analysisType; end
if nargin < 4 || isempty(plotType), plotType = P.plotType; end

Z = obj.(analysisType);

if numel(Z) == length(Z)
    % can only do a line plot
    hold(ax,'on');
    h = plot(ax,obj.yVals,Z,'-o','linewidth',2,'markersize',10, ...
        'color',P.getChannelLineColor(obj.channel));
    hold(ax,'off');
else
    switch plotType
        case 'plot3'
            cm = obj.analysisPlotOptions.channelColormap;
            yi = linspace(1,size(cm,1),length(obj.yVals))';
            cm = interp1(1:size(cm,1),cm,yi,'makima');
            cm = min(cm,1); cm = max(cm,0);
            [Y,X] = meshgrid(obj.yVals,obj.xVals);
            for i = 1:length(obj.yVals)
                h(i) = line(ax,X(:,i),Y(:,i),Z(:,i),'color',cm(i,:), ...
                    'marker','o','markerfacecolor',cm(i,:),'markersize',2);
            end
        
        case 'lines' % plot separate line for each y variable
            cm = obj.analysisPlotOptions.channelColormap;
            yi = linspace(1,size(cm,1),length(obj.yVals))';
            cm = interp1(1:size(cm,1),cm,yi,'makima');
            cm = min(cm,1); cm = max(cm,0);
            X = obj.xVals;  Y = obj.yVals;
            for i = 1:length(Y)
                h(i) = line(ax,X,Z(:,i),'color',cm(i,:), ...
                    'marker','o','markerfacecolor',cm(i,:),'markersize',2);
            end
            
        case 'imagesc'
            X = obj.xVals;
            Y = obj.yVals;
            ax.XAxis.Scale = 'linear'; % Must be linear
            h = imagesc(ax,X,Y,Z');

        case 'waterfall' % transpose data so waterfall is plotted along x axis
            [Y,X] = meshgrid(obj.yVals,obj.xVals);
            h = feval(plotType,ax,X',Y',Z');
            
        otherwise
            [Y,X] = meshgrid(obj.yVals,obj.xVals);
            h = feval(plotType,ax,X,Y,Z);
            shading(ax,P.shading);
    end

end

P.applyPlotOptions(P,ax);

ax.UserData = obj;

axis(ax,'tight');

