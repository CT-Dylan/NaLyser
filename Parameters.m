% Parameters
% -------------------------------------------------------------------------
% A class that represents a parameter/variable and its values.
%
% Instantiate with: p = Parameters()
%                or p = Parameters(name)
%                or p = Parameters(name, display name, unit)
%                or p = Parameters(name, display name, unit, values)
%                or p = Parameters(name, display name, initial value, final value, spacing inbetween)
%                or p = Parameters(name, display name, unit, initial value, final value, spacing inbetween)
%                or p = Parameters(name, display name, unit, values, initial value, final value, spacing inbetween)
% -------------------------------------------------------------------------
classdef Parameters < handle
    %% Properties
    properties
        name
        symbol
        unit
        values
        
        init
        fin
        spacing
        options
    end
    methods
        %% Constructor
        % p = Parameters()
        % p = Parameters(name)
        % p = Parameters(name, display name, unit)
        % p = Parameters(name, display name, unit, values)
        % p = Parameters(name, display name, initial value, final value, spacing inbetween)
        % p = Parameters(name, display name, unit, initial value, final value, spacing inbetween)
        % p = Parameters(name, display name, unit, values, initial value, final value, spacing inbetween)
        % -----------------------------------------------------------------------------------------------
        % Instantiate a Parameters object.
        function self = Parameters(varargin)
            switch nargin
                case 0 %Parameters()
                case 2 %Parameters(name)
                    if ~(isstring(varargin{1})|ischar((varargin{1})))
                        error('Error. \n First input must be a string, not a %s.',class(varargin{1}))
                    end
                    if ~(isstring(varargin{2})|ischar((varargin{2})))
                        error('Error. \n Second input must be a string, not a %s.',class(varargin{1}))
                    end
                    self.name = varargin{1};
                    self.symbol = varargin{2};
                case 3 %Parameters(name, symbol, unit)
                    if ~(isstring(varargin{1})|ischar((varargin{1})))
                        error('Error. \n First input must be a string, not a %s.',class(varargin{1}))
                    end
                    if ~(isstring(varargin{2})|ischar((varargin{2})))
                        error('Error. \n Second input must be a string, not a %s.',class(varargin{1}))
                    end
                    if ~(isstring(varargin{3})|ischar((varargin{3})))
                        error('Error. \n Third input must be a string, not a %s.',class(varargin{1}))
                    end
                    self.name = varargin{1};
                    self.symbol = varargin{2};
                    self.unit = varargin{3};
                    self.options = 1;
                case 4 %Parameters(name, symbol, unit, values)
                    if ~(isstring(varargin{1})|ischar((varargin{1})))
                        error('Error. \n First input must be a string, not a %s.',class(varargin{1}))
                    end
                    if ~(isstring(varargin{2})|ischar((varargin{2})))
                        error('Error. \n Second input must be a string, not a %s.',class(varargin{1}))
                    end
                    if ~(isstring(varargin{3})|ischar((varargin{3})))
                        error('Error. \n Third input must be a string, not a %s.',class(varargin{1}))
                    end
                    self.name = varargin{1};
                    self.symbol = varargin{2};
                    self.unit = varargin{3};
                    self.values = varargin{4};
                    self.init = self.values(1);
                    self.fin = self.values(end);
                    self.options = 1;
                case 5 %Parameters(name, symbol, init, fin, spacing)
                    if ~(isstring(varargin{1})|ischar((varargin{1})))
                        error('Error. \n First input must be a string, not a %s.',class(varargin{1}))
                    end
                    if ~(isstring(varargin{2})|ischar((varargin{2})))
                        error('Error. \n Second input must be a string, not a %s.',class(varargin{1}))
                    end
                    self.name = varargin{1};
                    self.symbol = varargin{2};
                    self.init = varargin{3};
                    self.fin = varargin{4};
                    self.spacing = varargin{5};
                    self.values = self.init:self.spacing:self.fin;
                    self.options = 1;
                case 6 %Parameters(name, symbol, unit, init, fin, spacing)
                    if ~(isstring(varargin{1})|ischar((varargin{1})))
                        error('Error. \n First input must be a string, not a %s.',class(varargin{1}))
                    end
                    if ~(isstring(varargin{2})|ischar((varargin{2})))
                        error('Error. \n Second input must be a string, not a %s.',class(varargin{1}))
                    end
                    if ~(isstring(varargin{3})|ischar((varargin{3})))
                        error('Error. \n Third input must be a string, not a %s.',class(varargin{1}))
                    end
                    self.name = varargin{1};
                    self.symbol = varargin{2};
                    self.unit = varargin{3};
                    self.init = varargin{4};
                    self.fin = varargin{5};
                    self.spacing = varargin{6};
                    self.values = self.init:self.spacing:self.fin;
                    self.options = 1;
                 case 7 %Parameters(name, symbol, unit, values, init, fin, spacing)
                    if ~(isstring(varargin{1})|ischar((varargin{1})))
                        error('Error. \n First input must be a string, not a %s.',class(varargin{1}))
                    end
                    if ~(isstring(varargin{2})|ischar((varargin{2})))
                        error('Error. \n Second input must be a string, not a %s.',class(varargin{1}))
                    end
                    if ~(isstring(varargin{3})|ischar((varargin{3})))
                        error('Error. \n Third input must be a string, not a %s.',class(varargin{1}))
                    end
                    self.name = varargin{1};
                    self.symbol = varargin{2};
                    self.unit = varargin{3};
                    self.values = varargin{4};
                    self.init = varargin{5};
                    self.fin = varargin{6};
                    self.spacing = varargin{7};
                    self.options = 1;
                    
                otherwise
                    error('Error. Invalid number of inputs.')
            end
        end
        
        
        
        %% Change the values
        % p.changeValues(new values)
        % p.changeValues(new initial value, new final value, new spacing inbetween)
        % -------------------------------------------------------------------------
        % Replace the stored parameter values by new ones.
        function changeValues(self,varargin)
            switch nargin 
                case 2   %changeValues(newValues)
                    self.values = varargin{1};
                    self.init = self.values(1);
                    self.fin = self.values(end);
                case 4   %changeValues(newInit, newFin, newSpacing)
                    self.init = varargin{1};
                    self.fin = varargin{2};
                    self.spacing = varargin{3};
                    self.values = self.init:self.spacing:self.fin;
                otherwise 
                    error('Error. Invalid number of inputs.')
            end
        end
        
        
        
        %% Add a value to the current ones
        % p.addValues(new values)
        % p.addValues(new initial value, new final value, new spacing inbetween)
        % -------------------------------------------------------------------------
        % Add to the stored parameter values the new ones.
        function addValues(self,varargin)
            self.options = self.options + 1;
            switch nargin 
                case 2   %addValues(newValues)
                    self.values(self.options) = varargin{1};
                    self.init = self.values(self.options, 1);
                    self.fin = self.values(self.options, end);
                case 4   %addValues(newInit, newFin, newSpacing)
                    self.init(self.options) = varargin{1};
                    self.fin(self.options) = varargin{2};
                    self.spacing(self.options) = varargin{3};
                    self.values(self.options) = self.init:self.spacing:self.fin;
                otherwise 
                    error('Error. Invalid number of inputs.')
            end
        end
    end
end