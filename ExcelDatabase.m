% ExcelDatabase
% -------------------------------------------------------------------------
% A class that stores the values within Excel files.
%
% Instantiate with: ed = ExcelDatabase()
% -------------------------------------------------------------------------
classdef ExcelDatabase < matlab.mixin.Copyable
    %% Properties
    properties
        filenames   % name of the excel files
        sheetnames  % name of the excel sheets
        sheetdata   % data contained in the excel sheets
        size        % size of the database
        readIdx     % index of where the reading pointer is
    end

    methods
        %% Constructor
        % ed = ExcelDatabase()
        % ed = ExcelDatabase(size)
        function self = ExcelDatabase(varargin)
            self.filenames = {};
            self.sheetnames = {};
            self.sheetdata = {};
            self.size = 0;
            self.readIdx = 1;
        end


        
        %% Add a sheet to the database
        % ed.addSheet("sheet.xlsx","Run12",content)
        function addSheet(self, filename, sheetname, sheetdata)
            self.filenames{end+1} = filename;
            self.sheetnames{end+1} = sheetname;
            self.sheetdata{end+1} = sheetdata;
            self.size = self.size+1;
        end



        %% Get the index of a requested file
        % idx = ed.findfile("sheet.xlsx")
        function found = findFile(self, filename)
            found = [];
            for i = 1:self.size
                if(contains(self.filenames{i}, filename))
                    found(end+1) = i;
                end
            end
        end



        %% Get the index of a requested sheet
        % idx = ed.findsheet("Run12")
        function found = findSheet(self, sheetname)
            found = [];
            for i = 1:self.size
                if(contains(self.sheetnames{i}, sheetname))
                    found(end+1) = i;
                end
            end
        end



        %% Reset the reading pointer
        % ed.resetReadIdx()
        function resetReadIdx(self)
            self.readIdx = 1;
        end



        %% Read the data of a sheet
        % data = ed.read()
        % data = ed.read(n)
        function S = read(self, varargin)
            switch nargin
                case 0
                    S = self.sheetdata{self.readIdx};
                    self.readIdx = self.readIdx+1;
                case 1 
                    S = self.sheetdata{self.readIdx};
                    self.readIdx = self.readIdx+1;
                case 2
                    if ~(isnumeric(varargin{1}))
                        error('Error. \n First input must be numeric, not a %s.',class(varargin{1}))
                    end
                    
                    S = self.sheetdata{varargin{1}};
                    
                    self.readIdx = varargin{1}+1;
                otherwise
                    error('Error. Invalid number of inputs.')
            end
            if(self.readIdx > self.size)
                self.readIdx = 1;
            end
            
        end
    end
end