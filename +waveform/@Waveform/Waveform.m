classdef Waveform < waveform.Analysis
    % obj = Waveform(samples,Fs,channel);
    %
    % NOTE: Here, "event" is used in a similar manner to "epoc" from TDT
    % parlance.
    
    
    properties
        
        Fs              double {mustBePositive, mustBeFinite} = 1 % 1x1
        samples         single {mustBeNumeric, mustBeFinite}   % Nx1 sampled data
        time            double {mustBeNumeric, mustBeFinite} % Nx1 timestamps; same size as samples
        channel         uint16 {mustBePositive, mustBeInteger, mustBeFinite} % 1x1 channel number
        
        Events          struct % waveform.Event

        timeWindow      double {mustBeFinite} = [0 1];
        timeWindowInclusive logical {mustBeNumericOrLogical} = [1 0]; % [onset offset]
         
        xVar            char
        yVar            char
        

        varStruct       struct
        
        plotOptions     waveform.Plot
        
        plotH           % store plot handles structure
        
        title           char
        
        info            char % general info
        UserData        % why not
        
    end
    
    properties (SetAccess = private, GetAccess = public)
        
        xVals           double
        yVals           double
        
        numSamples      double
        numTrials       uint32
        numTrialSamples uint32
        
        trialTimeVector    double
        trialSamplesVector uint32
        
        latestTimestamp   double
        
    end
    
    
    
    methods      
        C = getEpochData(obj,eventName);
        M = getEpochDataByValue(obj,varargin);
        
        % overloaded functions
        h = plot(obj,ax,h);
        
        
        
        
        % Constructor
        function obj = Waveform(samples,Fs,channel)
            if nargin >= 1, obj.samples = samples(:);  end
            if nargin >= 2, obj.Fs      = Fs;          end
            if nargin == 3, obj.channel = channel;     end
        end
        
        
        function obj = set.samples(obj,data)
            obj.samples = data(:);
%             notify(obj,'dataUpdate');
        end
        
        function obj = set.Fs(obj,Fs)
            obj.Fs = Fs;
%             notify(obj,'dataUpdate');
        end
        
        function obj = set.time(obj,time)
            if length(time) ~= length(obj.samples)
                me = Helpers.getME(mfilename('class'),'TimeDoesNotEqualSamples', 'size(time) ~= size(samples)');
                error(me);
            end
            obj.time = time(:);
%             notify(obj,'dataUpdate');
        end
        
        function t = get.time(obj)
            if ~isempty(obj.samples) && isempty(obj.time)
                t = (0:length(obj.samples)-1)'./obj.Fs;
            else
                t = obj.time;
            end
        end
        
        function t = get.latestTimestamp(obj)
            t = (length(obj.samples)-1) ./ obj.Fs;
            if t < 0, t = 0; end
        end
        
        function obj = set.channel(obj,num)
            obj.channel = num;
        end
        
        function num = get.channel(obj)
            num = obj.channel;
        end
        
        function y = get.yVals(obj)
            if isempty(obj.yVar)
                y = [];
            else
                y = obj.Events.(obj.yVar).distinct(obj.Events.(obj.yVar).activeIdx);
            end
        end
        
        function x = get.xVals(obj)
            if isempty(obj.xVar)
                x = [];
            else
                x = obj.Events.(obj.xVar).distinct(obj.Events.(obj.xVar).activeIdx);
            end
        end
        
        
        function title = get.title(obj)
            if isempty(obj.title)
                title = Helpers.genTitle(obj);
            end
        end
        
        function obj = set.timeWindow(obj,win)
            if numel(win) ~= 2
                error(Helpers.getME(mfilename('class'),'IncorrectNumValues','Must be a 1x2 matrix'));
            end
            if win(1) == win(2)
                error(Helpers.getME(mfilename('class'),'InvalidValues','Values must not be the same'));
            end
            obj.timeWindow = sort(win(:))';
        end
        
        function n = get.numSamples(obj)
            n = length(obj.samples);
        end
        
        function n = get.numTrials(obj)
            if isempty(obj.varStruct)
                if isempty(obj.yVar)
                    n = 0;
                    return
                end
            end
            D = obj.getEpochDataByValue;
            n = cellfun(@(a) size(a,2),D);
        end
        
        function n = get.numTrialSamples(obj)        
            if isempty(obj.varStruct)
                if isempty(obj.yVar)
                    n = 0;
                    return
                end
            end
            D = obj.getEpochDataByValue;
            n = cellfun(@(a) size(a,1),D);
        end
        

        function tvec = get.trialTimeVector(obj)
            % return time points for current timeWindow
            tvec = (obj.trialSamplesVector-1)/obj.Fs;
            
        end
        
        function wsmp = get.trialSamplesVector(obj)
            % return samples for current timeWindow
            wsmp = 1+single(floor(obj.Fs*obj.timeWindow(1)):ceil(obj.Fs*obj.timeWindow(2)));
            if ~obj.timeWindowInclusive(1), wsmp(1)   = []; end
            if ~obj.timeWindowInclusive(2), wsmp(end) = []; end
        end
        
        
        
        
        function disp(obj)
            fields = {'channel','numSamples','Fs', ...
                'timeWindow','xVar','yVar','xVals','yVals','numTrials'};
            s = Helpers.genDisp(obj,fields);
            fprintf('\nwaveform.Waveform\n%s\n',s)
        end
        
        
        
        function M = getMeanWaveform(obj)
            M = obj.getEpochDataByValue(obj.varStruct);
            if size(M,1) == 1, M = M'; end
            M = cellfun(@transpose,M,'uni',0);
            M = cellfun(@(a) mean(a,1),M,'uni',0);
        end
        
        function V = getVarWaveform(obj)
            V = obj.getEpochDataByValue(obj.varStruct);
            if size(V,1) == 1, V = V'; end
            V = cellfun(@transpose,V,'uni',0);
            V = cellfun(@(a) var(a,1),V,'uni',0);
        end
    
        function S  = get.varStruct(obj)
            xvar = obj.xVar;
            yvar = obj.yVar;
            
            if isempty(xvar) && isempty(yvar)
                S = [];
                return
            end
            
            if isempty(xvar)
                yvals = obj.yVals(obj.Events.(yvar).activeIdx);
                for y = 1:length(yvals)
                    S(1,y).(yvar) = yvals(y);
                end
            else
                xvals = obj.xVals(obj.Events.(xvar).activeIdx);
                yvals = obj.yVals(obj.Events.(yvar).activeIdx);
                for y = 1:length(yvals)
                    for x = 1:length(xvals)
                        S(x,y).(yvar) = yvals(y);
                        S(x,y).(xvar) = xvals(x);
                    end
                end
            end
        end
        
        
    end
    
end





