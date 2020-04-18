function v = isValidBlock(obj,block)
% v = isValidBlock(obj,blockPath)

b = dir(fullfile(obj.tankRootDir,obj.activeTank,block,'*.Tbk'));
v = ~isempty(b);

