function disconnect(obj)
% disconnect(obj)

try
    obj.actXTT.ReleaseServer;
    close(obj.invisFig);
    obj.connected = false;

catch me
%     vprintf(2,1,me);

end
