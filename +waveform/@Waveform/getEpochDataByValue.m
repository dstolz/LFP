function M = getEpochDataByValue(obj,varStruct)
% M = getEpochDataByValue(obj)
% M = getEpochDataByValue(obj,varStruct)
% 
% Retrieve data matrix time-locked to the onset of one or more
% simultaneously occuring events.
% 
% varStruct, if specified, must be a structure with field names equivalent to
% obj.eventNames.
% 
% varStruct can also be a matrix of structures which will return an equivalently
% sized cell matrix filled with time-locked data.
% 
% If not specified, then varStruct = obj.varStruct if obj.xVar and obj.yVar have been
% specified.
% 
% ex:
%       varStruct = struct('Levl',70,'Freq',1000);
%       M = obj.getEpochDataByValue(varStruct);
% 
% ex:   % results in cell matrix M with size 2 x 2
%       varStruct(1,1).Levl = 10;         varStruct(1,2).Levl = 10;
%       varStruct(1,1).Freq = 1000;       varStruct(1,2).Freq = 4000;
%       varStruct(2,1).Levl = 30;         varStruct(2,2).Levl = 30;
%       varStruct(2,1).Freq = 1000;       varStruct(2,2).Freq = 4000;
%       M = obj.getEpochDataByValue(varStruct);
%       
% see also, updateVars


if nargin == 1, varStruct = obj.varStruct; end

% t = tic;

if ~isstruct(varStruct) 
    error(lfp.Helpers.getME('InvalidInput','varStruct must be a struct or created using updateVars'));
end

M = cell(size(varStruct));

f = fieldnames(varStruct);

C = obj.getEpochData(f{1});

for k = 1:numel(varStruct)
    ind = true(size(obj.Events.(f{1}).values));
    for i = 1:length(f)
        ind = ind & obj.Events.(f{i}).values >= varStruct(k).(f{i})-obj.Events.(f{i}).tolerance ...
                  & obj.Events.(f{i}).values <= varStruct(k).(f{i})+obj.Events.(f{i}).tolerance;
    end
    
    if ~any(ind), continue; end
    
    M{k} = C(:,ind);
end

% fprintf('lfp.Waveform.getEpochDataByValue runtime: %0.2f s\n',toc(t));









