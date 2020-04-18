function success = openTank(obj,tank)
%  success = openTank(obj,[tank])

success = 0;


if (nargin < 2 || isempty(tank)) && obj.isValidTank(obj.activeTank)
    tank = obj.activeTank;
end

if ~ismember(tank,obj.tankList)
    me.message = sprintf('Tank "%s" was not found in the tankRootDir: "%s"', ...
        tank,obj.tankRootDir);
    me.identifier = 'lfp:TDT:set.activeTank:tankNotFound';
    me.stack = dbstack('-completenames');
    error(me);
end

if ~startsWith(tank,obj.tankRootDir,'IgnoreCase',true)
    tankPath = fullfile(obj.tankRootDir,tank);
end

% if isequal(obj.tankStatus,'Closed')
    success = obj.actXTT.OpenTank(tankPath,obj.tankMode(1));
% end

