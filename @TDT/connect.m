function connect(obj)
% connect(obj)

% make sure we're ocnnected with TTank.X
if isempty(obj.actXTT)
    f = findobj('type','figure','-and','tag','ActXTT');
    if isempty(f)
        obj.invisFig = figure('tag','ActXTT','Visible','off');
    else
        obj.invisFig = f;
    end
    
    try
        obj.actXTT = actxcontrol('TTank.X',[1 1 1 1],obj.invisFig);
        obj.actXTT.ConnectServer(obj.server,'Me');
        obj.connected = true;
    catch me
        % vprintf(1,me);
        obj.connected = false;
        errordlg(sprintf('Unable to create TTank.X: \n%s\n%s',me.identifier,me.message),'ControlPanel')
    end
end