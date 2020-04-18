% Create h_mainFigure and components
function createGUI(obj)

% default field values
dflt.h_editTankRootDir  = pwd;
dflt.h_editTimeWin      = '[0 0.1]';
dflt.h_numeditAmpScale  = 1;
dflt.h_numeditMaxTraces = 0;
dflt.h_dropdownGrid     = 'major';
dflt.h_dropdownAxesType = 'tiled';
dflt.h_dropdownColormap = 'jet';
dflt.h_dropdownAnalysisType = 'Fsp';
dflt.h_dropdownAnalysisPlotType = 'imagesc';
dflt.h_checkboxNormalize = 0;
dflt.h_menuExportOptVector = 'on';
dflt.h_menuExportOptMulti  = 'off';
dflt.h_menuExportOptSingle = 'off';
dflt.h_menuOptsShadingFaceted = 'off';
dflt.h_menuOptsShadingFlat    = 'off';
dflt.h_menuOptsShadingInterp  = 'on';
f = fieldnames(dflt);
v = getpref(obj.p_prefName,f,struct2cell(dflt));

for i = 1:length(f), P.(f{i}) = v{i}; end






% Create h_mainFigure
obj.h_mainFigure = uifigure;
obj.h_mainFigure.Position = [100 100 600 500];
obj.h_mainFigure.Name = 'LFP Control Panel';
obj.h_mainFigure.Tag = 'LFPControlPanel';
obj.h_mainFigure.DeleteFcn = @obj.fh_mainFigure_Delete;
obj.h_mainFigure.WindowKeyPressFcn   = @obj.keyHandler;
obj.h_mainFigure.WindowKeyReleaseFcn = @obj.keyHandler;
obj.h_mainFigure.Color = [1 1 1];


%% MENU ====================================================================
% file menu --------------------------------------------------------------
obj.h_menuFile = uimenu(obj.h_mainFigure);
obj.h_menuFile.Text = 'File';
obj.h_menuFile.Accelerator = 'f';

obj.h_menuFileLoadConfig = uimenu(obj.h_menuFile);
obj.h_menuFileLoadConfig.Tag = 'h_menuFileLoadConfig';
obj.h_menuFileLoadConfig.Text = 'Load Configuration File';
obj.h_menuFileLoadConfig.Accelerator = 'l';
obj.h_menuFileLoadConfig.MenuSelectedFcn  = @obj.f_menu_Clicked;

obj.h_menuFileSaveConfig = uimenu(obj.h_menuFile);
obj.h_menuFileSaveConfig.Tag = 'h_menuFileSaveConfig';
obj.h_menuFileSaveConfig.Text = 'Save Configuration File';
obj.h_menuFileSaveConfig.Accelerator = 's';
obj.h_menuFileSaveConfig.MenuSelectedFcn  = @obj.f_menu_Clicked;


obj.h_menuFileSaveData = uimenu(obj.h_menuFile);
obj.h_menuFileSaveData.Tag = 'h_menuFileSaveData';
obj.h_menuFileSaveData.Text = 'Save Data';
obj.h_menuFileSaveData.Accelerator = 'd';
obj.h_menuFileSaveData.MenuSelectedFcn  = @obj.f_menu_Clicked;
obj.h_menuFileSaveData.Separator = 'on';


obj.h_menuExport = uimenu(obj.h_mainFigure);
obj.h_menuExport.Text = 'Export';

obj.h_menuExportToBase = uimenu(obj.h_menuExport);
obj.h_menuExportToBase.Tag = 'h_menuExportToBase';
obj.h_menuExportToBase.Text = 'Export Data to Workspace';
obj.h_menuExportToBase.Accelerator = 'e';
obj.h_menuExportToBase.MenuSelectedFcn = @obj.f_menu_Clicked;

obj.h_menuExportOpt = uimenu(obj.h_menuExport);
obj.h_menuExportOpt.Text = 'Export Options';

obj.h_menuExportOptSingle = uimenu(obj.h_menuExportOpt);
obj.h_menuExportOptSingle.Tag = 'h_menuExportOptSingle';
obj.h_menuExportOptSingle.Text = 'All Channels on One Sheet';
obj.h_menuExportOptSingle.MenuSelectedFcn = @obj.f_exportOptions;
obj.h_menuExportOptSingle.Checked = P.h_menuExportOptSingle;
obj.h_menuExportOptSingle.UserData = 'single';
obj.h_menuExportOptSingle.Separator = 'on';

obj.h_menuExportOptMulti = uimenu(obj.h_menuExportOpt);
obj.h_menuExportOptMulti.Tag = 'h_menuExportOptMulti';
obj.h_menuExportOptMulti.Text = 'One Channel Per Sheet';
obj.h_menuExportOptMulti.MenuSelectedFcn = @obj.f_exportOptions;
obj.h_menuExportOptMulti.UserData = 'multi';
obj.h_menuExportOptMulti.Checked = P.h_menuExportOptMulti;

obj.h_menuExportOptVector = uimenu(obj.h_menuExportOpt);
obj.h_menuExportOptVector.Tag = 'h_menuExportOptVector';
obj.h_menuExportOptVector.Text = 'Vectorize Exported Data';
obj.h_menuExportOptVector.MenuSelectedFcn = @obj.f_exportOptions;
obj.h_menuExportOptVector.UserData = 'vector';
obj.h_menuExportOptVector.Checked = P.h_menuExportOptVector;



obj.h_menuOpts = uimenu(obj.h_mainFigure);
obj.h_menuOpts.Text = 'Options';

obj.h_menuOptsTimer = uimenu(obj.h_menuOpts);
obj.h_menuOptsTimer.Tag = 'h_menuOptsTimer';
obj.h_menuOptsTimer.Text = 'Data Monitor Timer Period';
obj.h_menuOptsTimer.MenuSelectedFcn = @obj.f_menu_Clicked;

obj.h_menuOptsPlotColors = uimenu(obj.h_menuOpts);
obj.h_menuOptsPlotColors.Tag = 'h_menuOptsPlotColors';
obj.h_menuOptsPlotColors.Text = 'Waveform Plot Colors';
obj.h_menuOptsPlotColors.MenuSelectedFcn = @obj.f_menu_Clicked;

obj.h_menuOptsShading = uimenu(obj.h_menuOpts);
obj.h_menuOptsShading.Text = 'Shading';

obj.h_menuOptsShadingFaceted = uimenu(obj.h_menuOptsShading);
obj.h_menuOptsShadingFaceted.Tag = 'h_menuOptsShadingFaceted';
obj.h_menuOptsShadingFaceted.Text = 'faceted';
obj.h_menuOptsShadingFaceted.MenuSelectedFcn = @obj.f_menu_Clicked;
obj.h_menuOptsShadingFaceted.Checked = 'off';

obj.h_menuOptsShadingFlat = uimenu(obj.h_menuOptsShading);
obj.h_menuOptsShadingFlat.Tag = 'h_menuOptsShadingFlat';
obj.h_menuOptsShadingFlat.Text = 'flat';
obj.h_menuOptsShadingFlat.MenuSelectedFcn = @obj.f_menu_Clicked;
obj.h_menuOptsShadingFlat.Checked = 'off';

obj.h_menuOptsShadingInterp = uimenu(obj.h_menuOptsShading);
obj.h_menuOptsShadingInterp.Tag = 'h_menuOptsShadingInterp';
obj.h_menuOptsShadingInterp.Text = 'interp';
obj.h_menuOptsShadingInterp.MenuSelectedFcn = @obj.f_menu_Clicked;
obj.h_menuOptsShadingInterp.Checked = 'on';




%% GRID LAYOUT ============================================================
gMain = uigridlayout(obj.h_mainFigure,[2 3]);
gMain.RowHeight        = {'1x','1x','1x'};
gMain.ColumnWidth      = {'1x','1x','1x'};
gMain.Padding          = [10 10 10 10]; % [L B R T]


rowCount = 14;
rowSpace = 22;

% Create h_leftPanel
obj.h_leftPanel = uipanel(gMain);
obj.h_leftPanel.Title = 'Select';
obj.h_leftPanel.BackgroundColor = [0.95 0.9 0.9];
obj.h_leftPanel.Scrollable    = 'off';
obj.h_leftPanel.Layout.Row    = [1 3];
obj.h_leftPanel.Layout.Column = 1;

% Create h_middlePanel
obj.h_middlePanel = uipanel(gMain);
obj.h_middlePanel.Title = 'Plot';
obj.h_middlePanel.BackgroundColor = [0.95 1 0.7];
obj.h_middlePanel.Scrollable    = 'off';
obj.h_middlePanel.Layout.Row    = [1 2];
obj.h_middlePanel.Layout.Column = 2;

% Create h_middleBottomPanel
obj.h_middleBottomPanel = uipanel(gMain);
obj.h_middleBottomPanel.Title = '';
obj.h_middleBottomPanel.BackgroundColor = [0.7 0.9 1];
obj.h_middleBottomPanel.Scrollable    = 'off';
obj.h_middleBottomPanel.Layout.Row    = 3;
obj.h_middleBottomPanel.Layout.Column = 2;

% Create h_rightTopPanel
obj.h_rightTopPanel = uipanel(gMain);
obj.h_rightTopPanel.Title = 'Analysis';
obj.h_rightTopPanel.BackgroundColor = [0.9 0.9 0.95];
obj.h_rightTopPanel.Scrollable    = 'off';
obj.h_rightTopPanel.Layout.Row    = [1 2];
obj.h_rightTopPanel.Layout.Column = 3;

% Create h_rightBottomPanel
obj.h_rightBottomPanel = uipanel(gMain);
obj.h_rightBottomPanel.Title = 'Export';
obj.h_rightBottomPanel.BackgroundColor = [1 0.9 0.7];
obj.h_rightBottomPanel.Scrollable    = 'off';
obj.h_rightBottomPanel.Layout.Row    = 3;
obj.h_rightBottomPanel.Layout.Column = 3;

% panels
gPanelData = uigridlayout(obj.h_leftPanel);
gPanelData.ColumnWidth = {'1x','2x','1x','1x'};
gPanelData.RowHeight   = num2cell(rowSpace*ones(rowCount,1));
gPanelData.Padding     = [5 10 5 10];

gPanelPlot = uigridlayout(obj.h_middlePanel);
gPanelPlot.ColumnWidth = {'1x','1x','1x','1x'};
gPanelPlot.RowHeight   = num2cell(rowSpace*ones(rowCount,1));
gPanelPlot.Padding     = [5 10 5 10];

gPanelMonitor = uigridlayout(obj.h_middleBottomPanel);
gPanelMonitor.ColumnWidth = {'1x'};
gPanelMonitor.RowHeight   = {'1x','1x'};
gPanelMonitor.Padding     = [5 10 5 10];

gPanelAnalysis = uigridlayout(obj.h_rightTopPanel);
gPanelAnalysis.ColumnWidth = {'1x','1x','1x'};
gPanelAnalysis.RowHeight   = num2cell(rowSpace*ones(rowCount,1));
gPanelAnalysis.Padding     = [5 10 5 10];

gPanelExport = uigridlayout(obj.h_rightBottomPanel);
gPanelExport.ColumnWidth = {'1x'};
gPanelExport.RowHeight   = {'1x','1x','1x'};
gPanelExport.Padding     = [5 10 5 10];


h = findobj(obj.h_mainFigure,'type','uipanel');
set(h,'FontSize',14,'FontWeight','bold','TitlePosition','centertop');











%% DATA PANEL =============================================================

R = 1; 
Rmax = length(gPanelData.RowHeight);
Cmax = length(gPanelData.ColumnWidth);

% Create h_editTankRootDir
obj.h_editTankRootDir = uieditfield(gPanelData, 'text');
obj.h_editTankRootDir.Editable = 'off';
obj.h_editTankRootDir.HorizontalAlignment = 'right';
obj.h_editTankRootDir.Value = P.h_editTankRootDir;
obj.h_editTankRootDir.Layout.Row    = R;
obj.h_editTankRootDir.Layout.Column = [1 Cmax-1];

% Create h_locateTankRootDir
obj.h_locateTankRootDir = uibutton(gPanelData, 'push');
obj.h_locateTankRootDir.ButtonPushedFcn = @obj.fh_locateTankRootDir_Pushed;
obj.h_locateTankRootDir.Text = '...';
obj.h_locateTankRootDir.Tooltip = 'Select new root directory...';
obj.h_locateTankRootDir.Layout.Row    = R;  R = R + 1;
obj.h_locateTankRootDir.Layout.Column = Cmax;

% Create h_labelTanks
obj.h_labelTanks = uilabel(gPanelData);
obj.h_labelTanks.Text = 'Tank';
obj.h_labelTanks.HorizontalAlignment = 'right';
obj.h_labelTanks.Layout.Row    = R;
obj.h_labelTanks.Layout.Column = 1;

% Create h_dropdownTanks
obj.h_dropdownTanks = uidropdown(gPanelData);
obj.h_dropdownTanks.Items = {'< EMPTY >'};
obj.h_dropdownTanks.Value = '< EMPTY >';
obj.h_dropdownTanks.ValueChangedFcn = @obj.fh_tankList_ValueChanged;
obj.h_dropdownTanks.Layout.Row    = R;    R = R + 1;
obj.h_dropdownTanks.Layout.Column = [2 Cmax];


% Create h_labelBlocks
obj.h_labelBlocks = uilabel(gPanelData);
obj.h_labelBlocks.Text = 'Block';
obj.h_labelBlocks.HorizontalAlignment = 'right';
obj.h_labelBlocks.Layout.Row    = R;
obj.h_labelBlocks.Layout.Column = 1;

% Create h_dropdownBlocks
obj.h_dropdownBlocks = uidropdown(gPanelData);
obj.h_dropdownBlocks.Items = {'< EMPTY >'};
obj.h_dropdownBlocks.Value = '< EMPTY >';
obj.h_dropdownBlocks.ValueChangedFcn = @obj.fh_blockList_ValueChanged;
obj.h_dropdownBlocks.Layout.Row     = R;  R = R + 1;
obj.h_dropdownBlocks.Layout.Column  = [2 Cmax];


% Create h_labelXVar
obj.h_labelXVar = uilabel(gPanelData);
obj.h_labelXVar.HorizontalAlignment = 'right';
obj.h_labelXVar.Text = 'X ';
obj.h_labelXVar.Layout.Row      = R;
obj.h_labelXVar.Layout.Column   = 1;

% Create h_dropdownXVar
obj.h_dropdownXVar = uidropdown(gPanelData);
obj.h_dropdownXVar.Items = {'< EMPTY >'};
obj.h_dropdownXVar.Value = '< EMPTY >';
obj.h_dropdownXVar.ValueChangedFcn = @obj.fh_variableChanged;
obj.h_dropdownXVar.Layout.Row    = R;       
obj.h_dropdownXVar.Layout.Column = [2 Cmax];

% % Create h_buttonXVar
% obj.h_buttonXVar = uibutton(gPanelData);
% obj.h_buttonXVar.Tag = 'h_buttonXVar';
% obj.h_buttonXVar.UserData = 'h_dropdownXVar'; % buddy
% obj.h_buttonXVar.ButtonPushedFcn = @obj.f_updateVarVals;
% obj.h_buttonXVar.Text = '...';
% obj.h_buttonXVar.Tooltip = 'Modify X Variable';
% obj.h_buttonXVar.Layout.Row = R;
% obj.h_buttonXVar.Layout.Column = Cmax;

R = R + 1;

% Create h_labelYVar
obj.h_labelYVar = uilabel(gPanelData);
obj.h_labelYVar.HorizontalAlignment = 'right';
% obj.h_labelYVar.FontWeight = 'bold';
obj.h_labelYVar.Text = 'Y ';
obj.h_labelYVar.Layout.Row       = R;
obj.h_labelYVar.Layout.Column    = 1;

% Create h_dropdownYVar
obj.h_dropdownYVar = uidropdown(gPanelData);
obj.h_dropdownYVar.Items = {'< EMPTY >'};
obj.h_dropdownYVar.Value = '< EMPTY >';
obj.h_dropdownYVar.ValueChangedFcn = @obj.fh_variableChanged;
obj.h_dropdownYVar.Layout.Row    = R;       
obj.h_dropdownYVar.Layout.Column = [2 Cmax];

% % Create h_buttonYVar
% obj.h_buttonYVar = uibutton(gPanelData);
% obj.h_buttonYVar.Tag = 'h_buttonYVar';
% obj.h_buttonYVar.UserData = 'h_dropdownYVar'; % buddy
% obj.h_buttonYVar.ButtonPushedFcn = @obj.f_updateVarVals;
% obj.h_buttonYVar.Text = '...';
% obj.h_buttonYVar.Tooltip = 'Modify Y Variable';
% obj.h_buttonYVar.Layout.Row = R;
% obj.h_buttonYVar.Layout.Column = Cmax;

R = R + 1;

% Create h_buttonSelectAllChannels
obj.h_buttonSelectAllChannels = uibutton(gPanelData);
obj.h_buttonSelectAllChannels.Tag = 'h_buttonSelectAllChannels';
obj.h_buttonSelectAllChannels.ButtonPushedFcn = @obj.f_selectAllChannels;
obj.h_buttonSelectAllChannels.Text = 'Select All';
obj.h_buttonSelectAllChannels.Tooltip = 'Toggle selection of all channels';
obj.h_buttonSelectAllChannels.Layout.Row = R;
obj.h_buttonSelectAllChannels.Layout.Column = [1 2];


% Create h_buttonSelectOddEvenChannels
obj.h_buttonSelectOddEvenChannels = uibutton(gPanelData);
obj.h_buttonSelectOddEvenChannels.Tag = 'h_buttonSelectOddEvenChannels';
obj.h_buttonSelectOddEvenChannels.ButtonPushedFcn = @obj.f_selectOddEvenChannels;
obj.h_buttonSelectOddEvenChannels.Text = 'Odd/Even';
obj.h_buttonSelectOddEvenChannels.Tooltip = 'Toggle selection of odd or even channels';
obj.h_buttonSelectOddEvenChannels.Layout.Row = R;
obj.h_buttonSelectOddEvenChannels.Layout.Column = [3 4];

R = R + 1;

% Create h_listChannels
obj.h_listChannels = uilistbox(gPanelData);
obj.h_listChannels.Items = {'< EMPTY >'};
obj.h_listChannels.Value = '< EMPTY >';
obj.h_listChannels.Multiselect = 'on';
obj.h_listChannels.ValueChangedFcn = @obj.fh_channelChanged;
obj.h_listChannels.Layout.Row = [R Rmax]; 
obj.h_listChannels.Layout.Column = [1 Cmax];
















%% PLOT PANEL =============================================================
 
Cmax = length(gPanelPlot.ColumnWidth);
Rmax = length(gPanelPlot.RowHeight);

R = 1;

% Create h_labelTimeWin
obj.h_labelTimeWin = uilabel(gPanelPlot);
obj.h_labelTimeWin.Text = 'Window';
obj.h_labelTimeWin.HorizontalAlignment = 'right';
obj.h_labelTimeWin.Layout.Row    = R;         
obj.h_labelTimeWin.Layout.Column = [1 2];

% Create h_editTimeWin
obj.h_editTimeWin = uieditfield(gPanelPlot,'text');
obj.h_editTimeWin.Tag = 'h_editTimeWin';
obj.h_editTimeWin.ValueChangedFcn = @obj.fh_editTimeWin_ValueChanged;
obj.h_editTimeWin.Value = P.h_editTimeWin;
obj.h_editTimeWin.UserData = str2num(P.h_editTimeWin); %#ok<ST2NM>
obj.h_editTimeWin.HorizontalAlignment = 'center';
obj.h_editTimeWin.Tooltip = 'Enter stimulus-locked time window in seconds. ex: [-0.05 0.1]';
obj.h_editTimeWin.Layout.Row     = R;
obj.h_editTimeWin.Layout.Column  = [3 4];

R = R + 1;

% Create h_checkboxNormalize
obj.h_checkboxNormalize = uicheckbox(gPanelPlot);
obj.h_checkboxNormalize.Tag = 'h_checkboxNormalize';
obj.h_checkboxNormalize.Text = 'Normalize Channels';
obj.h_checkboxNormalize.Value = P.h_checkboxNormalize;
obj.h_checkboxNormalize.Tooltip = 'Normalize amplitude of traces across channels';
obj.h_checkboxNormalize.Layout.Row = R;
obj.h_checkboxNormalize.Layout.Column = [2 4];

R = R + 1;


% Create h_labelAmpScale
obj.h_labelAmpScale = uilabel(gPanelPlot);
obj.h_labelAmpScale.Text = 'Amp Scale';
obj.h_labelAmpScale.HorizontalAlignment = 'right';
obj.h_labelAmpScale.Layout.Row    = R;         
obj.h_labelAmpScale.Layout.Column = [1 2];


% Create h_numeditAmpScale
obj.h_numeditAmpScale = uieditfield(gPanelPlot,'numeric');
obj.h_numeditAmpScale.Tag = 'h_numeditAmpScale';
% obj.h_numeditMaxTraces.ValueChangedFcn = @obj.updatePlot;
obj.h_numeditAmpScale.Limits = [0 100];
obj.h_numeditAmpScale.LowerLimitInclusive = 'off';
obj.h_numeditAmpScale.ValueDisplayFormat = '%.2f';
obj.h_numeditAmpScale.Value = P.h_numeditAmpScale;
obj.h_numeditAmpScale.HorizontalAlignment = 'center';
obj.h_numeditAmpScale.Tooltip = 'Main plot amplitude scaling factor';
obj.h_numeditAmpScale.Layout.Row = R;
obj.h_numeditAmpScale.Layout.Column = 3;

R = R + 1;
 
% Create h_labelMaxTraces
obj.h_labelMaxTraces = uilabel(gPanelPlot);
obj.h_labelMaxTraces.Text = 'Max # Traces';
obj.h_labelMaxTraces.HorizontalAlignment = 'right';
obj.h_labelMaxTraces.Layout.Row    = R;         
obj.h_labelMaxTraces.Layout.Column = [1 2];

% Create h_numeditMaxTraces
obj.h_numeditMaxTraces = uieditfield(gPanelPlot,'numeric');
obj.h_numeditMaxTraces.Tag = 'h_numeditMaxTraces';
% obj.h_numeditMaxTraces.ValueChangedFcn = @obj.updatePlot;
obj.h_numeditMaxTraces.Limits = [0 inf];
obj.h_numeditMaxTraces.ValueDisplayFormat = '%d';
obj.h_numeditMaxTraces.Value = P.h_numeditMaxTraces;
obj.h_numeditMaxTraces.HorizontalAlignment = 'center';
obj.h_numeditMaxTraces.Tooltip = 'Toggle display of individual stimulus-locked waveforms';
obj.h_numeditMaxTraces.Layout.Row = R;  
obj.h_numeditMaxTraces.Layout.Column = 3;

R = R + 1;


% Create h_labelGrid
obj.h_labelGrid = uilabel(gPanelPlot);
obj.h_labelGrid.Text = 'Grid';
obj.h_labelGrid.HorizontalAlignment = 'right';
obj.h_labelGrid.Layout.Row    = R;         
obj.h_labelGrid.Layout.Column = [1 2];

% Create h_dropdownGrid
obj.h_dropdownGrid = uidropdown(gPanelPlot);
obj.h_dropdownGrid.Tag = 'h_dropdownGrid';
% obj.h_dropdownGrid.ValueChangedFcn = @obj.updatePlot;
obj.h_dropdownGrid.Items = {'major','minor','all','off'};
obj.h_dropdownGrid.Value = P.h_dropdownGrid;
obj.h_dropdownGrid.Tooltip = 'Toggle display of grid on main plot';
obj.h_dropdownGrid.Layout.Row = R; 
obj.h_dropdownGrid.Layout.Column = [3 4];

R = R + 1;



% Create h_labelAxesType
obj.h_labelAxesType = uilabel(gPanelPlot);
obj.h_labelAxesType.Text = 'Axes';
obj.h_labelAxesType.HorizontalAlignment = 'right';
obj.h_labelAxesType.Layout.Row    = R;         
obj.h_labelAxesType.Layout.Column = [1 2];

% Create h_dropdownAxesType
obj.h_dropdownAxesType = uidropdown(gPanelPlot);
obj.h_dropdownAxesType.Tag = 'h_dropdownAxesType';
obj.h_dropdownAxesType.Tooltip = 'Control Axes Display';
obj.h_dropdownAxesType.Items = {'tiled','overlay'};
obj.h_dropdownAxesType.Value = P.h_dropdownAxesType;
% obj.h_dropdownAxesType.ValueChangedFcn = @obj.updatePlotOptions;
obj.h_dropdownAxesType.Layout.Row        = R;      
obj.h_dropdownAxesType.Layout.Column     = [3 4];

 R = R + 1;
 

% % Create h_labelPlotType
% obj.h_labelPlotType = uilabel(gPanelPlot);
% obj.h_labelPlotType.Text = 'Plot';
% obj.h_labelPlotType.HorizontalAlignment = 'right';
% obj.h_labelPlotType.Layout.Row    = R;         
% obj.h_labelPlotType.Layout.Column = [1 2];
% 
% % Create h_dropdownPlotType
% obj.h_dropdownPlotType = uidropdown(gPanelPlot);
% obj.h_dropdownPlotType.Tag = 'h_dropdownPlotType';
% obj.h_dropdownPlotType.Tooltip = 'Plot Type';
% obj.h_dropdownPlotType.Items = {'Traces','Density'};
% obj.h_dropdownPlotType.Value = 'Traces';
% obj.h_dropdownPlotType.ValueChangedFcn = @obj.updatePlotOptions;
% obj.h_dropdownPlotType.Layout.Row        = R;     
% obj.h_dropdownPlotType.Layout.Column     = [3 4];
% 
R = R + 1;

% Create h_buttonUpdatePlot
obj.h_buttonUpdatePlot = uibutton(gPanelPlot);
obj.h_buttonUpdatePlot.Text = 'Update Plot';
obj.h_buttonUpdatePlot.Tooltip = 'Click to update the main plot. Hold "shift" to plot into a new figure.';
obj.h_buttonUpdatePlot.Enable = 'off';
obj.h_buttonUpdatePlot.ButtonPushedFcn = @obj.updatePlot;
obj.h_buttonUpdatePlot.BusyAction    = 'cancel';
obj.h_buttonUpdatePlot.Layout.Row    = [R R+1];     
obj.h_buttonUpdatePlot.Layout.Column = [1 Cmax];




% MONITOR PANEL ===========================================================

R = 1;

% Create h_monitorData
obj.h_monitorData = uibutton(gPanelMonitor,'state');
obj.h_monitorData.Text  = 'Live Data Monitor';
obj.h_monitorData.Value = false;
obj.h_monitorData.Enable = 'on'; % enable when an active tank is selected
obj.h_monitorData.ValueChangedFcn = @obj.fh_monitorData_StateChanged;
obj.h_monitorData.Layout.Row     = [R R+1];
obj.h_monitorData.Layout.Column  = [1 Cmax];

R = R + 2;

% Create h_buttonLocatePlots
obj.h_buttonLocatePlots = uibutton(gPanelMonitor);
obj.h_buttonLocatePlots.Text = 'Locate Plots';
obj.h_buttonLocatePlots.Tooltip = 'Bring any plots to the foreground.';
obj.h_buttonLocatePlots.Enable = 'on';
obj.h_buttonLocatePlots.ButtonPushedFcn = @obj.locatePlots;
obj.h_buttonLocatePlots.BusyAction    = 'cancel';
obj.h_buttonLocatePlots.Layout.Row    = R;     
obj.h_buttonLocatePlots.Layout.Column = [1 Cmax];

% R = R + 1;







%% ANALYSIS PANEL =========================================================

Cmax = length(gPanelAnalysis.ColumnWidth);
Rmax = length(gPanelAnalysis.RowHeight);

R = 1; 

% Create h_labelAnalysisType
obj.h_labelAnalysisType = uilabel(gPanelAnalysis);
obj.h_labelAnalysisType.Text = 'Type';
obj.h_labelAnalysisType.HorizontalAlignment = 'right';
obj.h_labelAnalysisType.Layout.Row    = R;         
obj.h_labelAnalysisType.Layout.Column = 1;


% Create h_dropdownAnalysisType
obj.h_dropdownAnalysisType = uidropdown(gPanelAnalysis);
obj.h_dropdownAnalysisType.Tag = 'h_dropdownAnalysisType';
obj.h_dropdownAnalysisType.Tooltip = 'Analysis Type';
obj.h_dropdownAnalysisType.Items = {'RMS of Mean Waveform', ...
    'Mean RMS of traces','R - Correlation Coefficient','Fsp statistic', ...
    'Maximum Amplitude','Minimum Amplitude','Maximum Absolute Amplitude'};
obj.h_dropdownAnalysisType.ItemsData = {'RMSofMean','RMSofTraces','Rcorr', ...
    'Fsp','MaxAmp','MinAmp','MaxAbsAmp'};
obj.h_dropdownAnalysisType.Value = P.h_dropdownAnalysisType;
% obj.h_dropdownAnalysisType.ValueChangedFcn = @obj.updatePlotOptions;
obj.h_dropdownAnalysisType.Layout.Row      = R;      
obj.h_dropdownAnalysisType.Layout.Column   = [2 Cmax];

R = R + 1;


% Create h_labelAnalysisPlotType
obj.h_labelAnalysisPlotType = uilabel(gPanelAnalysis);
obj.h_labelAnalysisPlotType.Text = 'Plot';
obj.h_labelAnalysisPlotType.HorizontalAlignment = 'right';
obj.h_labelAnalysisPlotType.Layout.Row    = R;         
obj.h_labelAnalysisPlotType.Layout.Column = 1;

% Create h_dropdownAnalysisPlotType
obj.h_dropdownAnalysisPlotType = uidropdown(gPanelAnalysis);
obj.h_dropdownAnalysisPlotType.Tag = 'h_dropdownAnalysisPlotType';
obj.h_dropdownAnalysisPlotType.Tooltip = 'Analysis Plot Type';
obj.h_dropdownAnalysisPlotType.Items = {'plot3','lines','contour','contourf','surf', ...
    'surfc','mesh','meshc','meshz','waterfall','imagesc'};
obj.h_dropdownAnalysisPlotType.Value = P.h_dropdownAnalysisPlotType;
% obj.h_dropdownAnalysisPlotType.ValueChangedFcn = @obj.updatePlotOptions;
obj.h_dropdownAnalysisPlotType.Layout.Row      = R;      
obj.h_dropdownAnalysisPlotType.Layout.Column   = [2 Cmax];

R = R + 1;


% Create h_labelColormap
obj.h_labelColormap = uilabel(gPanelAnalysis);
obj.h_labelColormap.Text = 'Colormap';
obj.h_labelColormap.HorizontalAlignment = 'right';
obj.h_labelColormap.Layout.Row    = R;         
obj.h_labelColormap.Layout.Column = 1;


% Create h_dropdownColormap
obj.h_dropdownColormap = uidropdown(gPanelAnalysis);
obj.h_dropdownColormap.Tag = 'h_dropdownColormap';
% obj.h_dropdownColormap.ValueChangedFcn = @obj.updatePlot;
obj.h_dropdownColormap.Items = {'lines','parula','jet','hsv','hot','cool', ...
    'spring','summer','autumn','winter','gray','bone','copper','pink','colorcube', ...
    'prism','black'};
obj.h_dropdownColormap.Value = P.h_dropdownColormap;
obj.h_dropdownColormap.Tooltip = 'Choose a colormap';
obj.h_dropdownColormap.Layout.Row = R; 
obj.h_dropdownColormap.Layout.Column = [2 Cmax];

R = R + 1;

% Create h_rgroupXScale
obj.h_rgroupXScale = uibuttongroup(gPanelAnalysis);
obj.h_rgroupXScale.Title = 'X Scaling';
obj.h_rgroupXScale.Tooltip = 'Controls the scaling of x-axes';
obj.h_rgroupXScale.Layout.Row    = [R R+1];         
obj.h_rgroupXScale.Layout.Column = [1 Cmax];
obj.h_rgroupXScale.BackgroundColor = obj.h_rightTopPanel.BackgroundColor;

% Create h_rXScaleLinear
obj.h_rXScaleLinear = uiradiobutton(obj.h_rgroupXScale);
obj.h_rXScaleLinear.Tag = 'h_rXScaleLinear';
obj.h_rXScaleLinear.Text = 'linear';
obj.h_rXScaleLinear.Position = [20 5 50 22];

% Create h_rXScaleLog
obj.h_rXScaleLog = uiradiobutton(obj.h_rgroupXScale);
obj.h_rXScaleLog.Tag = 'h_rXScaleLog';
obj.h_rXScaleLog.Text = 'log';
obj.h_rXScaleLog.Position = [100 5 50 22];

R = R + 3;

% Create h_buttonUpdateAnalysisPlot
obj.h_buttonUpdateAnalysisPlot = uibutton(gPanelAnalysis);
obj.h_buttonUpdateAnalysisPlot.Text = 'Update Analysis Plot';
obj.h_buttonUpdateAnalysisPlot.Tooltip = 'Click to update the analysis plot';
obj.h_buttonUpdateAnalysisPlot.Enable  = 'off';
obj.h_buttonUpdateAnalysisPlot.ButtonPushedFcn = @obj.updateAnalysisPlot;
obj.h_buttonUpdateAnalysisPlot.Layout.Row    = [R R+1];     
obj.h_buttonUpdateAnalysisPlot.Layout.Column = [1 Cmax];

R = R + 2;





%% EXPORT =================================================================

R = 1;

% Create h_buttonExportWaveform
obj.h_buttonExportWaveform = uibutton(gPanelExport);
obj.h_buttonExportWaveform.Tag = 'h_buttonExportWaveform';
obj.h_buttonExportWaveform.Text = 'Waveforms';
obj.h_buttonExportWaveform.ButtonPushedFcn = @obj.exportData;
obj.h_buttonExportWaveform.Layout.Row = R;
obj.h_buttonExportWaveform.Layout.Column = 1;

R = R + 1;

% Create h_buttonExportAnalysis
obj.h_buttonExportAnalysis = uibutton(gPanelExport);
obj.h_buttonExportAnalysis.Tag = 'h_buttonExportAnalysis';
obj.h_buttonExportAnalysis.Text = 'Analysis';
obj.h_buttonExportAnalysis.ButtonPushedFcn = @obj.exportData;
obj.h_buttonExportAnalysis.Layout.Row = R;
obj.h_buttonExportAnalysis.Layout.Column = 1;


R = R + 1;



