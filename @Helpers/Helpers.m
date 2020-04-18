classdef Helpers < handle
    
    methods
        
        function obj = Helpers
            % no construction
        end
        
        
    end
    
    methods (Static)
        
        function k = getKeysPressed
            % adapted from: https://www.mathworks.com/matlabcentral/answers/347593-command-to-read-all-current-pressed-keyboard-keys
            NET.addAssembly('PresentationCore');
            akey = System.Windows.Input.Key.A;  %use any key to get the enum type
            keys = System.Enum.GetValues(akey.GetType);  %get all members of enumeration
            keynames = cell(System.Enum.GetNames(akey.GetType))';
            iskeyvalid = true(keys.Length, 1);
            iskeydown = false(keys.Length, 1);
            for keyidx = 1:keys.Length
                try
                    iskeydown(keyidx) = System.Windows.Input.Keyboard.IsKeyDown(keys(keyidx));
                catch
                    iskeyvalid(keyidx) = false;
                end
            end
            k = keynames(iskeydown);
            
        end
        
        
        
        function s = genDisp(obj,fields)
            nc = max(cellfun(@length,fields))+4;
            
            s = '';
            for f = fields
                c = obj.(char(f));
                if isnumeric(c) || islogical(c)
                    v = mat2str(c,8);
                    
                elseif iscell(c)
                    v = '{';    
                    for i = 1:numel(c)
                        v = [v '''' c{i} ''','];
                    end
                    if length(v) == 1, v = '{[]}'; end
                    v(end) = '}';
                    
                elseif ischar(c)
                    v = ['''' c ''''];
                    
                else
                    v = c;
                end
                
                if length(v) > 40, v = [v(1:find(v(1:40)==' ',1,'last')) ' ...']; end

                s = sprintf('%s%+*s:  %s\n',s,nc,char(f),v);
            end

        end
        
        function chksum = gitChksum(path)
            
            narginchk(1,1);
            
            chksum = nan;
            
            fid = fopen(fullfile(path,'.git','logs','HEAD'),'r');
            
            if fid < 3, return; end
            
            while ~feof(fid)
                g = fgetl(fid);
            end
            fclose(fid);
            
            a = find(g==' ');
            chksum = g(a(1)+1:a(2)-1);
        end
        
        
        function title = genTitle(obj)
            info = Helpers.getInfoStr(obj.info);
            if isempty(info)
                title = sprintf('Channel %d',obj.channel);
            else
                title = sprintf('%s | %s | Channel %d', ...
                    info.TankName,info.BlockName,obj.channel);
            end
        end
        
        
        function infoStruct = getInfoStr(infoStr,format,delim)
            % infoStruct = getInfoStr(infoStr,[format],[delim])
            if nargin < 1 || isempty(infoStr), infoStruct = []; return; end
            if nargin < 2 || isempty(format), format = '%s %q'; end
            if nargin < 3 || isempty(delim), delim = ':'; end
            c = textscan(infoStr,format,'delimiter',delim);
            c{1} = matlab.lang.makeValidName(c{1});
            infoStruct = cell2struct(c{2},c{1});
        end
        
        function me = getME(c,id,msg,varargin)
            % generates exception error fields identifier and stack of
            % calling function.  Add final message identifier and message
            % fields manually.
            %
            % msg is a string (char) message and has sprintf functionality.
            %
            % ex:  
            %    theBadThing = 'aef;oijea';
            %    me = Helpers.getME('BadThing','Bad thing: %s',theBadThing)
            c(1:find(c=='.')) = [];
            d = dbstack;
            d(1) = [];
            me.identifier = [c ':' id];
            me.stack      = d;
            me.message    = sprintf(msg,varargin{:});
        end
        
        
    end
    
end













