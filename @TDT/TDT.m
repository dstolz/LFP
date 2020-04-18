classdef TDT < handle
    
    properties (Access = public, Transient)
        channelStrFmt   char = 'Channel_%03d';
    end
    
    
    properties (SetObservable,GetObservable,AbortSet)
        server          char = 'Local';
        streamName      char = 'Wave';
        tankRootDir     char
        activeTank      char
        activeBlock     char
        tankMode        char {mustBeMember(tankMode,{'Read','Monitor'})} = 'Read'
    end
    
    properties (SetAccess = private, GetAccess = public, Transient)
        connected = false;
    end
    
    properties (SetAccess = private, GetAccess = public, Dependent, Transient)
        tankList         cell
        blockList        cell
        
        % BLOCK
        blockHot         char
        blockMemo        char
        blockName        char
        blockNotes       char
        blockStartTime   char % USE FancyTime
        blockStopTime    char
        
        % CHANNEL
        channels         uint16
        channelsStr      cell
        
        
        % EPOC
        epocData         struct % epocData.(epoc name).values, .onsets, .offsets, .unique
        epocNames        cell
        
        
        % TANK
        tankStatus       char

        summary          char
    end
    
    properties (SetAccess = private, GetAccess = protected, Transient)
        actXTT       % ActiveX for TTankX        
        epocCodes       cell
        blockUpdated    logical = true; % true if block duration has changed
    end
    
    
    properties (Access = private, Transient)
        invisFig     % figure container for activex controls
        blkStpTm        char
    end
    
    
    
    
    
    
    
    
    
    
    
    
    
    methods
        % functions existing in separate files specific to @TDT class
        connect(obj);
        disconnect(obj);
        s = openTank(obj,tank);
        closeTank(obj);
        v = isValidTank(obj,tankPath);
        v = isValidBlock(obj,blockPath);
        [W,Fs] = getWaveformData(obj,channel,dataName)
        
        
        % Constructor TDT
        function obj = TDT
            obj.connect;
            
            addlistener(obj,'activeTank','PreSet',@obj.preSetActiveTank);

        end
        
        % Destructor
        function delete(obj)
            try
                obj.closeTank;
            end
            obj.disconnect;
        end
        
        
        
        % HELPERS =========================================================
        function set.tankRootDir(obj,path)
            % just make sure it is a folder and that's it, because it may
            % be a new tank about to be recorded into.
            if ~isfolder(path), return; end
            obj.tankRootDir = path;
        end
        
        function path = get.tankRootDir(obj)
            path = obj.tankRootDir;
        end
        
        function tanks = get.tankList(obj)
            if isempty(obj.tankRootDir)
                tanks = {[]};
                return
            end
            d = dir(obj.tankRootDir);
            d(~[d.isdir]) = [];
            n = {d.name};
            n(ismember(n,{'.','..'})) = [];
            ind = cellfun(@(a) obj.isValidTank(a),n);
            tanks = n(ind);
        end
        
        function blocks = get.blockList(obj)
            if isempty(obj.tankRootDir) || isempty(obj.tankList)
                blocks = {[]};
                return
            end
            
            i = 1;
            blocks{i} = obj.actXTT.QueryBlockName(0); % initialize query
            while 1
                blocks{i} = obj.actXTT.QueryBlockName(i-1);
                if isempty(blocks{i})
                    break
                end
                i = i + 1;
            end
            blocks(end) = [];
            blocks = unique(blocks);
            
            if isempty(blocks) % try manually
                d = dir(fullfile(obj.tankRootDir,obj.activeTank));
                d(~[d.isdir]) = [];
                n = {d.name};
                n(ismember(n,{'.','..'})) = [];
                ind = cellfun(@(a) obj.isValidBlock(a),n);
                blocks = n(ind);
            end
        end
        
        
        
        
        
        
        
        % TANK ============================================================
        function set.activeTank(obj,tank)
            if isempty(tank) % closed tank
                obj.activeTank = '';
                return
            end
            
            if ~obj.connected, obj.connect; end
            
            obj.activeTank = tank;
            obj.openTank(tank);
            assert(~isequal(obj.tankStatus,'Cpen'), ...
                'lfp:TDT:set.activeTank', ...
                'Unable to open tank "%s"',tank)
        end
        
        function preSetActiveTank(obj,src,evnt)
            if obj.connected && ~isempty(obj.activeTank) && ~isequal(obj.tankStatus,'Closed')
                obj.closeTank;
            end
        end
        
        function tank = get.activeTank(obj)
            tank = obj.activeTank;
        end
        
        function status = get.tankStatus(obj)
            s = obj.actXTT.CheckTank(fullfile(obj.tankRootDir,obj.activeTank));
            switch s
                case 67
                    status = 'Closed';
                case 79
                    status = 'Open';
                case 82
                    status = 'Recording';
                otherwise
                    status = num2str(s);
            end
        end
        
        
        
        % BLOCK ===========================================================
        function set.activeBlock(obj,block)
            if isempty(block) % closed tank
                obj.activeBlock = '';
                return
            end
            
            assert(ismember(block,obj.blockList), ...
                'lfp:TDT:set.activeBlock:invalidBlock', ...
                'Invalid block "%s" in tank "%s"', ...
                block,fullfile(obj.tankRootDir,obj.activeTank))
            success = obj.actXTT.SelectBlock(['~' block]);
            if success
                obj.activeBlock = block;
            end
        end
        
        function block = get.activeBlock(obj)
            block = obj.activeBlock;
            obj.blockUpdated = true;
        end
        
        function name = get.blockName(obj)
            name = obj.actXTT.BlockName;
        end
        
        function memo = get.blockMemo(obj)
            memo = obj.actXTT.CurBlockMemo;
        end
        
        function notes = get.blockNotes(obj)
            notes = obj.actXTT.CurBlockNotes;
        end
        
        function startTime = get.blockStartTime(obj)
            start = obj.actXTT.CurBlockStartTime;
            startTime = obj.actXTT.FancyTime(start ,'D/O/Y H:M:S.U');
        end
        
        function stopTime = get.blockStopTime(obj)
            stop = obj.actXTT.CurBlockStopTime;
            stopTime = obj.actXTT.FancyTime(stop,'D/O/Y H:M:S.U');
        end
        
        function hot = get.blockHot(obj)
            hot = obj.actXTT.GetHotBlock;
        end
        
        function updated = get.blockUpdated(obj)
            updated = isempty(obj.blkStpTm) ...
                || ~isequal(obj.blkStpTm,obj.blockStopTime);
            if updated, obj.blkStpTm = obj.blockStopTime; end
        end
        
        function set.blkStpTm(obj,tm)
            obj.blkStpTm = tm;
        end
        
        
        % EPOC ============================================================
        function codes = get.epocCodes(obj)
            % retrieve epoc codes
            codes = [];
            if ~obj.connected, return; end
            i = 1;
            while 1
                t = obj.actXTT.GetEpocCode(i-1);
                if isempty(t), break; end
                codes{i} = t; %#ok<AGROW>
                i = i + 1;
            end
        end
        
        function epocData = get.epocData(obj)
            % retrieve additional information about epocData
            % depends on epocCodes
            epocData = [];
            codes = obj.epocCodes;
            if isempty(codes), return; end
            for i = 1:length(codes)
                t = obj.actXTT.GetEpocsV(codes{i},0,0,10^6);
                epocData.(codes{i}).values  = t(1,:);
                epocData.(codes{i}).onsets  = t(2,:);
                if all(t(3,:)==0) % no offset timestamp
                    epocData.(codes{i}).offsets = nan(size(t(3,:)));
                else
                    epocData.(codes{i}).offsets = t(3,:);
                end
                epocData.(codes{i}).unique    = unique(t(1,:));
                tol = min(diff(epocData.(codes{i}).unique))*0.1; 
                if isempty(tol) || isnan(tol), tol = eps('single'); end
                epocData.(codes{i}).tolerance = tol;
            end
            
        end
        
        function names = get.epocNames(obj)
            % return epoc names
            % depends on epocCodes
            
            e = obj.epocData;
            if isempty(e)
                names = [];
            else
                names = fieldnames(e);
            end
        end
        
        
        
        % CHANNEL =========================================================
        function ch = get.channels(obj)
            % find available channels 
            n = obj.actXTT.ReadEventsV(1024,obj.streamName,0,0,0,0,'NODATA');
            ch = unique(obj.actXTT.ParseEvInfoV(0,n,4));
        end
        
        function set.channelStrFmt(obj,strFormat)
            obj.channelStrFmt = strFormat;
        end
        
        
        function cstr = get.channelsStr(obj)
            ch = obj.channels;
            cstr = arrayfun(@(a) sprintf(obj.channelStrFmt,a),ch,'uni',0);
        end
        
        
        % OTHER ===========================================================
        function s = get.streamName(obj)
            s = obj.streamName;
        end
        
        function set.streamName(obj,s)
            s = char(s);
            if length(s) ~= 4 % TDT requirement
                me.identifier = 'TDT:set.streamName:InvalidStreamName';
                me.message    = sprintf('Invalid stream name "%s"',s);
                me.stack      = dbstack('-completenames');
                error(me)
            end
            obj.streamName = s;
        end
        
        function s = get.summary(obj)
            
            s = sprintf([ ...
                'Tank Directory:  %s\n', ...
                'Tank Name:       %s\n', ...
                'Block Name:      %s\n', ...
                'Block Start:     %s\n', ...
                'Block Stop:      %s\n', ...
                'Channel ID:      %s\n'], ... 
                obj.tankRootDir, ...
                obj.activeTank, ...
                obj.activeBlock, ...
                obj.blockStartTime, ...
                obj.blockStopTime, ...
                mat2str(obj.channels));
            
            e = obj.epochNames;
            for i = 1:length(e)
                s = sprintf('%svar %d:\t"%s"\n',s,i,e{i});
            end
                
        end
        
        
        % overloaded functions ============================================
        function disp(obj)
            fields = {'connected','server','tankRootDir','activeTank','activeBlock', ...
                'channels','blockStartTime','blockStopTime','streamName', ...
                'tankList','blockList'};
            s = Helpers.genDisp(obj,fields);
            disp(s)
        end
        
        
    end
end











