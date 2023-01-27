% Parameters
% -------------------------------------------------------------------------
% A class that manage the graphical display and figures
%
% Instantiate with: g = Graphs()
%                or g = Graphs(name)
%                or g = Graphs(name, Data)
%                or g = Graphs(name, Data, colors, lines types, markers types)
%
% Note: Still need to be fully commented.
% -------------------------------------------------------------------------
classdef Graphs < matlab.mixin.Copyable
    %% Properties
    properties
        % Graph properties
        name
        Data
        nbFigs
        figList
        axesList
        linesList
        currentFigure % version <2019b
        currentAxes
        colors
        lineType
        markerType
    
        % Parameter names
        xParam
        colParam
        subFigParam
        figParam
        lineParam
        markerParam
        
        % Options
        saveOptionPng
        saveOptionPdf
        saveOptionFig
        outputPath
        xScale
        yScale
        windowDimensions
        lineWidth
        fontSize
        gridOption
        autoscaleOption
        
        % Data
        x
        y
        mx
        Mx
        my
        My
        index
    end
    methods
        %% Constructor
        % g = Graphs()
        % g = Graphs(name)
        % g = Graphs(name, Data)
        % g = Graphs(name, Data, colors, lines types, markers types)
        % -----------------------------------------------------------------------------------------------
        % Instantiate a Graphs object.
        function self = Graphs(varargin)
            self.nbFigs = 0;
            self.saveOptionPng = 0;
            self.saveOptionPdf = 0;
            self.saveOptionFig = 0;
            self.outputPath = '';
            self.setWindowSize('screensize');
            self.lineWidth = 2.5;
            self.fontSize = 24;
            self.gridOption = false;
            self.autoscaleOption = true;
            self.linesList = {};
            switch nargin
                case 0 %Graphs()
                case 1 %Graphs(name)
                    if ~(isstring(varargin{1})||ischar((varargin{1})))
                        error('Error. \n First input must be a string, not a %s.',class(varargin{1}))
                    end
                    self.name = varargin{1};
                case 2 %Graphs(name, data)
                    if ~(isstring(varargin{1})||ischar((varargin{1})))
                        error('Error. \n First input must be a string, not a %s.',class(varargin{1}))
                    end
                    self.name = varargin{1};
                    self.Data = varargin{2};
                case 5 %Graphs(name, data, colors, lines, markers)
                    if ~(isstring(varargin{1})||ischar((varargin{1})))
                        error('Error. \n First input must be a string, not a %s.',class(varargin{1}))
                    end
                    self.name = varargin{1};
                    self.Data = varargin{2};
                    self.colors = varargin{3};
                    self.lineType = varargin{4};
                    self.markerType = varargin{5};
                    self.xScale = 'lin';
                    self.yScale = 'lin';

                otherwise
                    error('Error. Invalid number of inputs.')
            end
        end



        %% Create figure(s)
        % g.createFigure(display the figure(s) or not, save the figure(s) or not, how the figure(s) are displayed, options)
        % -----------------------------------------------------------------------------------------------------------------
        % Create figure(s) from the Data.
        function createFigure(self, displayFigure, saveOption, figDisplay, patternG, varargin)
            % Get a list of all the options values
            options = [];
            for i = 1:length(varargin)
                if ~(isstring(varargin{i})||ischar((varargin{i})))
                    error(['Error. \n ' num2str(i) ' input must be a string, not a %s.'],class(varargin{1}))
                end
                options = [options ' ' varargin{i}];
            end

            % Get the Parameters related to each option
            self.xParam = self.Data.getParameter(self.Data.findparameter(varargin{1}));
            self.colParam = self.Data.getParameter(self.Data.findparameter(varargin{2}));
            self.subFigParam = self.Data.getParameter(self.Data.findparameter(varargin{3}));
            self.figParam = self.Data.getParameter(self.Data.findparameter(varargin{4}));
            self.lineParam = self.Data.getParameter(self.Data.findparameter(varargin{5}));
            self.markerParam = self.Data.getParameter(self.Data.findparameter(varargin{6}));

            % Get the number of values for each option Parameter
            L_X = length(self.xParam.values);
            L_C = length(self.colParam.values);
            L_SF = length(self.subFigParam.values);
            L_F = length(self.figParam.values);
            L_L = length(self.lineParam.values);
            L_M = length(self.markerParam.values);


            if(L_SF < 1) % There is always at least 1 subfigure.
                L_SF = 1;
            end
            sf_size = ceil(sqrt(L_SF));
            % There should always be at least 1 figure.
            if(strcmp(figDisplay, 'merged') || ((L_F < 1) && strcmp(figDisplay, 'separate')))

                L_F = 1;
                %else
                %    error('Error. Value of figDisplay unsupported.')
            end

            % For each figure
            for f = 1:L_F
                self.nbFigs = self.nbFigs +1;
                % Create a figure
                self.figList{self.nbFigs} =  figure('Name',['Figure ' self.name ' ' num2str(self.nbFigs) ': ' options ], 'PaperType','A4',...
                    'PaperOrientation','landscape','NumberTitle','off',...'PaperPosition',[0 0 1 1],
                    'Position', self.windowDimensions,...
                    'visible',displayFigure... Position auf Bildschirm)
                    );

                % For each subfigure
                for sf = 1:L_SF
                    % Create a subfigure
                    if(isempty(patternG))
                        order = [1:8 14:15];%L_SF;
                        sP1 = sf_size;
                        sP2 = sf_size;
                    else
                        idx = self.Data.findparameter(self.subFigParam.name);
                        if(~isnan(idx))
                            val = unique(self.Data.table(:,idx+1));


                            %order = zeros(size(val));
                            [~, order] = ismember(val,reshape(patternG.',[],1));
                        else
                            order = 1;
                        end
                        sP1 = size(patternG,1);
                        sP2 = size(patternG,2);

                    end
                    if(~verLessThan('matlab','9.7') || (order(sf)> 0))
                        subPlot{self.nbFigs, sf} = subplot(sP1, sP2, order(sf), 'Parent', self.figList{self.nbFigs},...
                            'YScale', self.yScale,...
                            'XScale', self.xScale);
                        box(subPlot{self.nbFigs, sf},'on');
                        hold(subPlot{self.nbFigs, sf},'all');

                        % SubFigure display
                        if(~verLessThan('matlab','9.7'))
                            xlabel(append(self.xParam.symbol, ' (', self.xParam.unit, ')'),'fontsize',self.fontSize,'fontname','times','interpreter','latex');
                            ylabel(append(self.Data.symbol, ' (', self.Data.unit, ')'), 'fontsize',self.fontSize, 'fontname', 'times', 'interpreter', 'latex');
                        else
                            xlabel(join([self.xParam.symbol, ' (', self.xParam.unit, ')']),'fontsize',self.fontSize,'fontname','times','interpreter','latex');
                            ylabel(join([self.Data.symbol, ' (', self.Data.unit, ')']), 'fontsize',self.fontSize, 'fontname', 'times', 'interpreter', 'latex');
                        end
                        set(gca, 'fontsize', round(self.fontSize/sqrt(sf_size)), 'fontname', 'Times');
                        if(self.gridOption)
                            grid on
                            grid minor
                        else
                            grid off
                        end

                        % Loop over the lines to plot
                        % varargin{1} is for x values (loop to ignore as a line is defined as a function of x values)
                        % varargin{3} is for subfigure parameter (loop to ignore as we are currently plotting in that specific subfigure)
                        % varargin{4} is for figure parameter (loop to ignore as we are currently plotting in that specific figure)
                        if(strcmp(figDisplay, 'separate'))
                            Loop(1, self.rangeLoop([self.Data.findparameter(varargin{1}) self.Data.findparameter(varargin{3}) self.Data.findparameter(varargin{4})],...
                                {'NaN',num2str(sf),num2str(f)}), @self.plotData, figDisplay, self.xParam.values, self.Data.values, self.Data.filled,...
                                'LineWidth', self.lineWidth, 'Parent',subPlot{self.nbFigs, sf},...
                                'HandleVisibility','on');
                        else
                            Loop(1, self.rangeLoop([self.Data.findparameter(varargin{1}) self.Data.findparameter(varargin{3})],...
                                {'NaN',num2str(sf)}), @self.plotData, figDisplay, self.xParam.values, self.Data.values, self.Data.filled,...
                                'LineWidth',  self.lineWidth, 'Parent',subPlot{self.nbFigs, sf},...
                                'HandleVisibility','on');
                        end

                        % Add title to the subfigure
                        if(~strcmp(self.subFigParam.name, 'none'))
                            if(2019 <= [cellfun(@str2num,regexp(version('-release'),'\d+','match'))])
                                title(append(self.subFigParam.name, ' ', num2str(self.subFigParam.values(sf)), self.subFigParam.unit),'fontsize',round(self.fontSize/power(sP1,1/4)*3/4),'fontname','times','interpreter','latex');
                            else
                                title(join([self.subFigParam.name, ' ', num2str(self.subFigParam.values(sf)), self.subFigParam.unit]),'fontsize',round(self.fontSize/power(sP1,1/4)*3/4),'fontname','times','interpreter','latex');
                            end
                        end
                        if(self.autoscaleOption)
                            axis([min(self.xParam.values) max(self.xParam.values) min(self.Data.table(:,1)) max(self.Data.table(:,1))]);
                            %axis([-2 1 -0.75 0.25]);
                        end
                    end
                    self.axesList{f}(sf) = subPlot{self.nbFigs, sf};
                end

                % Create a legend
                lgd_gca = gca;
                [lgd_unique, lgd_pos] = unique({lgd_gca.Children.DisplayName});

                lgd = legend(lgd_gca.Children(sort(lgd_pos, 'descend')));
                set(lgd,'FontSize',round(self.fontSize*3/4), 'Position', [0.95 0.45 0.02 0.15], 'fontname', 'times', 'interpreter','latex');

                % Create a title for the figure
                titleText = '';
                for k = ndims(self.Data.values)+1:length(self.Data.parameters)
                    if(~isnan(self.Data.parameters{k}.values(1)))
                        s = regexp(self.Data.parameters{k}.symbol,'(\<\$)+\D+(\$)+|\w+','match');
                        if(~verLessThan('matlab','9.7'))
                            titleText = append(titleText, ' ', s{end}, ' ',num2str(self.Data.parameters{k}.values(1)), self.Data.parameters{k}.unit) ;
                        else
                            titleText = join([titleText, ' ', s{end}, ' ',num2str(self.Data.parameters{k}.values(1)), self.Data.parameters{k}.unit]) ;
                        end
                    end
                end

                if(strcmp(figDisplay, 'separate')&&(~strcmp(self.figParam.name, 'none')))
                    if(~verLessThan('matlab','9.7'))

                        sgtitle(append(self.figParam.name, " ", num2str(self.figParam.values(f)), self.figParam.unit, " ", titleText),'fontsize',self.fontSize,'fontname','times','interpreter','latex');
                    else
                        a = axes;
                        t1 = title(strcat(self.figParam.name, " ", num2str(self.figParam.values(f)), self.figParam.unit, " ", titleText),'fontsize',self.fontSize,'fontname','times','interpreter','latex');
                        a.Visible = 'off';
                        t1.Visible = 'on';
                    end
                else
                    if(~verLessThan('matlab','9.7'))

                        sgtitle(titleText,'fontsize',self.fontSize,'fontname','times','interpreter','latex');
                    else
                        a = axes;
                        t1 = title(titleText,'fontsize',self.fontSize,'fontname','times','interpreter','latex');
                        a.Visible = 'off';
                        t1.Visible = 'on';
                    end
                end

                % Save figure
                if(strcmp(saveOption, 'on'))
                    if isempty(self.figParam.values)
                        self.figParam.values = NaN;
                    end
                    date = num2str(round(datenum(datetime('now'))*1e6));
                    if(self.saveOptionFig)
                        mkdir(self.outputPath,'NaLyserFig');
                        saveas(self.figList{self.nbFigs},join([self.outputPath 'NaLyserFig\' self.name num2str(self.nbFigs) '_' figDisplay '_' self.figParam.name num2str(self.figParam.values(f)) '_' date '.fig'],""), 'fig');
                    end
                    if(self.saveOptionPdf)
                        mkdir(self.outputPath,'NaLyserPdf');
                        saveas(self.figList{self.nbFigs},join([self.outputPath 'NaLyserPdf\' self.name num2str(self.nbFigs) '_' figDisplay '_' self.figParam.name num2str(self.figParam.values(f)) '_' date '.pdf'],""), 'pdf');
                    end
                    if(self.saveOptionPng)
                        mkdir(self.outputPath,'NaLyserPng');
                        print(self.figList{self.nbFigs}, '-dpng',join([self.outputPath 'NaLyserPng\' self.name num2str(self.nbFigs) '_' figDisplay '_' self.figParam.name num2str(self.figParam.values(f)) '_' date '.png'],""));
                    end

                end
            end
        end



        %% Get the ranges of iteration values that a loop has to go over
        % g.rangeLoop(Parameter Positions to ignore, values to set for those Parameters)
        % -----------------------------------------------------------------------------------------------------------------
        % Create figure(s) from the Data.
        function r = rangeLoop(self, varargin)
            % Get the range of iteration values that a loop has to go over
            % for each Parameter.
            r = {};
            for n = 1:length(self.Data.parameters)
                r{end+1} = ['1:' num2str(length(self.Data.parameters{n}.values))];
            end

            % Remove loops to ignore by setting a single value to them.
            if(length(varargin) > 1)
                pos = varargin{1};
                mod = varargin{2};

                for m = 1:length(varargin{1})
                    if(~isnan(pos(m)))
                        r{pos(m)} = mod{m};
                    end
                end
            end
        end



        %% Plot the data
        function plotData(self, figDisplay, varargin)
            X = varargin{1};
            Y = varargin{2};
            L = varargin{3};
            narg = 6;
            properties = [''];
            i_x = 0;
            i_col = 0;
            i_fig = 0;
            i_line = 0;
            i_marker = 0;

            for i = 1:length(self.Data.parameters)

                if(strcmp(self.colParam.name, self.Data.parameters{i}.name)||strcmp(self.lineParam.name, self.Data.parameters{i}.name)||strcmp(self.markerParam.name, self.Data.parameters{i}.name)||strcmp(self.figParam.name, self.Data.parameters{i}.name))
                    if(~(strcmp(figDisplay, 'separate') && strcmp(self.figParam.name, self.Data.parameters{i}.name)))
                        s = regexp(self.Data.parameters{i}.symbol,'(\<\$)+\D+(\$)+|\w+','match');
                        if(~verLessThan('matlab','9.7'))
                            properties = append(properties, " ", s{end}, " ", num2str(self.Data.parameters{i}.values(varargin{3+narg+i})), self.Data.parameters{i}.unit);
                        else
                            properties = join([properties, " ", s{end}, " ", num2str(self.Data.parameters{i}.values(varargin{3+narg+i})), self.Data.parameters{i}.unit],"");

                        end
                    end
                end

                if(strcmp(self.xParam.name, self.Data.parameters{i}.name))
                    i_x = i;
                end
                if(strcmp(self.colParam.name, self.Data.parameters{i}.name))
                    i_col = i;
                end
                if(strcmp(self.figParam.name, self.Data.parameters{i}.name))
                    i_fig = i;
                end
                if(strcmp(self.lineParam.name, self.Data.parameters{i}.name))
                    i_line = i;
                end
                if(strcmp(self.markerParam.name, self.Data.parameters{i}.name))
                    i_marker = i;
                end
            end

            if(length(self.linesList) < self.nbFigs)
                self.linesList{self.nbFigs} = {};
            end

            plotY = squeeze(Y(varargin{(4+narg):end})).';
            idx = (squeeze(L(varargin{(4+narg):end})) ~= 0).';

            % Plot the data
            self.linesList{self.nbFigs}{end+1} = plot(X(idx), plotY(idx),varargin{4:(4+narg-1)},...
                'DisplayName', properties);

            if(i_col)
                self.linesList{self.nbFigs}{end}.Color = self.colors(varargin{3+narg+i_col},:);
            end
            if((~strcmp(figDisplay, 'separate')) && i_fig && ((i_col && (varargin{3+narg+i_col} == length(self.colParam.values)))||(i_line && (varargin{3+narg+i_line} == length(self.lineParam.values)))||(i_marker && (varargin{3+narg+i_marker} == length(self.markerParam.values)))))
                i_param = (3+narg+1):length(varargin);
                indices = {varargin{i_param(1:i_x-1)}, 1, varargin{i_param(i_x+1:length(i_param))}};
                %text(X(1)*(1), Y(indices{:})*(0.95), [regexp(self.figParam.symbol,'(\$).+(\$)','match')  num2str(self.Data.parameters{i_fig}.values(varargin{3+narg+i_fig})) self.figParam.unit],'interpreter','latex');
            end
            if(i_line)
                self.linesList{self.nbFigs}{end}.LineStyle = self.lineType{varargin{3+narg+i_line}};
            end
            if(i_marker)
                self.linesList{self.nbFigs}{end}.Marker = self.markerType{varargin{3+narg+i_marker}};
            end

        end


        
        %% Modify the options of the Graphs
        function modifyOptions(self,varargin)
            for v = 1:length(varargin)
                if((isstring(varargin{v})||ischar((varargin{v}))))
                    if(strcmp(varargin{v}, 'png'))
                        if((v ~= length(varargin)) && isnumeric(varargin{v+1}))
                            self.saveOptionPng = varargin{v+1};
                        end
                    end
                    if(strcmp(varargin{v}, 'pdf'))
                        if((v ~= length(varargin)) && isnumeric(varargin{v+1}))
                            self.saveOptionPdf = varargin{v+1};
                        end
                    end
                    if(strcmp(varargin{v}, 'fig'))
                        if((v ~= length(varargin)) && isnumeric(varargin{v+1}))
                            self.saveOptionFig = varargin{v+1};
                        end
                    end
                    if(strcmp(varargin{v}, 'outputPath'))
                        if((v ~= length(varargin)) && ((isstring(varargin{v+1})||ischar((varargin{v+1})))))
                            self.outputPath = varargin{v+1};
                        end
                    end
                    if(strcmp(varargin{v}, 'XScale'))
                        if((v ~= length(varargin)) && ((isstring(varargin{v+1})||ischar((varargin{v+1})))))
                            self.xScale = varargin{v+1};
                        end
                    end
                    if(strcmp(varargin{v}, 'YScale'))
                        if((v ~= length(varargin)) && ((isstring(varargin{v+1})||ischar((varargin{v+1})))))
                            self.yScale = varargin{v+1};
                        end
                    end
                    if(strcmp(varargin{v}, 'lineWidth'))
                        if((v ~= length(varargin)) && isnumeric(varargin{v+1}))
                            self.lineWidth = varargin{v+1};
                        end
                    end
                    if(strcmp(varargin{v}, 'fontSize'))
                        if((v ~= length(varargin)) && isnumeric(varargin{v+1}))
                            self.fontSize = varargin{v+1};
                        end
                    end
                    if(strcmp(varargin{v}, 'gridOption'))
                        if((v ~= length(varargin)) && islogical(varargin{v+1}))
                            self.gridOption = varargin{v+1};
                        end
                    end
                    if(strcmp(varargin{v}, 'autoscaleOption'))
                        if((v ~= length(varargin)) && islogical(varargin{v+1}))
                            self.autoscaleOption = varargin{v+1};
                        end
                    end
                end
            end
        end



        %% Define the size of the figure window
        function setWindowSize(self,option)
            set(0,'units','pixels');
            tmpf = figure('Units','pixels','Visible','on'); % open a figure, save the handles to a variable
            tmpf.WindowState = 'maximized'; % maximize the figure window
            waitfor(tmpf,'InnerPosition');
            Pix_SS = tmpf.InnerPosition;
            delete(tmpf);
            if(strcmp(option, 'screensize'))
                self.windowDimensions = Pix_SS;
            elseif(strcmp(option, 'halfwidth'))
                self.windowDimensions = [Pix_SS(1:2) Pix_SS(3)/2 Pix_SS(4)];
            elseif(strcmp(option, 'halfheight'))
                self.windowDimensions = [Pix_SS(1:3) Pix_SS(4)/2];
            elseif(strcmp(option, 'square'))
                if(Pix_SS(3) > Pix_SS(4))
                    self.windowDimensions = [Pix_SS(1:2) Pix_SS(4) Pix_SS(4)];
                else
                    self.windowDimensions = [Pix_SS(1:2) Pix_SS(3) Pix_SS(3)];
                end
            elseif(strcmp(option, 'rectangle'))
                GoldenRatio = 1.618033988749;
                if(Pix_SS(3) > Pix_SS(4) * GoldenRatio)
                    self.windowDimensions = [Pix_SS(1:2) round(Pix_SS(4)*GoldenRatio) Pix_SS(4)];
                else
                    self.windowDimensions = [Pix_SS(1:2) Pix_SS(3) round(Pix_SS(3)/GoldenRatio)];
                end
            elseif(strcmp(option, 'doublesquare'))
                if(Pix_SS(3) > Pix_SS(4) * 2)
                    self.windowDimensions = [Pix_SS(1:2) Pix_SS(4)*2 Pix_SS(4)];
                else
                    self.windowDimensions = [Pix_SS(1:2) Pix_SS(3) round(Pix_SS(3)/2)];
                end
            elseif(strcmp(option, 'ISO A'))
                if(Pix_SS(3) > Pix_SS(4) * sqrt(2))
                    self.windowDimensions = [Pix_SS(1:2) round(Pix_SS(4)*sqrt(2)) Pix_SS(4)];
                else
                    self.windowDimensions = [Pix_SS(1:2) Pix_SS(3) round(Pix_SS(3)/sqrt(2))];
                end
            else
                Pix_Dim = str2num(option);
                if(length(Pix_Dim) == 2)
                    self.windowDimensions = [Pix_SS(1:2) Pix_Dim(1:2)];
                else
                    disp('Error. Windows dimensions are invalid.')
                    self.windowDimensions = Pix_SS;
                end
            end
        end


        
        %% I forgot the purpose of that
        function [X,Y] = horizontalLine(self, figNum)
            components = get(Charac_G.figList{figNum}, 'Children');
            L = length(components.Children);
            for child = 1:L
                X(:, child) = components.Children(child).XData;
                Y(:, child) = components.Children(child).YData;

            end
        end



        %% Was to add a column to the Data table, but is most likely unusable for now
        function expandedData = expandData(self, expandFunction, varargin)

            % Copy data
            expandedData =  self.Data;
            expandedData.table(:,end+1) =  expandedData.table(:,end);
            expandedData.parameters{end+1} = Parameters('X', '$|\mathbf{R}|$', ' ', unique(expandedData.table(:,end-1)));

            % Get indices
            iC =  expandedData.findparameter("Channel");
            iG = expandedData.findparameter("Gate");
            [a,b,c] = unique(round(expandedData.table(:,iG)));

            % For gate
            for posG = 1:length(a)
                % Positions in table using that Gate
                tablePosG = find(c == posG);
                % Channels for that gate
                G_Channel = expandedData.table(tablePosG, iC);

                % Distances from that gate
                dist_str = expandFunction(a(posG),varargin{1});
                [d, e, f] = unique(G_Channel);
                %  For distance
                for d_name = 1:length(dist_str.name)
                    name = dist_str.name(d_name);
                    expandedData.table(tablePosG(find(G_Channel == name)),end-1) = dist_str.distance(d_name);
                end
            end
            % Remove channels
            expandedData.table(:,iG) = [];
            expandedData.parameters(iG) = [];
            %expandedData.table([find(expandedData.table(:,iC) == 13) ;find(expandedData.table(:,iC) == 14) ;find(expandedData.table(:,iC) == 15) ;find(expandedData.table(:,iC) == 16)],:) = [];
            % Create array
            expandedData.convertTable2Values();
        end
    end


end