function addEvent(obj,name,onsets,info)
% addEvent(obj,name,onsets,info)

if nargin < 3 || isempty(onsets), onsets = {[]}; end
if nargin < 4 || isempty(info),   info = {[]};   end

if ischar(name),      name = {name};     end
if isnumeric(onsets), onsets = {onsets}; end
if ischar(info),      info = {info};     end
    
for i = 1:length(name)
    obj.event.(name{i}).onsets = onsets{i};
    obj.event.(name{i}).info   = info{i};
end
