function plotAnalysisPostProcessing(obj,ax)

P = obj.analysisPlotOptions;

ind = ishandle(ax);

set(ax(ind),'xtickmode','auto','ytickmode','auto', ...
    'yticklabelmode','auto','xticklabelmode','auto', ...
    'yaxislocation','left');

for i = find(ind)'
    ax(i).Title.String  = '';
    ax(i).XLabel.String = '';
    ax(i).YLabel.String = '';
    ax(i).XTickLabel = [];
    ax(i).YTickLabel = [];
end

if sum(ind(:)) > 1
    a = ax(2:end,:); a = a(ind(2:end,:));
    set(a,'XTickLabel','');
    a = ax(:,2:end-1); a = a(ind(:,2:end-1));
    set(a,'YTickLabel','');
    a = ax(:,1); a = a(ind(:,1));
    set(a,'YTickLabelMode','auto');
    a = ax(:,end); a = a(ind(:,end));
    set(a,'YTickLabelMode','auto');
    a = ax(:,2:end); a = a(ind(:,2:end));
    set(a,'YAxisLocation','right');
end

if isempty(obj.xVar)
    ax(find(ind,1)).XLabel.String = obj.yVar;
    ax(find(ind,1)).YLabel.String = P.analysisType;
else
    ax(find(ind,1)).XLabel.String = obj.xVar;
    ax(find(ind,1)).YLabel.String = obj.yVar;
    ax(find(ind,1)).ZLabel.String = P.analysisType;
end



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
        
        
        titleStr = obj.title;
        titleStr = [titleStr ' | ', P.analysisType];
        
        c = findobj(P.container,'type','subplottext');
        if isempty(c)
            sgtitle(P.container,titleStr,'interpreter','none');
        else
            c.String = titleStr;
        end
        
        
        switch P.plotType
            case 'plot3'
                axlink = linkprop(ax(ind),{ 'CameraPosition', 'CameraTarget', 'XLim', 'YLim', 'ZLim'});
                setappdata(P.container, 'axlink', axlink);
                
                set(ax(ind),'xlimmode','auto','ylimmode','auto','zlimmode','auto');
                
                x = cell2mat(get(ax(ind),'xlim'));
                y = cell2mat(get(ax(ind),'ylim'));
                z = cell2mat(get(ax(ind),'zlim'));
                
                set(ax(ind), ...
                    'xlim',[min(x(:))*0.9 max(x(:))*1.1], ...
                    'ylim',[min(y(:))*0.9 max(y(:))*1.1], ...
                    'zlim',[min(z(:))*0.9 max(z(:))*1.1]);

                % hack to get axes to align properly
                % all axes should already be linked
                view(ax(find(ind,1)),2);
                view(ax(find(ind,1)),3);

            case 'line'
                axlink = linkprop(ax(ind),{'XLim', 'YLim'});
                setappdata(P.container, 'axlink', axlink);
                set(ax(ind),'xlimmode','auto','ylimmode','auto');
                x = cell2mat(get(ax(ind),'xlim'));
                y = cell2mat(get(ax(ind),'ylim'));
                set(ax(ind),'xlim',[min(x(:))*0.9 max(x(:))*1.1], ...
                    'ylim',[min(y(:))*0.9 max(y(:))*1.1]);
                view(ax(find(ind,1)),2);
                
                
            case 'lines'
                axlink = linkprop(ax(ind),{'XLim', 'YLim', 'ZLim'});
                setappdata(P.container, 'axlink', axlink);
                set(ax(ind),'xlimmode','auto','ylimmode','auto');
                x = cell2mat(get(ax(ind),'xlim'));
                y = cell2mat(get(ax(ind),'ylim'));
                set(ax(ind),'xlim',[min(x(:))*0.9 max(x(:))*1.1], ...
                    'ylim',[min(y(:))*0.9 max(y(:))*1.1]);
                view(ax(find(ind,1)),2);
                
            case {'imagesc','contour','contourf'}
                set(ax(ind),'climmode','auto','zlimmode','auto');
                c = get(ax(ind),'clim');
                if sum(ind(:)) == 1, c = {c}; end
                c = [c{:}];
                c = [min(c) max(c)];
                set(ax(ind),'clim',c);
                axlink = linkprop(ax(ind),{'CameraPosition', 'CameraTarget', 'XLim', 'YLim', 'CLim'});
                setappdata(P.container, 'axlink', axlink);
                view(ax(find(ind,1)),2);

            otherwise
                set(ax(ind),'zlimmode','auto');
                z = get(ax(ind),'zlim');
                if sum(ind(:)) == 1, z = {z}; end
                z = [z{:}];
                z = [min(z) max(z)];
                set(ax(ind),'zlim',z);
                axlink = linkprop(ax(ind),{ 'CameraPosition', 'CameraTarget', 'XLim', 'YLim', 'ZLim'});
                setappdata(P.container, 'axlink', axlink);
                
                % hack to get axes to align properly
                % all axes should already be linked
                view(ax(find(ind,1)),2);
                view(ax(find(ind,1)),3);
                
        end
        
        
end
