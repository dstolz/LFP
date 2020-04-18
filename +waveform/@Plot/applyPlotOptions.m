function applyPlotOptions(obj,ax)
%  applyPlotOptions(obj,ax)



ax.GridColor = [0 0 0];
ax.GridLineStyle = ':';
switch obj.grid
    case 'major'
        ax.XGrid = 'on';
        ax.YGrid = 'on';
    case 'minor'
        ax.XMinorGrid = 'on';
        ax.YMinorGrid = 'on';
    case 'all'
        ax.XGrid = 'on';
        ax.YGrid = 'on';
        ax.XMinorGrid = 'on';
        ax.YMinorGrid = 'on';
    case 'off'
        grid(ax,'off');
end
ax.Layer = 'top';

% PLOT TYPE SPECIFIC OPTIONSs
switch obj.plotType
    case 'imagesc'
        ax.XAxis.Scale = 'linear'; % must be linear
        set(ax,'ydir','normal');
        view(ax,2);
    otherwise
        ax.XAxis.Scale = obj.xScale;
end
