classdef Array
%     obj = Array(samples,Fs,channels)
% samples: Numerical vector or matrix with NxM dimensions,
%          where N is the number of samples and M the number of
%          channels. No default value, required.
% Fs:      Sampling rate in Hz (scalar). Default = 1;
% channels: Nx1 channel IDs (uint). Default = 1:N

    properties
        Events          struct % waveform.Event

        Waveform        waveform.Waveform

        timeWindow      double {mustBeNumeric, mustBeFinite} = [0 1]  % [onset offset]
        timeWindowInclusive logical = [1 0] % window test if true: >= | <=, false > | <

        xVar            char
        yVar            char
        
        varStruct       struct
        
        channelsActive  uint16 {mustBeNonnegative,mustBeInteger} = 0; % 0: all channels
        channelMap      uint16 {mustBePositive,mustBeInteger}
        
        plotOptions         waveform.Plot = waveform.Plot;
        analysisPlotOptions waveform.Plot = waveform.Plot;
        
        info            char
        UserData
    end
    
    
    properties (SetAccess = private, GetAccess = public, Dependent, Transient)
        eventNames      cell
        numChannels     uint16
        channels        uint16
        samples         double
        title           char
        Fs              double
    end
    
    
    methods (Static)
        plotPostProcessing(obj,ax);
        plotAnalysisPostProcessing(obj,ax);
    end
    
    
    methods
        addEvent(obj,name,onsets,info);
        removeEvent(obj,name); 
        
        obj = plotAnalysis(obj,ch,refreshFigure);
        
        % overloaded functions
        obj = plot(obj,container,resetLineHandles);

        % Constructor
        function obj = Array(samples,Fs,channels)
            % samples: Numerical vector or matrix with NxM dimensions, 
            %          where N is the number of samples and M the number of
            %          channels. No default value, required.
            % Fs:      Sampling rate in Hz (scalar). Default = 1;
            % channels: Nx1 channel IDs (uint). Default = 1:N
            
            if nargin < 2, Fs = 1; end
            if nargin < 3, channels = []; end
            
            if nargin >= 1
                if isempty(channels), channels = 1:size(samples,2); end
                for c = 1:size(samples,2)
                    idx = obj.getIdxByChannel(channels(c));
                    if isempty(idx) || isnan(idx), idx = channels(c); end
                    obj.Waveform(idx) = waveform.Waveform(samples(:,c),Fs,channels(c));
%                     obj.Waveform(idx) = waveform.Analysis(samples(:,c),Fs,channels(c));
                end
            end
                        
        end
        
        
        
        
        % Set/Get =========================================================
        function names = get.eventNames(obj)
            names = fieldnames(obj.Events);
        end
        
        function obj = set.xVar(obj,eventName)
            if isempty(eventName), obj.xVar = ''; end
            
            mustBeMember(eventName,[{''}; obj.eventNames]);
            
            obj.xVar = eventName;
            
            for i = 1:obj.numChannels
                obj.Waveform(i).xVar = eventName;
            end
        end
        
        
        function obj = set.yVar(obj,eventName)
            if isempty(eventName), obj.yVar = ''; return; end
            mustBeMember(eventName,obj.eventNames);
            obj.yVar = eventName;
            for i = 1:obj.numChannels
                obj.Waveform(i).yVar = eventName;
            end
        end
        
        
        function obj = set.varStruct(obj,varStruct)
            for i = 1:obj.numChannels
                obj.Waveform(i).varStruct = varStruct;
            end
        end
        
        function varStruct = get.varStruct(obj)
            varStruct = obj.Waveform(1).varStruct;
        end
        
        
        
        function obj = set.timeWindow(obj,win)
            if numel(win) ~= 2
                error(Helpers.getME(mfilename('class'),'IncorrectNumValues','Must be a 1x2 matrix'));
            end
            if win(1) == win(2)
                error(Helpers.getME(mfilename('class'),'InvalidValues','Values must not be the same'));
            end
            obj.timeWindow = sort(win(:))';
            for i = 1:obj.numChannels
                obj.Waveform(i).timeWindow = obj.timeWindow;
            end
        end
        
        function obj = set.timeWindowInclusive(obj,inc)
            if numel(inc) ~= 2
                error(Helpers.getME(mfilename('class'),'IncorrectNumValues','Must be a 1x2 matrix'));
            end
            set(obj.Waveform,'timeWindowInclusive',inc);
        end
        
        function samples = get.samples(obj)
            samples = [];
            
            % PRELIMINARY: NEED TO ACCOUNT FOR UNEQUAL SAMPLE LENGTHS
            for i = 1:length(obj.Waveform)
                samples(:,i) = obj.Waveform(i).samples;
            end
        end
        
        function channels = get.channels(obj)
            channels = [obj.Waveform.channel];
        end
        
        function ch = get.channelsActive(obj)
            if obj.channelsActive == 0, obj.channelsActive = obj.channels; end
            ch = intersect(obj.channelsActive,obj.channels);
        end
        
        function obj = set.channelsActive(obj,channels)
            if all(channels == 0)
                obj.channelsActive = [obj.Waveform.channel];
                
            elseif ~all(ismember(channels,obj.channels))
                error(Helpers.getME(mfilename('class'),'UndefinedChannels', ...
                    'Undefined channels: %s',mat2str(channels)));
                
            else
                obj.channelsActive = channels;
            end
        end
        
        function obj = set.channelMap(obj,map)
            if ~ismatrix(map)
                error(Helpers.getME(mfilename('class'),'InvalidDimensions', ...
                    'channelMap must be m x n matrix'));
            end
            
            if numel(intersect(obj.channels,map(:))) ~= obj.numChannels
                error(Helpers.getME(mfilename('class'),'NumelMismatch', ...
                    'channelMap must have the same number of values as channels'));
            end
            
            obj.channelMap = map;
        end
        
        function map = get.channelMap(obj)
            if isempty(obj.channelMap)
                obj.channelMap = obj.channels;
            end
            map = obj.channelMap;
        end
        
        
        function n = get.Fs(obj)
            if obj.numChannels == 0
                n = 1;
            else
                n = obj.Waveform(1).Fs;
            end
        end
        
        
        function title = get.title(obj)
            i = Helpers.getInfoStr(obj.info);
            if isempty(i)
                title = '';
                return
            end
            title = sprintf('%s | %s',i.TankName,i.BlockName);
        end
        
  
        function n = get.numChannels(obj)
            n = numel(obj.Waveform);
        end
        
        
        function obj = set.Events(obj,ev)
            for i = 1:obj.numChannels
                obj.Waveform(i).Events = ev;
            end
            obj.Events = ev;
        end
        
        
%         
%         function obj = set.plotOptions(obj,P)
%             for i = 1:obj.numChannels
%                 obj.Waveform(i).plotOptions = P;
%                 if ~isempty(P.ax) && numel(P.ax) == obj.numChannels
%                     obj.Waveform(i).plotOptions.ax = P.ax(i);
%                 end
%             end
%         end
%         
%         function P = get.plotOptions(obj)
%             P = obj.Waveform(1).plotOptions;
%             if isempty(P), P = waveform.Plot; end
%         end
%         
%         function obj = set.analysisPlotOptions(obj,P)
%             for i = 1:obj.numChannels
%                 obj.Waveform(i).analysisPlotOptions = P;
%                 if ~isempty(P.ax) && numel(P.ax) == obj.numChannels
%                     obj.Waveform(i).analysisPlotOptions.ax = P.ax(i);
%                 end
%             end
%         end
%         
%         function P = get.analysisPlotOptions(obj)
%             P = obj.Waveform(1).analysisPlotOptions;
%             if isempty(P), P = waveform.Plot; end
%         end
       
        
        
        % Helpers =========================================================
        function cidx = getIdxByChannel(obj,c)
            cidx = nan(size(c));
            ch = obj.channels;
            if isempty(ch), return; end
            for i = 1:length(c)
                ind = c(i) == ch;
                if any(ind)
                    cidx(i) = find(ind);
                end
            end
        end

        function m = getMaxAnalysisValue(obj,type)
            m = -inf;
            for i = 1:obj.numChannels
                m = max([obj.Waveform(i).(type)(:); m]);
            end
        end
        
        
        
       
        % overloaded functions --------------------------------------------
        
        function disp(obj)
            fields = {'title','Fs','numChannels', ...
                'channels','channelsActive','channelMap', ...
                'eventNames','xVar','yVar', ...
                'timeWindow','timeWindowInclusive'};
            s = Helpers.genDisp(obj,fields);
            fprintf('waveform.Array\n%s\n',s)
        end
        
        function n = length(obj)
            n = length(obj.Waveform);
            
        end
        
        function d = size(obj)
            d = size(obj.Waveform);
        end
        
    end
    
    
    
    
    
    
    
    
end



