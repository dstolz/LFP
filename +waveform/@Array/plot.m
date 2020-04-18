function obj = plot(obj,container,resetLineHandles)
% obj = plot(waveform.Array,[container],[resetLineHandles])

P = obj.plotOptions;

if nargin < 2 || isempty(container), P.container = gcf; else, P.container = container; end
if nargin < 3 || isempty(resetLineHandles), resetLineHandles = true; end

if isa(P.container,'matlab.ui.Figure'), P.container.Pointer = 'watch'; drawnow; end

if isempty(P.container.Name)
    P.container.Name = 'WaveformPlot';
end

switch P.axesType
    case 'tiled'
        ax = waveform.Plot.designTiled(P.container, ...
            numel(obj.channelsActive),P.channelSpacing, ...
            P.containerBorder);
        
    case 'overlay'
        delete(get(P.container,'children'));
        ax = axes(P.container);
end


P.ax = ax;

ch  = obj.channelsActive;
idx = obj.getIdxByChannel(ch);

delete(ax(numel(idx)+1:end));

fprintf('Plotting ')
for i = 1:numel(idx)
    obj.Waveform(idx(i)).varStruct = obj.varStruct;
    obj.Waveform(idx(i)).info = obj.info;
    
    switch P.axesType
        case 'tiled'
            obj.Waveform(idx(i)).plotOptions = P;
            obj.Waveform(idx(i)).plotOptions.ax = P.ax(i);
            
            if resetLineHandles, h = []; else,  h = obj.Waveform(idx(i)).plotH; end

            obj.Waveform(idx(i)).plotOptions.plotH = plot(obj.Waveform(idx(i)),ax(i),h);

            ax(i).ButtonDownFcn = @waveform.Plot.popoutPlot;
            arrayfun(@(a) setfield(a,'ButtonDownFcn',@waveform.Plot.popoutPlot),ax(i).Children,'uni',0);
            arrayfun(@(a) setfield(a,'PickableParts','all'),ax(i).Children,'uni',0);
            h = waveform.Plot.placeAxText(ax(i),num2str(obj.Waveform(idx(i)).channel),'bottom-right');
            h.FontWeight = 'bold';
            
            ax(i).UserData = obj.Waveform(idx(i));
            
            
        case 'overlay'
            obj.Waveform(idx(i)).plotOptions = P;
            plot(obj.Waveform(idx(i)),ax);
            ax.XLabel.String = '';
            ax.YLabel.String = '';
    end
    fprintf('.')
end

obj.plotOptions = P;

waveform.Array.plotPostProcessing(obj,ax);

fprintf(' done\n')

if isa(P.container,'matlab.ui.Figure'), P.container.Pointer = 'arrow'; end
