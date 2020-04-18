function h = popoutPlot(hObj,event)


switch event.Source.Type
    case 'axes'
        ax = hObj;
    otherwise
        ax = ancestor(hObj,'axes');
end

fig = ancestor(ax,'figure');

obj = ax.UserData; % Waveform object



titleStr = obj.title;

% kludge
n = find(fig.Name=='-')-1;
if isempty(n), n = length(fig.Name); end
plotRegime = fig.Name(1:n);


h.figure = figure('color','w','numbertitle','off');

if isequal(plotRegime,'AnalysisPlot')
    titleStr = [titleStr ' | ',obj.analysisPlotOptions.analysisType];
    obj.analysisPlotOptions.container = h.figure;
else
    obj.plotOptions.container = h.figure;
end


figure(h.figure);

h.ax = axes(h.figure);

h.figure.Colormap = fig.Colormap;

warning('off','MATLAB:Axes:NegativeDataInLogAxis');
switch plotRegime
    case 'AnalysisPlot'
        waveform.Plot.plotAnalysis(obj,h.ax);
        switch obj.analysisPlotOptions.plotType
            case 'plot3'
                h.ax.XAxis.Label.String = obj.xVar;
                h.ax.YAxis.Label.String = obj.yVar;
                h.ax.ZAxis.Label.String = obj.analysisPlotOptions.analysisType;
                view(h.ax,3);

            case 'lines'
                str = cellfun(@(a) num2str(a,'%.2f'),num2cell(obj.yVals),'uni',0);
                lgd = legend(h.ax,str,'location','eastoutside');
                h.ax.XAxis.Label.String = obj.xVar;
                h.ax.YAxis.Label.String = obj.yVar;
                title(lgd,obj.yVar);
                
            otherwise
                c = colorbar(h.ax);
                c.Label.FontSize = 12;
                c.Label.String = obj.analysisPlotOptions.analysisType; 
                
                h.ax.XAxis.Label.String = obj.xVar;
                h.ax.YAxis.Label.String = obj.yVar;
        end
        

    case 'WaveformPlot'
        obj.plot(h.ax);
end
warning('on','MATLAB:Axes:NegativeDataInLogAxis');
title(h.ax,titleStr);


h.figure.Name = titleStr;

drawnow limitrate


