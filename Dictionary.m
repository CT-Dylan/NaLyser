% Dictionary
% -------------------------------------------------------------------------
% A class that store and allows the access of values through keywords.
%
% Instantiate with: d = Dictionary()
% -------------------------------------------------------------------------
classdef Dictionary < matlab.mixin.Copyable
    %% Properties
    properties
        keys
        values
    end
    methods
        %% Constructor
        % d = Dictionary()
        % ----------------
        % Instantiate a Dictionary object.
        function self = Dictionary()
            self.keys = {};
            self.values = struct('name', {}, 'other', {}, 'v', []);
        end
        
        
        
        %% Sort the dictionary
        % d.sortDictionary()
        % d.sortDictionary(keyword)
        % -------------------------
        % Sort the values in the dictionary, or for a specific section of
        % it. Also removes duplicate values.
        function sortDictionary(self, varargin)
            switch nargin 
                case 1   %sortDictionary()
                    for i = 1:length(self.values)
                        self.values(i).v = unique(sort(self.values(i).v));
                    end
                case 2   %sortDictionary(name)
                    if ~(isstring(varargin{1})|ischar((varargin{1})))
                        error('Error. \n First input must be a string, not a %s.',class(varargin{1}))
                    end
                    for i = 1:length(self.values)
                        if(strcmp(self.values(i).name, varargin{1}))
                            self.values(i).v = unique(sort(self.values(i).v));
                        end
                    end
                otherwise 
                    error('Error. Invalid number of inputs.')
            
             end
        end
        
        
        
        %% Add keyword to the dictionary
        % d.addKey(key, values set name, other information)
        % -------------------------------------------------
        % Add a keyword to a dictionary, with the associated name and
        % information.
        function addKey(self, key, name, other)
            for i = 1:length(self.values)
                if(strcmp(self.keys(i), key))
                    disp('Key already exists.')
                    return;
                end          
            end
            if ~(isstring(key)|ischar(key))
                 error('Error. \n First input must be a string, not a %s.',class(key))
            end
            
            if ~(isstring(name)|ischar(name))
                 error('Error. \n Second input must be a string, not a %s.',class(name))
            end
            
            if ~(isstring(other)|ischar(other))
                 error('Error. \n Third input must be a string, not a %s.',class(other))
            end
            self.keys{end+1} = key;
            self.values(end+1) = struct('name', name, 'other', other, 'v', []);
       
        end
        
        
        
        %% Add a value
        % d.addvalue(keyword, value to add)
        % ---------------------------------
        % Add a value to the data linked to a keyword of the dictionary.
        function addValue(self, key, value)
            Found = 0;
            for i = 1:length(self.keys)
                if(strcmp(self.keys{i}, key))
                    Found = 1;
                    self.values(i).v = [self.values(i).v; value]; 
                end          
            end
            if Found == 0
                disp('Error. Key not found.');
            end
        end
        
        
        
        %% Find the location of a parameter
        % index = d.findparameter(keyword)
        % --------------------------------
        % Gives the location index of the data linked to the keyword given
        % in input.
        function i = findparameter(self, name)
            Found = 0;
            for i = 1:length(self.values)
                if(strcmp(self.values(i).name, name))
                    Found = 1;
                    break;
                end
            end
            if(Found == 0)
                i = NaN;
            end
        end
        
        
        
        %% Load a dictionary
        % d.load(file name)
        % -----------------
        % Load the information of a dictionary stored previously using the
        % Dictionary.save() function.
        function load(self,file)
           try
               if(2019 <= [cellfun(@str2num,regexp(version('-release'),'\d+','match'))])
                    tmp = readcell(file,'Delimiter',',','Whitespace','');
                   
                    for i = 1:size(tmp,1)
                        self.addKey(tmp{i,1},tmp{i,2},tmp{i,3})
                    end
               else
                    tmp = readtable(file,'ReadVariableNames',false);
                    
                    for i = 1:size(tmp,1)
                        self.addKey(table2array(tmp{i,1}),table2array(tmp{i,2}),table2array(tmp{i,3}));
                    end
               end
           catch
               error("Error. No dictionary to load.")
           end
        end
        
        
        
        %% Save the dictionary
        % d.save(file name)
        % -----------------
        % Save the current dictionary in the current directory under the
        % name given in input.
        function save(self,file)
            f = fopen(file, 'w');
            try
            for i = 1:length(self.keys)
                fprintf(f, [self.keys{i}]);
                fprintf(f, [',"' strrep(self.values(i).name,'\','\\') '"']);
                fprintf(f, [',"' strrep(self.values(i).other,'\','\\') '"']);
                fprintf(f, [',"' self.values(i).v '"']);
                fprintf(f, '\r\n');
            end
            catch
                fclose(f);
                error('Error. Dictionary save unsuccessful.');
            end
            fclose(f);
        end
        
        
        
        %% Get the values
        % values = d.getValue(keyword)
        % -------------------
        % Return the values linked to the keyword given in the input.
        function [v, returnType, returnString] = getValue(self,key, varargin)
            returnType = 1;
            returnString = '';
            for i = 1:length(self.keys)
                currentK = self.keys(i);
                if(strcmp(currentK, key))
                    v = self.values(i);
                    return
                end
            end
            
            
            % If not found, try to see if a parameter starts with a
            % keyword.
            returnType = 0;
            for i = 1:length(self.keys)
                currentK = self.keys(i);
                if(startsWith(key, currentK))
                    v = self.values(i);
                    returnString = extractAfter(key, currentK);
                    return
                end
            end

            returnType = -1;

            v = struct([]);
        end
        
    end
end