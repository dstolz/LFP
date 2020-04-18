function h = plotContinuous(obj,ax,varargin)


if nargin < 2, ax = []; end
ax = obj.setupPlotAx(ax);

maxy = max(abs(obj.samples))*0.8;




validVars = obj.validEventNames;

xtest = xlim(ax).*[0.1 5];

c = lines;
hold(ax,'on');
for i = 1:numel(validVars)
    ons = obj.event.(validVars{i}).onsets;
    ind = ons>=xtest(1) & ons <= xtest(2);
    ons = ons(ind);
    onv = obj.event.(validVars{i}).values(ind);
    off = obj.event.(validVars{i}).offsets;
    off = off(off>=xtest(1) & off <= xtest(2));
    
    y = (maxy-(maxy*i*0.1))*ones(1,length(ons));
    dy = double(y(1));
    
    h.lineEventOnset.(validVars{i}) = plot(ax,[ons; ons],[y; -y],'-','color',c(i,:));
    h.markerEventOnset.(validVars{i}) = plot(ax,[ons; ons+1/obj.Fs*10],[y; y], ...
        '-','color',c(i,:));
    
    for j = 1:length(onv)
        h.textEventValue.(validVars{i})(j) = text(ax,ons(j)+1/obj.Fs*10,dy, ...
            [validVars{i} '=' num2str(onv(j))]);
        if i == 1
            text(ax,ons(j)+5/obj.Fs,-dy,num2str(j));
        end
    end
    set(h.textEventValue.(validVars{i}),'color',c(i,:),'fontsize',8);
        
    
    
    if ~all(isnan(off))
        h.lineEventOffset.(validVars{i}) = plot(ax,[off; off],[y; -y],'-','color',c(i,:));
        h.markerEventOffset.(validVars{i}) = plot(ax,[off; off-1/obj.Fs*10],[y; y], ...
            '-','color',c(i,:));
        text(ax,ons(j)-5/obj.Fs,dy,num2str(j));
    end
    
end

% plot continuous single
ind = obj.time >= xtest(1) & obj.time <= xtest(2);
h.lineSignal = plot(ax,obj.time(ind),obj.samples(ind),'-k','linewidth',2);

hold(ax,'off');


ax.XLim = [-0.5*ons(1) 4.5*mean(diff(ons))];
ax.YLim = [-1 1]*maxy;

ax.XAxis.Label.String = 'time (s)';
ax.YAxis.Label.String = 'voltage';

ax.XAxis.TickValuesMode = 'auto';
ax.YAxis.TickValuesMode = 'auto';



obj.applyPlotOptions(ax);



ax.Title.String = '';

% PAN NOT WORKING PROPERLY YET
if isa(ax,'matlab.ui.control.UIAxes')
    p = pan; % p = pan(ax); throws error if uiaxes?
else
    p = pan(obj.plotFig);
end
p.Motion = 'horizontal';
p.Enable = 'on';
p.ActionPostCallback = @obj.plotContinuous;


