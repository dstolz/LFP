function obj = plotAnalysis(obj,ch,refreshFigure)
if nargin < 2 || isempty(ch), ch = obj.channelsActive; end
if nargin < 3 || isempty(refreshFigure), refreshFigure = true; end

warning('off','MATLAB:Axes:NegativeDataInLogAxis');

P = obj.analysisPlotOptions;

if isa(P.container,'matlab.ui.Figure'), P.container.Pointer = 'watch'; drawnow; end


P.container.Colormap = P.channelColormap;

if refreshFigure
    switch P.axesType
        case 'tiled'
            set(P.container,'Colormap',P.channelColormap);
            P.ax = waveform.Plot.designTiled(P.container, ...
                numel(obj.channelsActive),P.channelSpacing, ...
                0.15);
        case 'overlay'
            delete(get(P.container,'children'));
            P.ax = axes(P.container);
    end
end

ax = P.ax;

idx = obj.getIdxByChannel(ch);

fprintf('Plotting ')
for i = 1:numel(idx)
    obj.Waveform(idx(i)).analysisPlotOptions = P;
    obj.Waveform(idx(i)).varStruct           = obj.varStruct;
    obj.Waveform(idx(i)).info                = obj.info;
    
    switch P.axesType
        case 'tiled'
            obj.Waveform(idx(i)).analysisPlotOptions.ax    = ax(idx(i));
            obj.Waveform(idx(i)).analysisPlotOptions.plotH = waveform.Plot.plotAnalysis(obj.Waveform(idx(i)),ax(idx(i)));
            if ~isequal(P.plotType,'plot3') && isa(obj.Waveform(idx(i)).analysisPlotOptions.plotH,'matlab.graphics.chart.primitive.Line')
                obj.Waveform(idx(i)).analysisPlotOptions.plotType = 'line';
                P.plotType = 'line';
            end
            ax(i).ButtonDownFcn = @waveform.Plot.popoutPlot;
            arrayfun(@(a) setfield(a,'ButtonDownFcn',@waveform.Plot.popoutPlot),ax(idx(i)).Children,'uni',0);
            arrayfun(@(a) setfield(a,'PickableParts','all'),ax(idx(i)).Children,'uni',0);
            ax(idx(i)).UserData = obj.Waveform(idx(i));
            h = waveform.Plot.placeAxText(ax(idx(i)),num2str(obj.Waveform(idx(i)).channel),'bottom-right');
            h.FontWeight = 'bold';
            
        case 'overlay'
            obj.Waveform(idx(i)).analysisPlotOptions = P;
            waveform.Plot.plotAnalysis(obj.Waveform(idx(i)),ax);
    end
    fprintf('.')
end
fprintf(' done\n')
switch P.axesType
    case 'tiled'
        
    case 'overlay'
        %                     s = arrayfun(@(a) sprintf('Channel %d',a),obj.channelsActive,'uni',0);
        %                     legend(ax,s,'Location','Best');
        ax.XLabel.String = obj.yVar;
        ax.YLabel.String = P.analysisType;
        ax.Title.String  = obj.title;
end

P.ax = ax;

obj.analysisPlotOptions = P;

waveform.Array.plotAnalysisPostProcessing(obj,ax);


warning('on','MATLAB:Axes:NegativeDataInLogAxis');

if isa(P.container,'matlab.ui.Figure'), P.container.Pointer = 'arrow'; end


