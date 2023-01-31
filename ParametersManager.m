% ParametersManager
% -------------------------------------------------------------------------
% A class to manage the Parameters of an analysis program.
%
% Instantiate with: pM = ParametersManager()
%               or: pM = ParametersManager(dictionary)
% -------------------------------------------------------------------------
classdef ParametersManager < matlab.mixin.Copyable
    %% Properties 
    properties
        paramDictionary     % Dictionary containing all the types of parameters.
        ch_paramInterest    % Parameters/Variables to plot in the Characteristics section.
        tf_paramInterest    % Parameters/Variables to plot in the Transfer function section.
        time_paramInterest  % Parameters/Variables to plot in the Time Series section.
    end
    methods
        %% Constructor
        % pM = ParametersManager()
        % pM = ParametersManager(dictionary)
        % ----------------------------------
        % Instantiate a ParametersManager object. The first additional
        % argument is attributed to the parameters dictionary property.
        function self = ParametersManager(varargin)
            if nargin > 0
                self.paramDictionary = varargin{1};
            end
        end
        
        
        
        %% Add parameters of interest to the Characteristics section
        % pM.addCh(parameters)
        % --------------------
        % Assign a set of parameters of interest in the characteristics
        % section. The type of the first argument is Parameters. 
        function addCh(self, paramInterest)
            self.ch_paramInterest = paramInterest;
        end
        
        
        
        %% Add parameters of interest to the Transfer function section
        % pM.addTf(parameters)
        % --------------------
        % Assign a set of parameters of interest in the transfer function
        % section. The type of the first argument is Parameters.
        function addTf(self, paramInterest)
            self.tf_paramInterest = paramInterest;
        end
        
        
        
        %% Add parameters of interest to the Chara section
        % pM.addTime(parameters)
        % ----------------------
        % Assign a set of parameters of interest in the time series
        % section. The type of the first argument is Parameters.
        function addTime(self, paramInterest)
            self.time_paramInterest = paramInterest;
        end
        
        
        
        %% Create a dictionary
        % pM.createDictionary()
        % ---------------------
        % Create a default hard-coded dictionary and save it or, if one exists 
        % in the current directory under the name "parameterDictionary.csv", 
        % load this dictionary.
        function createDictionary(self)
            % Create a dictionary.
            self.paramDictionary = Dictionary();
            pDFile = dir(['parameterDictionary.csv']);
            if(~isempty(pDFile)) % Load values
                self.paramDictionary.load(pDFile.name);
            else % Or create values
                self.paramDictionary.addKey('none', 'none $n$', ' ');
                self.paramDictionary.addKey('File', 'file', ' ');
                self.paramDictionary.addKey('Test', 'Test $t$', ' ');
                self.paramDictionary.addKey('pH', 'pH', ' ');
                self.paramDictionary.addKey('T', 'Temperature', '$^\circ$C');
                self.paramDictionary.addKey('Time', 'Start Time', 'min');
                self.paramDictionary.addKey('Sol', 'Solution Droplet', ' ');
                self.paramDictionary.addKey('Take', 'Take', ' ');
                self.paramDictionary.addKey('Cycle', 'Cycle', ' ');
                self.paramDictionary.addKey('Run', 'Run', ' ');
                self.paramDictionary.addKey('Channel', 'Channel', ' ');
                self.paramDictionary.addKey('VGS','Gate Voltage $V_\textrm{GS}$', 'V');
                self.paramDictionary.addKey('VDS','Drain Voltage $V_\textrm{DS}$', 'V');
                self.paramDictionary.addKey('Freq','Frequency $f$','Hz');
                self.paramDictionary.addKey('Tint','Internal temperature $T_\textrm{int}$','$^\circ$C');
                self.paramDictionary.addKey('Phase','Phase $\phi$','$^\circ$');
                self.paramDictionary.addKey('File','file',' ');
                self.paramDictionary.addKey('Sheet','sheet',' ');
                self.paramDictionary.save(['parameterDictionary.csv']);
            end
        end
        
        
        
        %% Compare parameters sets
        % [intersection, difference12, difference21] = pM.cmpParameters(parameters, type)
        % -------------------------------------------------------------------------------
        % Compare the input parameters set with the one of the Manager of
        % specified type (characteristics, transfer function or time). The
        % output is the common parameters, the ones specific to the
        % Manager's set and the ones specific to the input's.
        function [in, sd1, sd2] = cmpParameters(self, param, type)
            switch type
                case 'ch'
                    in = intersect(self.ch_paramInterest,param);
                    sd1 = setdiff(self.ch_paramInterest,param);
                    sd2 = setdiff(param,self.ch_paramInterest);
                case 'tf'
                    in = intersect(self.tf_paramInterest,param);
                    sd1 = setdiff(self.tf_paramInterest,param);
                    sd2 = setdiff(param,self.tf_paramInterest);
               
                case 'time'
                    in = intersect(self.time_paramInterest,param);
                    sd1 = setdiff(self.time_paramInterest,param);
                    sd2 = setdiff(param,self.time_paramInterest);
               
                otherwise
                    error('Error. Type of comparison not defined.');
            end
        end
        
        
        
        %% Confirm the choice of Parameters and display values
        % choice = pM.confirm(intersection, difference12, difference21, parameters, type)
        % -------------------------------------------------------------------------------
        % Confirm the choice of parameters. The input is given by the
        % output of the parametersManager.cmpParameters() function, the set
        % of parameters of interest and the type of (characteristics,
        % transfer function or time).
        function choice = confirm(self, var, in, sd1, sd2, paramInterest, type)
            % Get the not found parameters
            sd1 = setdiff(sd1, {'none'});
            
            % Set the size of the interface.
            Pix_SS = get(0,'screensize');
            TableLength = length(in)+length(sd2)+length(sd1);
            X = 500;
            Y = 120 + TableLength*40;
            
            % Create the interface
            d = uifigure('Position',[((Pix_SS(3)-X)/2) ((Pix_SS(4)-Y)/2) X Y],'Name',[type ' Parameters']);
            
            % Add table rows for the parameters of interest
            rowNames = {};
            rowNames{end+1} = 'variable';
            for i = 1:length(in)
                for j = 1:length(paramInterest)
                    if(strcmp(paramInterest{j}, in{i}))
                        switch j
                            case 1
                                rowNames{end+1} = 'x axis';
                            case 2
                                rowNames{end+1} = 'colours';
                            case 3
                                rowNames{end+1} = 'subfigures';
                            case 4
                                rowNames{end+1} = 'figures';
                            case 5
                                rowNames{end+1} = 'line types';
                            case 6
                                rowNames{end+1} = 'marker types';
                        end
                    end
                end
            end
            
            % Add table rows for the parameters that are not of interest
            for k = 1:length(sd2)
                rowNames{end+1} = ['Working Point ' num2str(k)];
            end
            
            % Add table rows for parameters of interest that are missing
            for l = 1:length(sd1)
                rowNames{end+1} = ['Missing ' num2str(l)];
            end
            
            % Create the table
            T = table('Size', [TableLength+1 4],...
                'VariableTypes',{'string','string','string','string'},...
                'VariableNames',{'Keyword','Display_name','Unit','Values'},...
                'RowNames', rowNames);
            
            % Fill in values to the table
            T(1,1) = var(1);
            T(1,2) = {[var{2} ' ' var{3}]};
            T(1,3) = var(4);
            T(1,4) = {'all'};
            for i = 1:length(in)
                T(i+1,1) = in(i); 
                v = self.paramDictionary.getValue(in{i});
                T(i+1,2) = {v.name};
                T(i+1,3) = {v.other};
                T(i+1,4) = {'all'};
            end
            for k = 1:length(sd2)
                T(length(in)+k+1,1) = sd2(k);
                v = self.paramDictionary.getValue(sd2{k});
                T(length(in)+k+1,2) = {v.name};
                T(length(in)+k+1,3) = {v.other};
                T(length(in)+k+1,4) = {'ignore'};
            end
            for l = 1:length(sd1)
                T(length(in)+length(sd2)+l+1,1) = sd1(l);
                T(length(in)+length(sd2)+l+1,4) = {'error'};
            end
            
            % Add table to the interface
            uit = uitable(d,'Data',T);
            uit.Position = [20 100 460 TableLength*40];
            if(~verLessThan('matlab','9.7'))
                miss = uistyle('BackgroundColor','red');
                addStyle(uit,miss,'row', length(in)+length(sd2)+1+1:TableLength+1);
            end
            
            % Add control tools
            txt = uilabel('Parent',d,...
                'Position',[20 60 210 40],...
                'Text','Modify and close to confirm:');
            
            name = uieditfield('Parent',d,...
                'Position',[180 40 135 25],...
                'Value',T{1,2});
            
            unit = uieditfield('Parent',d,...
                'Position',[330 40 80 25],...
                'Value',T{1,3});
            
            val = uidropdown('Parent',d,...
                'Position',[420 40 70 25],...
                'Value', 'all',...
                'Items',{'all'},...
                'Editable','on', 'Enable', 'off');
            
            dd = uidropdown('Parent',d,...
                'Position',[75 40 90 25],...
                'Items',[var(1),in,sd2,sd1],...
                'ValueChangedFcn',@(dd,event0, event1,event2,event3) selection(dd, T, name, unit, val));
            
            btn = uibutton('Parent',d,...
                'Position',[89 10 70 25],...
                'Text','Modify',...
                'ButtonPushedFcn', @(btn,event0, event1,event2,event3,event4,event5) plotButtonPushed(btn, uit.Data,dd, name, unit, val,uit));
            
            % Output the table data
            choice = uit.Data;
            
            % Wait for d to close before running to completion
            uiwait(d);
            
            % ----------------
            % Nested Functions
            % ----------------
            
            % selection(calling dropdown, table, name, unit, value)
            % -----------------------------------------------------
            % Find the selected row of the table and display it in the
            % control tools.
            function selection(dd,T,name, unit, val)
                % Find the row selected
                keyword = dd.Value;
                rowIdx = find(ismember(T{1:end,1}, keyword));
                % Get and display
                if(strcmp(T{rowIdx,4},'all')) %in
                    val.Enable = 'off';
                    val.Value = 'all';
                    val.Items = {'all'};
                    unit.Enable = 'on';
                    name.Enable = 'on';
                elseif(strcmp(T{rowIdx,4},'error')) %sd1
                    val.Enable = 'off';
                    val.Value = 'error';
                    val.Items = {'error'};
                    unit.Enable = 'off';
                    name.Enable = 'off';
                else %sd2
                    val.Enable = 'on';
                    val.Value = 'ignore';
                    val.Items = {'default','ignore','Enter a value'};
                    unit.Enable = 'on';
                    name.Enable = 'on';
                end
                name.Value = T{rowIdx,2};
                unit.Value = T{rowIdx,3};
            end
            
            
        % plotButtonPushed(button, table, dropdown, name, unit, value, user interface table)
        % ----------------------------------------------------------------------------------
        % Change the selected row values in the interface by the values in
        % the control tools.
        function plotButtonPushed(btn, T, dd, name, unit, val,uit)
            keyword = dd.Value;
            rowIdx = find(ismember(T{1:end,1}, keyword));
            T(rowIdx,2) = {name.Value};
            T(rowIdx,3) = {unit.Value};
            T(rowIdx,4) = {val.Value};
            uit.Data = T;
            choice = uit.Data;
        end
      
        end
        
        
        %% Confirm the choice of Parameters and display values
        % parametersList = pM.makeList(table)
        % -------------------------------------------------------------------------------
        % Make a list of parameters from a a table.
        function pL = makeList(self,table)
            pL = {};
            for i = 1:height(table)
                element = table{i,5}{1};
                num = str2double(element);
                num2 = str2num(element);

                prefix = string(table{i,3});
                if(strcmp(prefix, "-"))
                    prefix = "";
                end
                if(strcmp(element , 'error'))
                    error(strjoin(["Error." ,table{i,1}{1}, " is not detected in the files."]));
                elseif(strcmp(element , 'all'))
                    pL{end+1} = Parameters(table{i,1}{1},table{i,2}{1}, join([prefix,table{i,4}{1}], ""));
                elseif(strcmp(element , 'default'))
                    pL{end+1} = Parameters(table{i,1}{1},table{i,2}{1}, join([prefix,table{i,4}{1}], ""));
                elseif(strcmp(element , 'ignore'))
                    pL{end+1} = Parameters(table{i,1}{1},table{i,2}{1}, join([prefix,table{i,4}{1}], ""));
                
                elseif(~isnan(num))
                    pL{end+1} = Parameters(table{i,1}{1},table{i,2}{1}, join([prefix,table{i,4}{1}], ""), num);
                elseif(~isempty(num2))
                    pL{end+1} = Parameters(table{i,1}{1},table{i,2}{1}, join([prefix,table{i,4}{1}], ""), num2);
                else
                    error([element ' should be a standard value or a number.']);
                end
            end
        end
        
        
        
    end
end