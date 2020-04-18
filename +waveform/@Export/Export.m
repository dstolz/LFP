classdef Export < handle
    
    properties (Access = public)
        data                    
        
        fullFileName    char = '';
        
        filePath        char = '';
        fileName        char = '';
        
        fieldSeparator  char = ',';
        
        exportMode      char {mustBeMember(exportMode,{'single','multi','vector'})} = 'single';
    end
    
    
    
    properties (Access = private)
        fid 
        pnfn 
        statusBox
    end
    
    methods
                
        function obj = Export(data)
            c = class(data);
            c(1:find(c=='.')) = [];
            if ~ismember(c,{'Waveform','Array','Analysis'})
                error(Helpers.getME(mfilename('class'),'InvalidClass','Invalid class: %s',c));
            end
            
            obj.data = data;
        end
        
        function set.filePath(obj,path)
            obj.filePath = path;
        end
        
        function path = get.filePath(obj)
            if isempty(obj.filePath), obj.filePath = pwd; end
            path = obj.filePath;
        end
        
        function fileName = get.fileName(obj)
            if isempty(obj.fileName)
                    
                    switch class(obj.data)
                        case 'waveform.Waveform'
                            info = Helpers.getInfoStr(obj.data.info);
                            fileName = sprintf('Waveform_%s_%s_Channel-%s.xls', ...
                                info.TankName,info.BlockName,info.Channels);
                            
                            
                        case {'waveform.Array','waveform.Analysis'}
                            info = Helpers.getInfoStr(obj.data.info);
                            fileName = sprintf('WaveformAnalysis_%s_%s-%s.xls', ...
                                info.TankName,info.BlockName, ...
                                obj.data.plotOptions.analysisType);
%                             fileName = sprintf('WaveformAnalysis_%s_%s_Channels-%s.xls', ...
%                                 info.TankName,info.BlockName,info.Channels);
                    end

            else
                fileName = obj.fileName;
            end
        end
        
        function set.fileName(obj,fileName)
            obj.fileName = fileName;
        end
        
        
        function fullFileName = get.fullFileName(obj)
            fullFileName = fullfile(obj.filePath,obj.fileName);
        end
        
        function set.fullFileName(obj,fullFileName)
            obj.fullFileName = fullFileName;
        end
        
        function set.fieldSeparator(obj,sep)
            assert(length(sep)==1,Helpers.getME(mfilename('class'), ...
                'InvalidInput','Invalid field separator: "%s"',sep));
            obj.fieldSeparator = sep;
        end
        
        function pnfn = getFilenameGUI(obj)
            
            [fn,pn] = uiputfile( ...
                {'*.mat','MAT-file (*.mat)'; ...
                 '*.xls','Comma-Separated Values (*.xls)'; ...
                 '*.xls','Excel File (*.xls)'; ...
                 '*.json','JSON File (*.json)'}, ...
                 'Save as...',fullfile(obj.filePath,obj.fileName));
            
            if isequal(fn,0)
                pnfn = [];
                return
            end
            
            pnfn = fullfile(pn,fn);
            
            obj.filePath = pn;
            obj.fileName = fn;
        end
        
        
        function updateStatusBox(obj,status,icon)
            if nargin < 3 || isempty(icon), icon = 'help'; end
            if isempty(obj.statusBox)
                obj.statusBox = msgbox(status,'Export',icon,'modal');
            else
%                 obj.statusBox
            end
            
            
        end
        
        function writeWaveform(obj)
            
            obj.fid = obj.openFile;
            if obj.fid == -1, return; end
                        
            
            fs = obj.fieldSeparator;

            W = obj.data;
            
            obj.writeHeader(W);
            obj.writeVarInfo(W);
            
            M = W.getMeanWaveform;
            
            M  = M(~cellfun(@isempty,M));
            N = numel(M);
            tvec = W.trialTimeVector;
            %fprintf(obj.fid,'Time (s)\n');
            for i = 1:length(tvec)
                fprintf(obj.fid,'\n%.9f%c',tvec(i),fs); % time point
                for j = 1:N
                    fprintf(obj.fid,'%.9f%c',M{j}(i),fs);
                end
            end
            fprintf(obj.fid,'\n');
            
            obj.closeFile;
        end
        
        function writeWaveformArray(obj)
            
        end
        
        function writeWaveformAnalysis(obj,analysisType)
            
            warning('off','MATLAB:xlswrite:AddSheet');
                        
            fn = obj.fullFileName;
            
            delete(fn);
            
            switch obj.exportMode
                case 'single'
                    
                    if isempty(obj.data.Waveform(1).xVals)
                        fprintf('Writing data ...')
                        xlswrite(fn,{[obj.data.Waveform(1).yVar '\Channel']},1,'B2');
                        xlswrite(fn,obj.data.channels,1,'C2');
                        xlswrite(fn,obj.data.Waveform(1).yVals',1,'B3');
                        xlswrite(fn,[obj.data.Waveform.(analysisType)],1,'C3');
                        fprintf(' done\n')
                        
                    else
                        
                        a = 1;
                        for i = 1:obj.data.numChannels
                            W = obj.data.Waveform(i);
                            
                            fprintf('Writing Channel %d (%d of %d)\n',W.channel,i,obj.data.numChannels)
                            
                            xlswrite(fn,{'Channel',W.channel},1,sprintf('B%d',a));
                            xlswrite(fn,{[W.xVar '\' W.yVar]},1,sprintf('B%d',a+1));
                            xlswrite(fn,W.yVals,1,sprintf('C%d',a+1));
                            xlswrite(fn,W.xVals',1,sprintf('B%d',a+2));
                            xlswrite(fn,W.(analysisType),1,sprintf('C%d',a+2));
                            
                            a = a+4+size(W.(analysisType),1);
                        end
                    end
                    
                case 'multi'
                    
                    for i = 1:obj.data.numChannels
                        W = obj.data.Waveform(i);
                        
                        fprintf('Writing Channel %d (%d of %d)\n',W.channel,i,obj.data.numChannels)

                        cstr = sprintf('Ch_%d',W.channel);
                        
                        xlswrite(fn,{'Channel',W.channel},cstr,sprintf('B%d',1));
                        xlswrite(fn,{[W.xVar '\' W.yVar]},cstr,sprintf('B%d',2));
                        if isempty(W.xVals)
                            xlswrite(fn,W.yVals,cstr,sprintf('C%d',3));
                            xlswrite(fn,W.(analysisType)',cstr,sprintf('C%d',4));
                        else
                            xlswrite(fn,W.yVals,cstr,sprintf('C%d',2));
                            xlswrite(fn,W.xVals',cstr,sprintf('B%d',3));
                            xlswrite(fn,W.(analysisType),cstr,sprintf('C%d',3));
                        end
                    end
                    
                case 'vector'
                    fprintf(2,'Vectorized exporting not yet implmented\n')
%                     c = char(65:90); % A -> Z
%                     for i = 1:obj.data.numChannels
%                         W = obj.data.Waveform(i);
%                         
%                         fprintf('Writing Channel %d (%d of %d)\n',W.channel,i,obj.data.numChannels)
% 
%                         xlswrite(fn,W.(analysisType)(:),1,sprintf('%c%d',c(i),
%                     end
            end
            
            warning('on','MATLAB:xlswrite:AddSheet');
%             obj.fid = obj.openFile;
%             if obj.fid == -1, return; end
%             
%             fs = obj.fieldSeparator;
%             
%             D = obj.data;
%             
%             obj.writeHeader(D);
%             obj.writeVarInfo(D.Waveform);
% 
%             Z = D.(analysisType);
%             
%             for i = 1:size(Z,2)
%                 for j = 1:size(Z,1)
%                     fprintf(obj.fid,'%.9f%c',Z(j,i),fs);
%                 end
%                 fprintf(obj.fid,'\n');
%             end
%             
%             obj.closeFile;
        end
    end
    
    methods (Access = private)
        
        
        function writeHeader(obj,W)
            obj.updateStatusBox(sprintf('Writing Waveform data: "%s.%s"',obj.fileName));

            info = Helpers.getInfoStr(W.info);
            fs = obj.fieldSeparator;
            fn = fieldnames(info);
            for i = 1:length(fn)
                if isnumeric(info.(fn{i}))
                    info.(fn{i}) = mat2str(info.(fn{i}));
                end
                fprintf(obj.fid,'%s%c%s\n',fn{i},fs,info.(fn{i}));
            end
        end
        
        function writeVarInfo(obj,W)
            
            nt = W.numTrials;
            ns = W.numTrialSamples;
            
            fs = obj.fieldSeparator;
            
            N = numel(W.varStruct);
            
            % X
            if isempty(W.xVar)
                fprintf(obj.fid,'\n');
            else
                fprintf(obj.fid,'\n%s:%c',W.xVar,fs);
                for i = 1:N
                    if ns(i) == 0, continue; end
                    fprintf(obj.fid,'%g%c',W.varStruct(i).(W.xVar),fs);
                end
            end
            
            % Y
            fprintf(obj.fid,'\n%s:%c',W.yVar,fs);
            for i = 1:N
                if ns(i) == 0, continue; end
                fprintf(obj.fid,'%g%c',W.varStruct(i).(W.yVar),fs);
            end
            
            % count
            fprintf(obj.fid,'\nCount:%c',fs);
            for i = 1:N
                if ns(i) == 0, continue; end
                fprintf(obj.fid,'%d%c',nt(i),fs);
            end
            
            
            fprintf(obj.fid,'\n');
                
        end
        
        function fid = openFile(obj)
            if ~isempty(obj.fid) && obj.fid > 2, obj.closeFile; end
            [fid,msg] = fopen(obj.fullFileName,'w');
            if fid == -1
                obj.updateStatusBox('There was an error opening "%s" for writing!','error');
            end
        end
        
        function e = closeFile(obj)
            fclose(obj.fid);
            obj.fid = [];
        end
    end
    
end