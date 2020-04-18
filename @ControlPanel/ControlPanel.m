classdef ControlPanel < handle
    
    
    % Properties that correspond to obj components
    properties (Access = private, Transient)
        h_mainFigure         matlab.ui.Figure
        h_leftPanel          % matlab.ui.control.Panel
        h_middleBottomPanel
        h_dropdownTanks      matlab.ui.control.DropDown
        h_dropdownBlocks     matlab.ui.control.DropDown
        h_buttonSelectAllChannels       matlab.ui.control.Button
        h_buttonSelectOddEvenChannels   matlab.ui.control.Button
        h_listChannels       matlab.ui.control.ListBox
        h_labelXVar          matlab.ui.control.Label
        h_dropdownXVar       matlab.ui.control.DropDown
%         h_buttonXVar         matlab.ui.control.Button
        h_labelYVar          matlab.ui.control.Label
        h_dropdownYVar       matlab.ui.control.DropDown
%         h_buttonYVar         matlab.ui.control.Button
        h_locatePlots        matlab.ui.control.Button
        h_labelTanks         matlab.ui.control.Label
        h_labelBlocks        matlab.ui.control.Label
        h_editTankRootDir    matlab.ui.control.EditField
        h_locateTankRootDir  matlab.ui.control.Button
        h_dropdownAxesType   matlab.ui.control.DropDown
        h_monitorData        matlab.ui.control.StateButton
        h_rightTopPanel       
        h_rightBottomPanel
        h_middlePanel
        h_labelTimeWin       matlab.ui.control.Label
        h_editTimeWin        matlab.ui.control.EditField
        h_checkboxNormalize  matlab.ui.control.CheckBox
        h_labelAmpScale      matlab.ui.control.Label
        h_numeditAmpScale    matlab.ui.control.NumericEditField
        h_labelGrid          matlab.ui.control.Label
        h_dropdownGrid       matlab.ui.control.DropDown
        h_buttonUpdatePlot   matlab.ui.control.Button
        h_buttonLocatePlots  matlab.ui.control.Button
        h_labelMaxTraces     matlab.ui.control.Label
        h_numeditMaxTraces   matlab.ui.control.NumericEditField
        h_dropdownAnalysisType      matlab.ui.control.DropDown
        h_dropdownAnalysisPlotType  matlab.ui.control.DropDown
        h_buttonUpdateAnalysisPlot  matlab.ui.control.Button
        h_rgroupXScale
        h_rXScaleLinear
        h_rXScaleLog
        h_labelAxesType         matlab.ui.control.Label
        h_labelPlotType         matlab.ui.control.Label
        h_labelAnalysisType     matlab.ui.control.Label
        h_labelAnalysisPlotType matlab.ui.control.Label
        h_labelColormap         matlab.ui.control.Label
        h_dropdownColormap      matlab.ui.control.DropDown
        h_buttonExportWaveform  matlab.ui.control.Button
        h_buttonExportAnalysis  matlab.ui.control.Button
        h_menuFile
        h_menuFileLoadConfig
        h_menuFileSaveConfig
        h_menuFileSaveData
        h_menuExport
        h_menuExportToBase
        h_menuExportOpt
        h_menuExportOptSingle
        h_menuExportOptMulti
        h_menuExportOptVector
        h_menuOpts
        h_menuOptsTimer
        h_menuOptsPlotColors
        h_menuOptsShading
        h_menuOptsShadingFaceted
        h_menuOptsShadingFlat
        h_menuOptsShadingInterp
        
        
        guiState                char {mustBeMember(guiState,{'DisableData','Idle','Monitoring','NoData','Plotting'})} = 'NoData'
        
    end
    
    properties (Access = public, Transient)
        Data                waveform.Array
        monitorTimerPeriod  double {mustBePositive,mustBeFinite} = 0.5; % seconds
        plotColors          char = 'lines';
    end
    
    
    properties (SetAccess = private, GetAccess = public, Transient)
        TDT                 TDT
        config              %struct
        configFile          char
    end
    
    
    properties (Access = private)
        monitorTimer        timer
        validEventNames     cell
        
        figWaveformPlot     matlab.ui.Figure
        figAnalysisPlot     matlab.ui.Figure
        
        
    end 
    
    properties (Access = private, Constant)
        p_prefName          char = 'ControlPanel';
    end
    
    
    
    
    
    
    methods
        createGUI(obj);

        % Construct obj
        function obj = ControlPanel(configFile)
            
            obj.updateGuiState('NoData');
            
            f = findobj('tag','LFPControlPanel');
            if ~isempty(f)
                delete(obj);
                return
            end
            
            
            % Create and configure components
            obj.createGUI;
            
                
            % Set configuration
            if nargin == 1 && ~isempty(configFile)
                obj.configFile = configFile;
            else
                obj.configFile = 'defaultConfig.mat';
            end
            
            obj.TDT = TDT;
            
            rootDir = getpref(obj.p_prefName,'h_editTankRootDir',[]);
            if ~isempty(rootDir) && isfolder(rootDir)
                obj.populateTanks(rootDir);
            end
                        
            % setup TDT
            obj.TDT.connect;
            
        end
        
        function fh_mainFigure_Delete(obj,h,event)            
            obj.TDT.disconnect;
            T = timerfind('Name','LiveDataMonitor');
            if ~isempty(T)
                stop(T);
                delete(T);
            end
        end
        
        function set.configFile(obj,config)
            load(config,'config');
            fn = fieldnames(config);
            for i = 1:length(fn)
                switch fn{i}
                    case 'values'
                        vfn = fieldnames(config.values);
                        for j = 1:length(vfn)
                            if isprop(obj.(vfn{j}),'Value')
                                obj.(vfn{j}).Value = config.values.(vfn{j});
                                
                            elseif isprop(obj.(vfn{j}),'Checked')
                                obj.(vfn{j}).Checked = config.values.(vfn{j});

                            end
                        end
                        
                    otherwise
                        obj.updateConfig(fn{i},config.(fn{i}));
                end
            end
        end
        
        function updateConfig(obj,field,value)
            obj.config.(field) = value;
        end

        function names = get.validEventNames(obj)
            names = obj.TDT.epocNames(~ismember(obj.TDT.epocNames,obj.config.invalidEvents));
        end
        
        
       
        
        
        function f = get.figWaveformPlot(obj)
            f = findobj('type','figure','-and','-regexp','Name','^WaveformPlot*');
            if isempty(f)
                f = figure('Name','WaveformPlot-1','color','w','numbertitle','off');
            elseif numel(f) > 1
                idx = [f.Number];
                f(idx<max(idx)) = [];
            end
        end
        
        
        function f = get.figAnalysisPlot(obj)
            f = findobj('type','figure','-and','-regexp','Name','^AnalysisPlot*');
            if isempty(f)
                f = figure('Name','AnalysisPlot-1','color','w','numbertitle','off');
            elseif numel(f) > 1
                idx = [f.Number];
                f(idx<max(idx)) = [];
            end
        end
        
        
        
        
        
        
        
        
        
        
        

        function updateGuiState(obj,state)
            obj.guiState = state;
            
            hData = [obj.h_dropdownTanks,obj.h_dropdownBlocks, ...
                 obj.h_listChannels,obj.h_buttonSelectAllChannels,obj.h_buttonSelectOddEvenChannels, ...
                 obj.h_dropdownXVar,obj.h_dropdownYVar];
            
            hPlot = [obj.h_buttonUpdatePlot, ...
                obj.h_buttonUpdateAnalysisPlot,obj.h_dropdownAnalysisPlotType, ...
                obj.h_dropdownAnalysisType,obj.h_monitorData];
             
            switch obj.guiState
                case 'Idle'
                    set([hData, hPlot],'Enable','on');
                    obj.h_monitorData.BackgroundColor = [0.4 1 0.4];
                    obj.h_monitorData.Text = 'Live Data Monitor';
                    obj.h_monitorData.Tooltip = 'Click to begin monitoring data';
                    obj.h_monitorData.FontAngle = 'normal';
                    
                case 'NoData'
                    set([obj.h_dropdownTanks,obj.h_dropdownBlocks, ...
                        obj.h_listChannels, ...
                        obj.h_dropdownXVar,obj.h_dropdownYVar], ...
                        'ItemsData',{'< EMPTY >'}, ...
                        'Items',{'< EMPTY >'}, ...
                        'Value',{'< EMPTY >'});
                    set([hData, hPlot],'Enable','off');

                    
                case 'DisableData'
                    set([hData, hPlot],'Enable','off');
                    
                case 'Monitoring'
                    set([obj.h_dropdownTanks,obj.h_dropdownBlocks, ...
                        ],'Enable','off');
                    obj.h_monitorData.BackgroundColor = [1 0.4 0.4];
                    obj.h_monitorData.Text = 'Monitoring Data ...';
                    obj.h_monitorData.Tooltip = 'Click to stop monitoring data';
                    obj.h_monitorData.FontAngle = 'italic';
                    
                case 'Plotting'
%                     set([hPlot hData],'Enable','off');
                    
            end
            
%             fprintf('MODE: %s\n',obj.guiState)
            
            drawnow
        end
        
        
        
        
        
        function exportData(obj,h,event)
            
            obj.plotPrecurser; % make sure we're up to date
            
            E = waveform.Export(obj.Data);
            
            m = findobj(obj.h_mainFigure,'-regexp','tag','h_menuExportOpt*','-and','checked','on');
            E.exportMode = m.UserData;

            switch h.Tag
                case 'h_buttonExportWaveform'
                
                case 'h_buttonExportAnalysis'
                    E.writeWaveformAnalysis(obj.h_dropdownAnalysisType.Value);
            end
            
        end
        
        
        
        
        
        function f_exportOptions(obj,h,event)
            m = findobj(obj.h_mainFigure,'-regexp','tag','h_menuExportOpt*');
            set(m,'checked','off');
            h.Checked = 'on';
            setpref(obj.p_prefName,{m.Tag},get(m,'checked'));
        end
        
        
        
        
        % POPULATE GUI ====================================================
        function populateTanks(obj,rootDir)
            % Check some directory (rootDir) for TDT tanks
            %
            % islegacy can be returned as a logical vector the same size as tanks
            % indicating whether or not the tank is actually a legacy tank.
            if nargin < 2
                rootDir = obj.TDT.tankRootDir;
            end
            
            origRootDir = obj.TDT.tankRootDir;
            
            if isempty(rootDir)
                d = helpdlg(sprintf('No Valid Data Tanks Found in "%s"',rootDir),'tankRootDir');
                uiwait(d);
                obj.fh_locateTankRootDir_Pushed;
                obj.TDT.activeTank  = [];
                obj.TDT.activeBlock = [];
                obj.TDT.tankRootDir = origRootDir;
                return
            else
                obj.TDT.tankRootDir = rootDir;
                tanks = obj.TDT.tankList;
                
                if isempty(tanks)
                    d = helpdlg(sprintf('No Valid Data Tanks Found in "%s"',rootDir),'tankRootDir');
                    uiwait(d);
                    obj.fh_locateTankRootDir_Pushed;
                    obj.TDT.activeTank  = [];
                    obj.TDT.activeBlock = [];
                    obj.TDT.tankRootDir = origRootDir;
                    return
                end
            end
            
            obj.h_dropdownTanks.Items     = tanks;
            obj.h_dropdownTanks.ItemsData = tanks;
            obj.h_dropdownTanks.Value     = tanks{1};
            
            obj.fh_tankList_ValueChanged;
            
            
            r = obj.TDT.tankRootDir(max(1,length(obj.TDT.tankRootDir)-15):end);
            if length(r) < length(obj.TDT.tankRootDir)-3
                obj.h_editTankRootDir.Value = ['...' r];
            else
                obj.h_editTankRootDir.Value = obj.TDT.tankRootDir;
            end
            obj.h_editTankRootDir.Tooltip = obj.TDT.tankRootDir;
            
            
            obj.updateGuiState('Idle');
        end
        
        function populateBlocks(obj)            

            blocks = obj.TDT.blockList;
            
            if isempty(blocks)
                errmsg = sprintf('No blocks found in tank "%s"',obj.TDT.activeTank);
                % vprintf(2,errmsg);
                warndlg(errmsg,'ControlPanel','modal');
                return
            end
            obj.h_dropdownBlocks.Items     = blocks;
            obj.h_dropdownBlocks.ItemsData = blocks;
            obj.h_dropdownBlocks.Value     = blocks{1};
            obj.TDT.activeBlock            = blocks{1};

            obj.Data = waveform.Array; % reinitialize data
            
            
            set([obj.h_dropdownXVar, obj.h_dropdownYVar, obj.h_listChannels], ...
                'Enable','off');
            
            if obj.populateVariables && obj.populateChannels
                set([obj.h_dropdownXVar, obj.h_dropdownYVar, obj.h_listChannels], ...
                    'Enable','on');
            end
            
            updateVarInfo(obj);
            
            drawnow
        end
        
        function r = populateChannels(obj)
            r = 0;
            if isequal(obj.TDT.tankStatus,'Closed') || isempty(obj.TDT.channels)
                set(obj.h_listChannels, ...
                    'Items',{'< EMPTY >'}, ...
                    'ItemsData',{'< EMPTY >'}, ...
                    'Value',{'< EMPTY >'}, ...
                    'Enable','off');
                return
            end
            
            obj.h_listChannels.Items     = obj.TDT.channelsStr;
            obj.h_listChannels.ItemsData = obj.TDT.channels;
            obj.h_listChannels.Value     = obj.h_listChannels.ItemsData;
            
            r = 1;
        end
                
        function r = populateVariables(obj)
            r = 0;
            if isequal(obj.TDT.tankStatus,'Closed') || isempty(obj.TDT.epocNames)
                set([obj.h_dropdownXVar,obj.h_dropdownYVar], ...
                    'Items',{'< EMPTY >'}, ...
                    'ItemsData',{'< EMPTY >'}, ...
                    'Value',{'< EMPTY >'}, ...
                    'Enable','off');
                return
            end
            
            obj.copyEventsFromTDT;
            
            names = obj.validEventNames;
            namesExt = names;
            for i = 1:numel(names)
                s = mat2str(obj.Data.Events.(names{i}).distinct,9);
                if s(1)~='[', s = ['[' s ']']; end
                if length(s) > 15, s(15:end) = []; s(end+1:end+3) = '...'; end
                namesExt{i} = sprintf('%s %s',names{i},s);
            end
            
            set([obj.h_dropdownXVar,obj.h_dropdownYVar],'Enable','on');
            obj.h_dropdownXVar.Items     = [{'time'}; namesExt(:)];
            obj.h_dropdownXVar.ItemsData = [{'time'}; names(:)];
            obj.h_dropdownYVar.Items     = namesExt;
            obj.h_dropdownYVar.ItemsData = names;
            if ~any(strcmp(obj.h_dropdownXVar.Value,[{'time'}; names(:)]))
                obj.h_dropdownXVar.Value = 'time';
            end
            if ~any(strcmp(obj.h_dropdownYVar.Value,names))
                obj.h_dropdownYVar.Value = names{1};
            end
            
            
            r = 1;
            
        end
        
        function updateVarInfo(obj)
            xv = obj.h_dropdownXVar.Value;
            yv = obj.h_dropdownYVar.Value;
            
            % note that some of this functionality is vestigial.
            
            if isequal(xv,'time')
                xs = 'Determined by the "Window" field ...';
                obj.h_labelXVar.Text = 'X ';
            else
                xidx = obj.Data.Events.(xv).activeIdx;
                xs = mat2str(obj.Data.Events.(xv).distinct(xidx),7);
                if length(xidx) < obj.Data.Events.(xv).count
                    obj.h_labelXVar.Text = 'X*';
                    xs = ['*User selected: ' xs];
                else
                    obj.h_labelXVar.Text = 'X ';
                end
            end
            
            yidx = obj.Data.Events.(yv).activeIdx;
            ys = mat2str(obj.Data.Events.(yv).distinct(yidx),7);            
            if length(yidx) < obj.Data.Events.(yv).count
                obj.h_labelYVar.Text = 'Y*';
                ys = ['*User selected: ' ys];
            else
                obj.h_labelYVar.Text = 'Y ';
            end
            
            obj.h_labelXVar.Tooltip    = xs;
            obj.h_dropdownXVar.Tooltip = xs;
            obj.h_labelYVar.Tooltip    = ys;
            obj.h_dropdownYVar.Tooltip = ys;
                        
        end
        
        
        
        
        
        
        
        
        
        
        % GUI INTERACTION =================================================
        
        function f_menu_Clicked(obj,h,event)
            switch event.Source.Tag
                case 'h_menuFileLoadConfig'
                    [fn,pn] = uigetfile({'*.mat','Config (*.mat)'}, ...
                        'Locate Configuration file');
                    if isequal(pn,0), return; end
                    obj.configFile = fullfile(pn,fn); % loads the config
                    
                case 'h_menuFileSaveConfig'
                    [fn,pn] = uiputfile({'*.mat','Config (*.mat)'}, ...
                        'Save Configuration file');
                    if isequal(pn,0), return; end
                    
                    config = obj.config; %#ok<PROPLC>
                    config.values = getpref(obj.p_prefName);%#ok<PROPLC>
                    save(fullfile(pn,fn),'config');
                    
                case 'h_menuFileSaveData'
                    fn = sprintf('%s_%s_x%s_y%s.mat', ...
                        obj.TDT.activeTank,obj.TDT.activeBlock, ...
                        obj.Data.xVar,obj.Data.yVar);
                    [fn,pn] = uiputfile('*.mat','Save all channel data',fn);
                    if isequal(fn,0), return; end
                    pnfn = fullfile(pn,fn);
                    n = sprintf('lfpData_%s_%s',obj.TDT.activeTank, ...
                        obj.TDT.activeBlock);
                    n = matlab.lang.makeValidName(n);
                    fprintf('Saving data ...')
                    eval(sprintf('%s = obj.Data;',n));
                    save(pnfn,n);  
                    fprintf(' done\n -> <a href="matlab: load(''%s'')">%s</a> (%s)\n',pnfn,fn,pn)
                    
                case 'h_menuExportToBase'
                    n = sprintf('lfpData_%s_%s',obj.TDT.activeTank, ...
                        obj.TDT.activeBlock);
                    n = matlab.lang.makeValidName(n);
                    assignin('base',n,obj.Data);
                    evalin('base',sprintf('whos(''%s'')',n))
                    evalin('base',sprintf('disp(%s)',n))
                    
                case 'h_menuOptsTimer'
                    opts.Resize = 'off';
                    opts.WindowStyle = 'modal';
                    opts.Interpreter = 'none';
                    v = inputdlg('Enter timer period in seconds:','timer period', ...
                        1,{num2str(obj.monitorTimerPeriod)},opts);
                    if isempty(v), return; end
                    try
                        obj.monitorTimerPeriod = str2double(char(v));
                    catch me
                        errordlg('Invalid Entry: Value must be positive and finite')
                    end
                    
                case 'h_menuOptsPlotColors'
                    s = {'lines','parula','jet','hsv','hot','cool', ...
                        'spring','summer','autumn','winter','gray','bone','copper','pink','colorcube', ...
                        'prism','black'};
                    [sel,ok] = listdlg('ListString',s,'SelectionMode','single', ...
                        'InitialValue',find(ismember(s,obj.plotColors)), ...
                        'Name','Plot Colors','PromptString','Select color scheme:');
                    if ~ok, return; end
                    obj.plotColors = s{sel};
                    
                    
                case {'h_menuOptsShadingFaceted','h_menuOptsShadingFlat','h_menuOptsShadingInterp'}
                    set([obj.h_menuOptsShadingFaceted,obj.h_menuOptsShadingFlat,obj.h_menuOptsShadingInterp], ...
                        'checked','off');
                    obj.(event.Source.Tag).Checked = 'on';
                    obj.Data.analysisPlotOptions.shading = obj.(event.Source.Tag).Text;
            end
        end
        
        function f_selectAllChannels(obj,h,event)
            d = obj.h_listChannels.ItemsData;
            if contains(h.Text,'None')
                obj.h_listChannels.Value = [];
                h.Text = 'Select All';
            else
                obj.h_listChannels.Value = d;
                h.Text = 'Select None';
            end
        end
        
        function f_selectOddEvenChannels(obj,h,event)
            
            v = obj.h_listChannels.Value;
            d = obj.h_listChannels.ItemsData;
            if isempty(v)
                obj.h_listChannels.Value = d(1:2:end);
            elseif rem(v,2) == 1
                obj.h_listChannels.Value = d(2:2:end);
            else
                obj.h_listChannels.Value = d(1:2:end);
            end
            
        end
        
%         function f_updateVarVals(obj,h,event)
%             
%             h_var = obj.(h.UserData); % associated variable dropdown
% 
%             s = h_var.Value;
%             if isequal(s,'time')
%                 f = helpdlg('Use the "Window" field in the GUI to modify the time window.','Modify Variable');
%                 f.WindowStyle = 'modal';
%                 uiwait(f);
%                 return
%             end
%             
%             varIdx  = obj.Data.Events.(s).activeIdx;
%             varVals = obj.Data.Events.(s).distinct;
%             varValsStr = cellfun(@(a) num2str(a,'%0.3f'),num2cell(varVals),'uni',0);
%             
%             [idx,tf] = listdlg('liststring',varValsStr,'name',h_var.Value, ...
%                 'promptstring',sprintf('Select values for the variable "%s":',h_var.Value), ...
%                 'initialvalue',varIdx);
%             if ~tf, return; end
%             
%             obj.Data.Events.(s).activeIdx = idx;
%             
%             updateVarInfo(obj);
%         end
        
        % Edit field
        function fh_editTimeWin_ValueChanged(obj,h,event)
            w = str2num(event.Value); %#ok<ST2NM>
            if numel(w) == 1, w = sort([0 w]); end
            if isempty(w) || ~isnumeric(w) || numel(w) > 2 || all(w == w(1))
                me.identifier = 'ControlPanel:fh_editTimeWin_ValueChanged:InvalidEntry';
                me.message    = 'Invalid entry. Time window must have 2 numeric values, ex: [0 0.2]';
                me.stack      = dbstack;
%                 vprintf(2,1,me);
                h.Value = event.PreviousValue;
                warndlg(me.message,'Time Window','modal');
                return
            end
            if all(w(:) == h.UserData(:)), return; end
            h.UserData = w;
%             obj.updatePlot;
        end
        
        
        % Button pushed function: h_locateTankRootDir
        function fh_locateTankRootDir_Pushed(obj,h,event)
            tmpDir = getpref(obj.p_prefName,'h_editTankRootDir',pwd);
            
            if ~isfolder(tmpDir), tmpDir = pwd; end
            
            rootDir = uigetdir(tmpDir,'Locate tank directory');
            
            if isequal(rootDir,0), return; end
            
            obj.TDT.tankRootDir = rootDir;
            
            setpref(obj.p_prefName,'h_editTankRootDir',rootDir);
            
            obj.populateTanks(rootDir);
        end
        
        
        % channel changed
        function fh_channelChanged(obj,h,event)
            ind = ismember(obj.TDT.channels,obj.h_listChannels.Value);
            if ~any(ind) || isempty(obj.TDT.channels) || all(isnan(obj.TDT.channels))
                T = timerfind('Name','LiveDataMonitor');
                if ~isempty(T), stop(T); delete(T); end
            end
            obj.plotPrecurser;
        end
        
        % X or Y value changed
        function fh_variableChanged(obj,h,event)
            names = obj.validEventNames;
            if isequal(names{1},'< EMPTY >'), return; end
            updateVarInfo(obj);
            obj.plotPrecurser;
        end
        
        
        % Value changed function: h_dropdownTanks
        function fh_tankList_ValueChanged(obj,h,event)
            if isequal(obj.h_dropdownTanks.Value,'< EMPTY >'), return; end
            
            obj.Data = waveform.Array; % reinitialize
            
            obj.TDT.activeTank = obj.h_dropdownTanks.Value;
            obj.populateBlocks;
        end
        
        % Value changed function: h_dropdownBlocks
        function fh_blockList_ValueChanged(obj,h,event)
            if isequal(obj.h_dropdownTanks.Value,'< EMPTY >'), return; end
            
            obj.TDT.activeBlock = obj.h_dropdownBlocks.Value;
            
            obj.Data = waveform.Array; % reinitialize
            
            obj.populateChannels;
            
            obj.populateVariables;
            
            obj.plotPrecurser;
        end
        
        
        function keyHandler(obj,h,event)

            switch lower(event.Key)
                case 'p'
                    obj.updatePlot;
            end
            
        end
        
        function locatePlots(obj,h,event)
            f = findobj('type','figure', ...
                '-and','-regexp','name','^WaveformPlot*', ...
                '-or', '-regexp','name','^AnalysisPlot*', ...
                '-or', '-regexp','name',sprintf('^%s*',obj.TDT.activeTank));
            
            for i = 1:length(f)
                figure(f(i));
            end
        end
        
        
        
        % PLOTTING ========================================================
        function updateWaveformArray(obj)
            
            x = obj.h_dropdownXVar.Value;
            if isequal(x,'time'), x = ''; end
            obj.Data.xVar = x;
            obj.Data.yVar = obj.h_dropdownYVar.Value;
                        
            obj.Data.channelsActive = obj.h_listChannels.Value;
            
            obj.Data.timeWindow = obj.h_editTimeWin.UserData;
            
            % update Waveform info
            s = sprintf([ ...
                'Timestamp:   "%s"\n', ...
                'Directory:   "%s"\n', ...
                'Tank Name:   "%s"\n', ...
                'Block Name:  "%s"\n', ...
                'Block Start: "%s"\n', ...
                'Block Stop:  "%s"\n', ...
                'Channels:    "%s"\n', ...
                'X Variable:  "%s"\n', ...
                'Y Variable:  "%s"'], ...
                datestr(now), ...
                obj.TDT.tankRootDir, ...
                obj.TDT.activeTank, ...
                obj.TDT.activeBlock, ...
                obj.TDT.blockStartTime, ...
                obj.TDT.blockStopTime, ...
                mat2str(obj.Data.channels), ...
                obj.Data.xVar,obj.Data.yVar);
            
            obj.Data.info = s;
            
        end
        
        
        
        function updateWaveforms(obj,C)
            % Collect data from data tank or append new data if some data
            % has already been loaded
            if nargin < 2 || isempty(C), C = obj.Data.channels; end
            
            cidx = obj.Data.getIdxByChannel(C);
%             tic
            for w = 1:numel(C)
                ons = 0;
                if ~isnan(cidx(w))
                    oW = obj.Data.Waveform(cidx(w));
                    ons = oW.latestTimestamp; % only grab new data if available
                end
                
                [samples,Fs] = obj.TDT.getWaveformData(C(w),[ons 0]);
                
                if all(isnan(samples)), continue; end
                
                if ~isnan(samples(1)) && ons >  0 % append new data
                    obj.Data.Waveform(cidx(w)).samples = [obj.Data.Waveform(cidx(w)).samples; samples];
                else
                    obj.Data.Waveform(end+1) = waveform.Waveform(samples,Fs,C(w));
                end
            end
%             toc


        end
        
        function copyEventsFromTDT(obj)
            % copy TDT epocData to Waveform Events
            f = obj.validEventNames;
            t = struct('garbage',[]);
            for i = 1:length(f)
                a = obj.TDT.epocData.(f{i});
                t.(f{i}) = waveform.Event(f{i},a.values,a.onsets,a.offsets);
            end
            t = rmfield(t,'garbage');
            obj.Data.Events = t;
        end
        
        function plotPrecurser(obj,channels,isAnalysis)
            if nargin < 2 || isempty(channels), channels = obj.h_listChannels.Value; end
            if nargin < 3 || isempty(isAnalysis), isAnalysis = false; end
            
            obj.updateWaveforms(channels);
            obj.copyEventsFromTDT;
            obj.updateWaveformArray;
            obj.updatePlotOptions(isAnalysis);
        end
        
        function updatePlotOptions(obj,isAnalysis)
            
            PO.grid             = obj.h_dropdownGrid.Value;
            PO.maxTraces        = obj.h_numeditMaxTraces.Value;
            PO.ampScale         = obj.h_numeditAmpScale.Value;
            PO.axesType         = obj.h_dropdownAxesType.Value;
            PO.timeWindow       = str2num(obj.h_editTimeWin.Value); %#ok<ST2NM>
            PO.plotType         = obj.h_dropdownAnalysisPlotType.Value;
            PO.analysisType     = obj.h_dropdownAnalysisType.Value;
            PO.channelColormap  = obj.h_dropdownColormap.Value;
            PO.normalizeAmp     = obj.h_checkboxNormalize.Value;
            
            if obj.h_rXScaleLinear.Value
                PO.xScale = 'linear';
            else
                PO.xScale = 'log';
            end
            
            % kludge
            opts = {'grid','maxTraces','ampScale','axesType','timeWindow', ...
                'plotType','analysisType','channelColormap','normalizeAmp', ...
                'xScale'};
            
            for w = 1:obj.Data.numChannels
                if isempty(obj.Data.Waveform(w).plotOptions), obj.Data.Waveform(w).plotOptions = waveform.Plot; end
                if isempty(obj.Data.Waveform(w).analysisPlotOptions), obj.Data.Waveform(w).analysisPlotOptions = waveform.Plot; end
            end
            
            for i = 1:length(opts)
                if isAnalysis
                    obj.Data.analysisPlotOptions.(opts{i}) = PO.(opts{i});
                else
                    obj.Data.plotOptions.(opts{i}) = PO.(opts{i});
                end
                for w = 1:obj.Data.numChannels
                    
                    if isAnalysis
                        obj.Data.Waveform(w).analysisPlotOptions.(opts{i}) = PO.(opts{i});
                    else
                        obj.Data.Waveform(w).plotOptions.(opts{i}) = PO.(opts{i});
                    end
                end
            end
                
            h = findobj(obj.h_mainFigure,'-property','Value');
            for i = 1:numel(h)
                if isempty(h(i).Tag), continue; end
                P.(h(i).Tag) = h(i).Value;
            end
            
            f = fieldnames(P);
            v = struct2cell(P);
            setpref(obj.p_prefName,f,v);

        end
        
        function updatePlot(obj,h,event)

            obj.updateGuiState('Plotting');

            k = Helpers.getKeysPressed;
            
            if ismember(k,{'LeftShift','RightShift'})
                x = findobj('-regexp','name','^WaveformPlot*','-and','type','figure');
                if isempty(x)
                    f = obj.figWaveformPlot;
                else
                    idx = cellfun(@(a) str2double(a(find(a=='-',1,'last')+1:end)),{x.Name});
                    if isempty(idx), idx = 1; else, idx = min(setdiff(1:max(idx)+1,idx)); end
                    n = sprintf('WaveformPlot-%d',idx);
                    f = figure('Name',n,'color','w','numbertitle','off');
                end
            else
                f = obj.figWaveformPlot;
                clf(f);
            end
            
            obj.plotPrecurser;


            obj.Data.plotOptions.container = f;
            obj.Data.plotOptions.xScale = 'linear'; % must be the case for traces plot
            obj.Data.plotOptions.channelColormap = obj.plotColors;
            
            obj.Data = plot(obj.Data,f,true);

            figure(f);

            obj.updateGuiState('Idle');
            
            drawnow
            
        end
        
        
        
        function updateAnalysisPlot(obj,~,~)
            obj.updateGuiState('Plotting');

            
            k = Helpers.getKeysPressed;
            
            if ismember(k,{'LeftShift','RightShift'})
                x = findobj('-regexp','name','^AnalysisPlot*','-and','type','figure');
                if isempty(x)
                    f = obj.figAnalysisPlot;
                else
                    idx = cellfun(@(a) str2double(a(find(a=='-',1,'last')+1:end)),{x.Name});
                    if isempty(idx), idx = 1; else, idx = min(setdiff(1:max(idx)+1,idx)); end
                    n = sprintf('AnalysisPlot-%d',idx);
                    f = figure('Name',n,'color','w','numbertitle','off');
                end
            else
                f = obj.figAnalysisPlot;
                clf(f);
            end

            obj.plotPrecurser(obj.Data.channelsActive,true);

            obj.Data.analysisPlotOptions.container = f;
            
            obj.Data = obj.Data.plotAnalysis;
            
            obj.updateGuiState('Idle');
            
            figure(f);
            
            drawnow
        end
        
        
        
        
        
        
        
        % MONITORING ======================================================
        
        % Button pushed function: h_monitorData
        function fh_monitorData_StateChanged(obj,h,event)
            
            obj.h_monitorData.Enable = 'off'; drawnow
            
            if obj.h_monitorData.Value % turn monitor on
                % create/start timer

                try
                    obj.monitorTimer = obj.createTimer;
                    start(obj.monitorTimer);
                                        
                catch me
                    obj.updateGuiState('Idle');
                    rethrow(me)
                end
                
               
                
            else % turn monitor off
                % stop/destroy timer
                stop(obj.monitorTimer);
                delete(obj.monitorTimer);
                
            end
            
            obj.h_monitorData.Enable = 'on'; drawnow
        end
      
        
        
        function T = createTimer(obj)
            % use timerfind just in case shit hit the fan and there's still
            % a timer that was never destroyed.
            T = timerfind('Name','LiveDataMonitor');
            if ~isempty(T)
                stop(T);
                delete(T);
            end
            
            T = timer( ...
                'Name','LiveDataMonitor', ...
                'BusyMode','drop', ...
                'ExecutionMode','fixedSpacing', ...
                'Period',  obj.monitorTimerPeriod, ...
                'StartFcn',@obj.monitorTimerStart, ...
                'TimerFcn',@obj.monitorTimerFcn, ...
                'ErrorFcn',@obj.monitorTimerError, ...
                'StopFcn', @obj.monitorTimerStop, ...
                'TasksToExecute',inf);
        end
        
        function monitorTimerStart(obj,h,event)
            
            blk = obj.TDT.blockHot;
            
            if ~isempty(blk)
                obj.TDT.activeBlock = blk;
                obj.h_listBlocks.Value = blk;
            end
            
            obj.updatePlot;
            
            obj.updateGuiState('Monitoring');
        end
        
        function monitorTimerFcn(obj,h,event)
            obj.monitorPlot;
        end
        
        function monitorTimerError(obj,h,event)
            obj.h_monitorData.Value = 0;
%             rethrow(event.Data);
        end
        
        function monitorTimerStop(obj,h,event)
            obj.h_monitorData.Value = 0;
            obj.updateGuiState('Idle');
        end
        
        function monitorPlot(obj)
            persistent updateIdx
%             tic
            
            Wf = findobj('-regexp','name','^WaveformPlot*','-and','type','figure');
            Af = findobj('-regexp','name','^AnalysisPlot*','-and','type','figure');
            
            if isempty(Wf) && isempty(Af)
                stop(obj.monitorTimer);
                return
            end
            
            if isempty(updateIdx) || updateIdx > obj.Data.numChannels
                updateIdx = 1; 
            end
            
            
            if isempty(obj.Data.Waveform(updateIdx)), return; end
            
%             fprintf('Updating channel %d\n',obj.Data.Waveform(updateIdx).channel)
            
            if ~isempty(Wf)
                obj.plotPrecurser(obj.Data.Waveform(updateIdx).channel);
                
                [~,idx] = max([Wf.Number]); Wf = Wf(idx);
                obj.Data.Waveform(updateIdx).plotOptions.container = Wf;
                obj.Data.Waveform(updateIdx).plotOptions.xScale = 'linear';
                obj.Data.Waveform(updateIdx).plotOptions.channelColormap = obj.plotColors;

                obj.Data.Waveform(updateIdx).plotOptions.plotH = plot( ...
                    obj.Data.Waveform(updateIdx), ...
                    obj.Data.Waveform(updateIdx).plotOptions.ax, ...
                    obj.Data.Waveform(updateIdx).plotOptions.plotH);
                
                waveform.Array.plotPostProcessing(obj.Data,obj.Data.plotOptions.ax);
            end
            
            if ~isempty(Af)
                obj.plotPrecurser(obj.Data.Waveform(updateIdx).channel,true);
                [~,idx] = max([Af.Number]); Af = Af(idx);
                obj.Data.Waveform(updateIdx).analysisPlotOptions.container = Af;
                obj.Data = obj.Data.plotAnalysis(obj.Data.Waveform(updateIdx).channel,false);
            end
            
            drawnow
            
            updateIdx = updateIdx + 1;
            
%             toc
        end
        
    end
    
    
    
    
    
end





