function ax = setupPlotAx(obj,ax)
% ax = setupPlotAx(obj,ax)

if nargin < 2 || isempty(ax)
    if isempty(obj.ax)
        ax = gca; 
    else
        ax = obj.ax;
    end
end



ax.SortMethod = 'childorder';
ax.Interruptible = 'off';
% ax.Title.String = 'Plotting ...';
ax.YAxis.TickValues = [];
ax.XAxis.TickValues = [];
ax.YAxis.Label.String = '';
ax.XAxis.Label.String = '';
drawnow

