% Data
% -------------------------------------------------------------------------
% A class that stores the values of a measured quantity as a function of 
% parameters. They can be stored as a matrix/tensor or as a table of
% coordinates and values.
%
% Instantiate with: d = Data()
%                or d = Data(name, display name, unit)
%                or d = Data(name, display name, unit, Parameters) 
%                or d = Data(name, display name, unit, Parameters, values)
% -------------------------------------------------------------------------
classdef Data < matlab.mixin.Copyable
    %% Properties
    properties
        name                % name of the quantity
        symbol              % symbol representing the quantity
        unit                % unit of the quantity
        parameters          % parameters on which the quantity depends
        values              % matrix of the quantity values as a function of the parameters
        filled              % matrix of filled values (1 if the values element at the same location was filled, 0 otherwise)
        table               % table of the quantity values
    end
    methods
        %% Constructor
        % d = Data()
        % d = Data(name, display name, unit)
        % d = Data(name, display name, unit, Parameters) 
        % d = Data(name, display name, unit, Parameters, values)
        % ------------------------------------------------------
        % Instantiate a Data object. Some properties can directly be
        % filled.
        function self = Data(varargin)
            switch nargin
                case 0 
                case 3 %Data(name, symbol, unit)
                    if ~(isstring(varargin{1})|ischar((varargin{1})))
                        error('Error. \n First input must be a string, not a %s.',class(varargin{1}))
                    end
                    self.name = varargin{1};
                    if ~(isstring(varargin{2})|ischar((varargin{2})))
                        error('Error. \n Second input must be a string, not a %s.',class(varargin{2}))
                    end
                    self.symbol = varargin{2};
                    if ~(isstring(varargin{3})|ischar((varargin{3})))
                        error('Error. \n Third input must be a string, not a %s.',class(varargin{2}))
                    end
                    self.unit = varargin{3};
                case 4 %Data(name, symbol, unit, parameters)
                    if ~(isstring(varargin{1})|ischar((varargin{1})))
                        error('Error. \n First input must be a string, not a %s.',class(varargin{1}))
                    end
                    self.name = varargin{1};
                    if ~(isstring(varargin{2})|ischar((varargin{2})))
                        error('Error. \n Second input must be a string, not a %s.',class(varargin{2}))
                    end
                    self.symbol = varargin{2};
                    if ~(isstring(varargin{3})|ischar((varargin{3})))
                        error('Error. \n Third input must be a string, not a %s.',class(varargin{2}))
                    end
                    self.unit = varargin{3};
                    self.parameters = varargin{4};
                case 5 %Data(name, symbol unit, parameters, values)
                    if ~(isstring(varargin{1})|ischar((varargin{1})))
                        error('Error. \n First input must be a string, not a %s.',class(varargin{1}))
                    end
                    self.name = varargin{1};
                    if ~(isstring(varargin{2})|ischar((varargin{2})))
                        error('Error. \n Second input must be a string, not a %s.',class(varargin{2}))
                    end
                    self.symbol = varargin{2};
                    if ~(isstring(varargin{3})|ischar((varargin{3})))
                        error('Error. \n Third input must be a string, not a %s.',class(varargin{2}))
                    end
                    self.unit = varargin{3};
                    self.parameters = varargin{4};
                    self.values = varargin{5};
                    self.filled = (self.values ~= 0);
                otherwise
                    error('Error. Invalid number of inputs.')
            end
        end
        
        
        
        %% Allocate values
        % d.allocateValues
        % ----------------
        % Create a NaN array in the values property with the size given by
        % the Parameters lengths in the order stored the parameters
        % property.
        function allocateValues(self)
            sz = [];
            for i = 1:length(self.parameters)
                sz = [sz length(self.parameters{i}.values)];
            end
            if length(sz) <= 1
                self.values = nan(sz,1);
            else
                self.values = nan(sz);
            end
        end
        
        
        
        %% Find the index of a parameter
        % index = findparameter(parameter name)
        % -------------------------------------
        % Get the index of the parameter of given name, as it is stored in
        % the parameter property.
        function i = findparameter(self, name)
            Found = 0;
            % Find exact name
            for i = 1:length(self.parameters)
                if(strcmp(self.parameters{i}.name, name))
                    Found = 1;
                    break;
                end
            end

            if(Found == 0)
                %Else find if contains the name
                for i = 1:length(self.parameters)
                if(contains(name,self.parameters{i}.name))
                    Found = 1;
                    break;
                end
                end
            end

            % Else not found
            if(Found == 0)
                i = NaN;
            end
        end
        
        
        
        %% Get a parameter
        % parameter = d.getParameter(index)
        % ---------------------------------
        % Get a parameter stored at the location index given in input.
        function P = getParameter(self, i)
            if(isnan(i))
                P = Parameters('none', 'none');
            else
                P = self.parameters{i};
            end
        end
        
        
        
        %% Assign the vector to the values matrix/tensor at a given position
        % d.assignVector(vector, index of the vector parameter, other parameter indices)
        function assignVector(self, vector, dim, vararg)
            switch nargin
                case 3 %assignVector(v, 1)
                    self.values = vector;
                case 4 %assignVector(v, 1, other)
                    if dim == 1
                        
                    switch length(vararg)
                        case 1
                            self.values(:,vararg(1)) = vector;
                        case 2
                            self.values(:,vararg(1),vararg(2)) = vector;
                        case 3
                            self.values(:,vararg(1),vararg(2),vararg(3)) = vector;
                        case 4
                            self.values(:,vararg(1),vararg(2),vararg(3), vararg(4)) = vector;
                        case 5
                            self.values(:,vararg(1),vararg(2),vararg(3), vararg(4), vararg(5)) = vector;
                    end
                    end
                    
                    if dim == 2
                        
                    switch length(vararg)
                        case 1
                            self.values(vararg(1),:) = vector;
                        case 2
                            self.values(vararg(1),:,vararg(2)) = vector;
                        case 3
                            self.values(vararg(1),:,vararg(2),vararg(3)) = vector;
                        case 4
                            self.values(vararg(1),:,vararg(2),vararg(3), vararg(4)) = vector;
                        case 5
                            self.values(vararg(1),:,vararg(2),vararg(3), vararg(4), vararg(5)) = vector;
                    end
                    end
                    if dim == 3
                        
                    switch length(vararg)
                    
                        case 2
                            self.values(vararg(1),vararg(2),:) = vector;
                        case 3
                            self.values(vararg(1),vararg(2),:,vararg(3)) = vector;
                        case 4
                            self.values(vararg(1),vararg(2),:,vararg(3), vararg(4)) = vector;
                        case 5
                            self.values(vararg(1),vararg(2),:,vararg(3), vararg(4), vararg(5)) = vector;
                    end
                    end
                    if dim == 4
                        
                    switch length(vararg)
                    
                        case 3
                            self.values(vararg(1),vararg(2),vararg(3),:) = vector;
                        case 4
                            self.values(vararg(1),vararg(2),vararg(3),:, vararg(4)) = vector;
                        case 5
                            self.values(vararg(1),vararg(2),vararg(3),:, vararg(4), vararg(5)) = vector;
                    end
                    end
                    if dim == 5
                        
                    switch length(vararg)
                    
                        case 4
                            self.values(vararg(1),vararg(2),vararg(3), vararg(4),:) = vector;
                        case 5
                            self.values(vararg(1),vararg(2),vararg(3), vararg(4),:, vararg(5)) = vector;
                    end
                    end
                otherwise
                    error('Error. Invalid number of inputs.')
            end
            
        end
        
        
        
        %% Create a table
        % d.createTable()
        % ---------------
        % Create an initial table of NaN.
        function createTable(self)
            tmp = [self.parameters{:}];
            names = {tmp.name};
            self.table = nan(1,length(names)+1);
        end
        
        
        
        %% Add rows to the table
        % d.add2Table(table rows)
        % -----------------------
        % Add rows to the table. Size should match.
        function add2Table(self,rows)
            if(size(self.table,1) == 1)
                self.table(end:end+size(rows,1)-1, :) = rows;
            else
                self.table(end+1:end+size(rows,1), :) = rows;
            end
        end
        
        
        
        %% Filter the table
        % d.filter()
        % ----------
        % Filter the unnecessary columns (not of interest) of the table.
        function filter(self,T)
            for i = 1:height(T)
                num = str2num(T{i,end}{1});
                if(strcmp(T{i,end}{1}, 'default'))                
                    self.table = self.table(self.table(:,i) == self.table(1,i+1),:);
                    self.parameters{i}.values = self.table(1,i+1);

                elseif(strcmp(T{i,end}{1}, 'ignore'))
                    self.table(:,i+1) = NaN;

                elseif((~isnan(num))&(~isempty(num)))
                    idx = [];
                    for n = 1:length(num)
                        idx = [idx; find(self.table(:,i+1) == num(n))];
                    end
                    self.table = self.table(idx,:);
                end
            end
        end
        


        %% Remove values associated to subfigures that do not need to be kept.
        % d.keepSubfigure(table, keptValues)
        % ----------------------------------
        function keepSubfigure(self,T, keep)
            try
                if(sum(contains(T.Properties.RowNames, "subfigures")))
                    idx = self.findparameter(T{"subfigures","Name"});
                    val = unique(self.table(:,idx+1));
                    remove = setdiff(val, keep);
                    rIdx = [];
                    for r = 1:length(remove)
                        rIdx = [rIdx; find(self.table(:,idx+1) == remove(r))];
                    end
                    self.table(rIdx,:) = [];
                end
            catch
                error("Subfigures adjustment failed.");
            end
        end
        
        
        
        %% Convert table to values matrix/tensor
        % d.convertTable2Values()
        % -----------------------
        % Convert the rows of the table into a matrix/tensor of values.
        function convertTable2Values(self)
            for i = 1:length(self.parameters)
                if(any(isnan(self.table(:,i+1)))) % If a column contains NaN values
                    self.parameters{i}.values = NaN;
                    idcs(:,i) = ones(size(self.table(:,i+1)));
                else
                    [self.parameters{i}.values, tmp, idcs(:,i)] = unique(self.table(:,i+1));
                end
            end
            self.allocateValues();
            self.values = accumarray(idcs, self.table(:,1), [],@(x) x(end)); % If same indices, take the last element
            self.filled = accumarray(idcs, true, [],@(x) x(end)); % If same indices, take the last element
        end
    
    end
end