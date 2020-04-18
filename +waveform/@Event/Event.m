classdef Event
% obj = Event(name,values,onsets,offsets,tolerance)

    properties
        
        name        char
        alias       char
        values      {mustBeFinite}
        onsets      {mustBeFinite}
        offsets     {mustBeNumeric}
        tolerance   {mustBeNumeric,mustBePositive}
        distinct    {mustBeFinite}
        activeIdx   uint32 {mustBePositive,mustBeInteger}
        units       char
        
    end
    
    properties (SetAccess = private, GetAccess = public)
        count       uint32
    end
    
    methods
        function obj = Event(name,values,onsets,offsets,tolerance)
            if nargin >= 1, obj.name = name;       end
            if nargin >= 2, obj.values = values;   end
            if nargin >= 3, obj.onsets = onsets;   end
            if nargin >= 4, obj.offsets = offsets; end
            if nargin == 5 && ~isempty(tolerance), obj.tolerance = tolerance; end
            
            obj.distinct = unique(obj.values);
        end
        
        function tol = get.tolerance(obj)
            if isempty(obj.tolerance)
                m = median(diff(obj.distinct));
                if isnan(m)
                    obj.tolerance = eps(class(obj.distinct));
                else
                    obj.tolerance = 0.1*m;
                end
            end
            tol = obj.tolerance;
        end
        
        function idx = get.activeIdx(obj)
            if isempty(obj.activeIdx)
                idx = 1:obj.count;
            else
                idx = obj.activeIdx;
            end
        end
        
        function n = get.count(obj)
            n = length(obj.distinct);
        end
        
        function a = get.alias(obj)
            if isempty(obj.alias)
                obj.alias = obj.name;
            end
            a = obj.alias;
        end
    end
    
end