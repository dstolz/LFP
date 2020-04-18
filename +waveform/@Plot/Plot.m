classdef Plot
    
    properties
        ax              matlab.graphics.axis.Axes % handle (obj) of current axes
        
        % options
        ampScale        {mustBeFinite,mustBeNonempty,mustBePositive} = 1; % amplitude scaling
        maxTraces       {mustBeNumeric} = 0; % maximum number of individual waves to plot for a given condition
        grid            {mustBeMember(grid,{'major','minor','all','off'})} = 'major';
        xScale          {mustBeMember(xScale,{'linear','log'})} = 'linear';
        timeWindow      {mustBeFinite,mustBeNumeric} = [0 0.1];
        axesType        {mustBeMember(axesType,{'overlay','tiled'})} = 'overlay';
        channelColormap
        lineColor       {mustBeNonnegative,mustBeLessThanOrEqual(lineColor,1)}
        channelSpacing  {mustBeNonnegative,mustBeLessThanOrEqual(channelSpacing,0.5)} = 0.025;
        container % panel or figure
        containerBorder {mustBeNonnegative,mustBeLessThanOrEqual(containerBorder,0.75)} = 0.1;
        normalizeAmp    matlab.lang.OnOffSwitchState = 0; 
        dispAmpTimeCal  matlab.lang.OnOffSwitchState = 0;
        shading         {mustBeMember(shading,{'flat','faceted','interp'})} = 'faceted';
        
        analysisType    char
        plotType        char
        
        plotH           
    end
    
    properties (SetAccess = private, GetAccess = public, Dependent)
        plotFig       % handle to axes parent figure
        
    end
    
    methods (Static)
        ax = setupPlotAx(obj,ax);
        applyPlotOptions(obj,ax);
        h = popoutPlot(ax,h,event);
        
        h = plotTraces(obj,ax,varargin);
        h = plotDensity(obj,ax,varargin);
        h = plotContinuous(obj,ax,varargin);
        h = plotAnalysis(obj,ax,atype,ptype);
    end
    
    methods
        
        function obj = Plot(ax)
            if nargin == 1,obj.ax = ax; end
        end
        
        function plotFig = get.plotFig(obj)
            plotFig = ancestor(obj.ax,'figure');
        end
         
        
        function obj = set.timeWindow(obj,timeWindow)
            if numel(timeWindow) ~= 2
                error(Helpers.getME(mfilename('class'),'IncorrectNumValues','timeWindow must have two values'));
            end
            obj.timeWindow = timeWindow(:)';
        end
        
        
        function obj = set.container(obj,container)
            if isa(container,'Axes')
                container = container.Parent;
            end
            container.AutoResizeChildren = false;
            obj.container = container;
        end
        
        function obj = set.lineColor(obj,color)
            if numel(color) ~= 3
                error(Helpers.getME(mfilename('class'),'InvalidColor','lineColor must be a 1x3 vector'));
            end
            obj.lineColor = color(:)';
        end
        
        function color = getChannelLineColor(obj,channel)
            if isempty(obj.channelColormap), obj.channelColormap = 'colorcube'; end
            if ischar(obj.channelColormap)
                cm = feval(obj.channelColormap);
            elseif ismatrix(obj.channelColormap)
                cm = obj.channelColormap;
            end
            color = cm(channel,:);
        end
        
        function color = get.lineColor(obj)
            if isempty(obj.lineColor)
                color = [0 0 0];
            else
                color = obj.lineColor;
            end
        end
        
        function map = get.channelColormap(obj)
            if isempty(obj.channelColormap)
                obj.channelColormap = colorcube;
            end
            
            if ischar(obj.channelColormap)
                switch obj.channelColormap
                    case 'black'
                        map = zeros(512,3);
                    otherwise
                        map = feval(obj.channelColormap);
                end
            elseif ismatrix(obj.channelColormap)
                map = obj.channelColormap;
            end
        end
        
        function obj = set.channelColormap(obj,map)
            obj.channelColormap = map;
        end
        
        function ax = get.ax(obj)
            if isempty(obj.plotH)
                ax = obj.ax;
            else
                f = fieldnames(obj.plotH);
                ax = ancestor(obj.plotH.(f{1}),'axes');
            end
        end
        
        
    end
    
    
    
    
    
    
    
    
    
    
    
    methods (Static)
        
        function ax = designTiled(container,n,spacing,border)
            % ax = designTiled(fig,n,[spacing],[border])
            % 
            % Returns a MxN matrix of axis handles to fit n plots in a
            % rectangular grid.
            %
            % container is the nadle to the figure or panel in which to
            % create the grid of axes.
            % 
            % n specifies the number of axes to create.  n can also be
            % specified as an m x n matrix to explicitly generate the rows
            % and columns of the design.
            %
            % The optional input parameters, spacing and border, control the
            % normalized distance between the axes and the edge of the
            % contaier, respectively.
            
            if nargin < 3 || isempty(spacing), spacing = 0.025; end
            if nargin < 4 || isempty(border),  border = 0.13;   end
            
            if isscalar(n)
                nrows = ceil(sqrt(n));
                ncols = ceil(n/nrows);
            else
                [nrows,ncols] = size(n);
            end
            
            c = linspace(border,1-border,ncols+1);
            r = linspace(border,1-border,nrows+1);
            
            if ncols == 1, dc = 1-border*2; else, dc = c(2)-c(1)-spacing; end
            if nrows == 1, dr = 1-border*2; else, dr = r(2)-r(1)-spacing; end
            
            delete(container.Children);
            
            for i = 1:ncols*nrows
                [y,x] = ind2sub([nrows, ncols],i);
                if y > length(r)-1 || x > length(c)-1, continue; end
                ax(y,x) = axes(container,'position',[c(x) r(y) dc dr]);
                ax(y,x).XAxis.TickValues = [];
                ax(y,x).YAxis.TickValues = [];
            end
        end
        
        function h = placeAxText(ax,string,location)
            % h = placeAxText(ax,string,{location])
            %
            % Places text, string at a specified location within the axes, ax.
            %
            % Location must be a char string containing vertical and/or
            % horizontal location, for example: 'top-left', or 'bottom'
            % 
            % default location = 'bottom-right'
            
            if nargin < 3, location = 'bottom-right'; end
            
            location = lower(location);
            
            if contains(location,'top')
                y = 0.9;
            elseif contains(location,'bot')
                y = 0.1;
            else
                y = 0.5;
            end
            
            if contains(location,'l')
                x = 0.1;
            elseif contains(location,'r')
                x = 0.9;
            else
                x = 0.5;
            end
            
            h = text(ax,x,y,string,'units','normalized','margin',0.1, ...
                'backgroundcolor',[1 1 1 0.75]);
            
        end
        
        
        
    end
    
    
    
    
    
    
    
end
    