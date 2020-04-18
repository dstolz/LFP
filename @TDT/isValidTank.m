function v = isValidTank(obj,tankPath)
% v = isValidTank(obj,tankPath)

v = false;

% look in a block (subdirectory)

if ~any(tankPath==filesep)
    tankPath = fullfile(obj.tankRootDir,tankPath);
end


blockdir = dir(tankPath);
blockdir(ismember({blockdir.name},{'.','..'})) = [];

if isempty(blockdir), return; end

ff = fullfile(tankPath,blockdir(1).name,'*.Tbk');
blockcont = dir(ff);
v = ~isempty(blockcont);
