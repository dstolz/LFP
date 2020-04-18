classdef Analysis % < waveform.Waveform
    
    properties
        analysisPlotOptions waveform.Plot
    end
    
    properties (SetAccess = private, GetAccess = public)
        Fsp           double % F statistic = var(signal) / var(single point)
        % "Fsp involves calculation of a variance ratio (hence the F) the
        % numerator of which is essentially the sample variance of the
        % average and the denominator of which is the variance of the set
        % of data values at a fixed single point (hence the “SP”) in the
        % time window across a group of sweeps."
        
        RMSofMean     double % RMS power of the mean of traces
        RMSofTraces   double % Mean RMS power of traces
        Rcorr         double % Correlation coefficient
       
        
        MaxAmp        double
        MinAmp        double
        MaxAbsAmp     double
        
        
        meanWaveform  double
    end
    
    properties (SetAccess = private, GetAccess = public, Transient)
        organizedData   cell
    end
    
    methods
        h = plot(obj,ax,analysisType,plotType);
                
        function obj = Analysis(samples,Fs,channel)
            if nargin >= 1, obj.samples = samples(:);  end
            if nargin >= 2, obj.Fs      = Fs;          end
            if nargin == 3, obj.channel = channel;     end
        end
        
        function rms = get.RMSofMean(obj)
            c = cellfun(@waveform.Analysis.computeRMS,obj.meanWaveform,'uni',0);
            rms = nan(size(c));
            for i = 1:numel(c)
                if isempty(c{i}), continue; end
                rms(i) = mean(c{i});
            end
        end
        
        function rms = get.RMSofTraces(obj)
            c = cellfun(@waveform.Analysis.computeRMS,obj.organizedData,'uni',0);
            rms = nan(size(c));
            for i = 1:numel(c)
                if isempty(c{i}), continue; end
                rms(i) = mean(c{i});
            end
        end
        
        function Rcorr = get.Rcorr(obj)
            od = obj.organizedData;
            Rcorr = cellfun(@(a) tril(corrcoef(a),-1),od,'uni',0);
            ind = cellfun(@(a) tril(true(size(a)),-1),Rcorr,'uni',0);
            Rcorr = cellfun(@(a,b) mean(a(b)),Rcorr,ind);
        end
        
        function Fsp = get.Fsp(obj)
            VarS  = cellfun(@var,obj.meanWaveform);
            
            od = obj.organizedData;
            od(cellfun(@isempty,od)) = {nan};
            VarSP = cellfun(@(a) var(a(1,:)),od);
            Fsp = VarS./VarSP;
        end
        
        
        function m = get.MaxAmp(obj)
            w = obj.getMeanWaveform;
            w(cellfun(@isempty,w)) = {nan};
            m = cellfun(@max,w);
        end
        
        function m = get.MinAmp(obj)
            w = obj.getMeanWaveform;
            w(cellfun(@isempty,w)) = {nan};
            m = cellfun(@min,w);
        end
        
        function m = get.MaxAbsAmp(obj)
            w = obj.getMeanWaveform;
            w(cellfun(@isempty,w)) = {nan};
            m = cellfun(@(a) max(abs(a)),w);
        end
        
        
        function data = get.organizedData(obj)
            data = obj.getEpochDataByValue(obj.varStruct);
            if size(data,1) == 1, data = data'; end
        end
        
        function M = get.meanWaveform(obj)
            M = cellfun(@transpose,obj.organizedData,'uni',0);
            if size(M,1) == 1, M = M'; end
            M = cellfun(@mean,M,'uni',0);
        end
        
        
    end
    
    methods (Static)
        function v = computeRMS(y,dim)
            if isempty(y), v = []; return; end
            if nargin < 2 || isempty(dim), dim = find(size(y,1)); end
            v = sqrt(mean(y.^2,dim));
        end
        

    end
    
end