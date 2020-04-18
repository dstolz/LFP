function plotPostProcessing(obj,ax)
P = obj.plotOptions;

ind = ishandle(ax);
assert(any(ind(:)),'waveform.Array:plotPostProcessing:NoValidAxes', ...
    'No valid axes were specified.');

for i = find(ind)'
    ax(i).Title.String  = '';
    ax(i).XLabel.String = '';
    ax(i).YLabel.String = '';
    ax(i).XTickLabel = [];
    ax(i).YTickLabel = [];
end

if sum(ind) > 1
    set(ax(ind(:,end),end),'yaxislocation','right');
end

if isempty(obj.xVar)
    ax(find(ind,1)).XLabel.String = 'time (ms)';
    set(ax(1,ind(1,:)),'XTickMode','auto');
    x = 1000*ax(find(ind(1,:),1)).XTick;
    set(ax(1,ind(1,:)),'XTickLabel',x);
else
    x = ax(find(ind,1)).XTick;
    xs = cellstr(num2str(obj.Events.(obj.xVar).distinct','%.1f'));
    
    if length(x) > 12
        v = round(linspace(1,length(x),10));
        idx = setdiff(1:length(x),v);
        for i = idx, xs{i} = ''; end
    end
    set(ax(1,ind(1,:)),'XTick',x,'XTickLabel',xs);
    ax(find(ind,1)).XLabel.String = obj.xVar;
end

y = ax(find(ind,1)).YTick;
ys = cellstr(num2str(obj.Events.(obj.yVar).distinct(:),'%.1f'));
if length(y) > 12
    v = round(linspace(1,length(y),10));
    idx = setdiff(1:length(y),v);
    for i = idx, ys{i} = ''; end
end

set(ax(ind(:,1),1),'YTick',y,'YTickLabel',ys);
set(ax(ind(:,end),end),'YTickLabel',ys);
ax(find(ind,1)).YLabel.String = obj.yVar;


switch P.axesType
    case 'overlay'
        c = obj.channelsActive;
        cm = P.channelColormap;
        titleStr = [obj.title ' | Channels: '];
        for i = 1:length(c)
            titleStr = sprintf('%s\\color[rgb]{%.4f %.4f %.4f}%d,',titleStr,cm(c(i),:),c(i));
        end
        titleStr(end) = [];
        ax.Title.String = titleStr;
        ax.Title.Interpreter = 'tex';
        ax.YAxisLocation = 'left';
        
    case 'tiled'
        if sum(ind(:)) > 1
            set(ax(ind(:,end),end),'YAxisLocation','right');
        else
            set(ax,'YAxisLocation','left');
        end
        
   
        c = findobj(P.container,'type','subplottext');
        if isempty(c)
            sgtitle(P.container,obj.title,'interpreter','none');
        else
            c.String = obj.title;
        end


end