classdef GraphAnalyser < matlab.mixin.Copyable
    properties
        className   % Name of the class of the object
        g           % Graph object
        Pix_SS      % Screen size in pixel
        Pix_UIS     % Graphical User Interface size in pixel
        Pix_PS      % Upper right panel size in pixel
        uiFig       % GUI
        uiPan       % Panels of the GUI
        ax          % Axes of the figure being analysed

        outputFigure    % Figure collecting the results
        outputAxesList  % Axes of that said figure

        x       % x values
        y       % y values
        mx      % minimum x values of each box formed by two points
        Mx      % Maximum x values of each box formed by two points
        my      % minimum y values of each box formed by two points
        My      % Maximum y values of each box formed by two points
        index   % Index
        color   % Color of each curves
        displayName % Display names of each curves (contains parameters data)
    end
    methods
        %% Constructor
        function self = GraphAnalyser(varargin)
            self.className = 'Graph Analyser';
            switch nargin
                case 0 %GraphAnalyser()
                case 1 %GraphAnalyser(Graphs)
                    self.g = varargin{1};
                otherwise
                    error('Error. Invalid number of inputs.')
            end

            % Get dimension of the screen
            self.Pix_SS = get(0,'screensize');

            % Create popup window
            self.Pix_UIS = self.getSlot(1, 1, 1, self.Pix_SS, 0.9);
            self.uiFig = uifigure('Position', self.Pix_UIS,'Name',class(self));

            % Create upper panel
            self.uiPan{1} = uipanel('Position',self.getSlot(1, 2, 1, [0 self.Pix_UIS(4)*2/3 self.Pix_UIS(3) self.Pix_UIS(4)*1/3], 1),'Parent', self.uiFig);

            for i = 1:self.g.nbFigs
                for a = 1:length(self.g.axesList{i})
                    for c = 1:length(self.g.axesList{i}(a).Children)
                        self.g.axesList{i}(a).Children(c).Tag = 'original';
                    end
                    hold(self.g.axesList{i}(a),'on');
                    grid(self.g.axesList{i}(a),'on');
                    grid(self.g.axesList{i}(a),'minor');
                end
            end

            % Create lower panel
            self.uiPan{2} = uipanel(self.uiFig,'Position',self.getSlot(1, 1, 1, self.Pix_UIS .* [0 0 1 2/3], 1),'Parent',self.uiFig);

            if(~verLessThan('matlab','9.7'))
                self.ax{2} = axes(self.uiPan{2});
            else
                self.ax{2} = uiaxes(self.uiPan{2});
                set(self.ax{2},'Units',self.uiPan{2}.Units,'Position',self.uiPan{2}.Position)
            end
            hold(self.ax{2},'on');
            grid(self.ax{2},'on');
            grid(self.ax{2},'minor');
            self.uiPan{2}.Children.XLabel.String = 'Unknown';
            self.uiPan{2}.Children.YLabel.String = 'X';

            % Create upper right panel
            self.Pix_PS = self.getSlot(1, 2, 2, [0 self.Pix_UIS(4)*2/3 self.Pix_UIS(3) self.Pix_UIS(4)*1/3],1);
            self.uiPan{3} = uipanel('Position', self.Pix_PS,'Parent', self.uiFig);
        end



        %% Get the position of slots available for buttons, dropdown,...
        function slot = getSlot(self,rows, columns, position, screen, ratio)
            dx = screen(3)/columns;
            dy = screen(4)/rows;
            x = screen(1) + (0:dx:screen(3)-dx);
            y = screen(2) + (0:dy:screen(4)-dy);
            [row,col] = ind2sub([rows columns], position);
            dx_slot = ratio * dx;
            dy_slot = ratio * dy;
            x_slot = x(col) + (dx-dx_slot)/2;
            y_slot = y(row) + (dy-dy_slot)/2;
            slot = [x_slot y_slot dx_slot dy_slot];
        end



        %% Create output figure and hide it for now
        function createFigure(self)
            i = matches(self.dd{1}.Items, self.dd{1}.Value);
            self.outputFigure = figure('Name',join(['Figure ' self.g.name ' ' num2str(i) ': ' self.className '-' num2str(round(datenum(datetime('now'))*1e6));]), 'PaperType','A4',...
                'PaperOrientation','landscape','NumberTitle','off',...'PaperPosition',[0 0 1 1],
                'Position', [1 1 1900 1280],...
                'visible','off'... Position auf Bildschirm)
                );

            lenAxesList2 = length(self.g.axesList{i});
            for j = 1:lenAxesList2

                self.outputAxesList{j} = copyobj(self.g.axesList{i}(j),self.outputFigure);
                cla(self.outputAxesList{j});
            end

        end



        %% Collect the data results and place it in the output figure
        function collect(self, btn)
            set(self.outputFigure, 'Visible', 'on')
            outFigureAxes = findobj(self.outputFigure.Children,'Type','Axes');
            subfigureNb = contains(cellfun(@(x) x.String, {outFigureAxes.Title}, 'UniformOutput', false), extractAfter(self.dd{4}.Value, '> '));
            positionSF = get(outFigureAxes(subfigureNb), 'position');
            titleSF.String = outFigureAxes(subfigureNb).Title.String;
            titleSF.FontSize = outFigureAxes(subfigureNb).Title.FontSize;
            titleSF.FontWeight = outFigureAxes(subfigureNb).Title.FontWeight;
            titleSF.FontName = outFigureAxes(subfigureNb).Title.FontName;
            titleSF.Interpreter = outFigureAxes(subfigureNb).Title.Interpreter;
            outFigureAxes(subfigureNb).Tag = 'Obsolete';

            self.outputAxesList{subfigureNb} = copyobj(self.uiPan{2}.Children, self.outputFigure);
            outAxes = findobj(self.outputAxesList{subfigureNb},'Type','Axes'); 
            outAxes.Title.String = titleSF.String;
            outAxes.Title.FontSize = titleSF.FontSize;
            outAxes.Title.FontWeight = titleSF.FontWeight;
            outAxes.Title.FontName = titleSF.FontName;
            outAxes.Title.Interpreter = titleSF.Interpreter;

            for i = 1:length(outFigureAxes)
                if(matches(outFigureAxes(i).Tag, 'Obsolete'))
                    delete(outFigureAxes(i));
                    break;
                end
            end
            set(outAxes, 'Position', positionSF);
        end



        %% findInMatrix(matrix, offset, coordinates)
        % -----------------------------------------
        % Find an element in a N-dimensional matrix.
        function findInMatrix(self, data, offset, varargin)
            v = ones(size(data,1),1);
            for(i=1:length(varargin))
                v = v & [data(:,offset+i) == varargin{i}];
            end
            disp(find(v));
        end

        

        %% getChildrenFields(axes)
        % ----------------------------------------------
        % Get fields of Children of a given axes set.
        function [xC,yC,colorC,DisplayNameC] = getChildrenFields(self,ax)
            xC = vertcat(ax.Children(:).XData);
            yC = vertcat(ax.Children(:).YData);
            colorC = vertcat(ax.Children(:).Color);
            DisplayNameC = {ax.Children(:).DisplayName};
            if (length(DisplayNameC) ~= size(xC,1))
                DisplayNameC = cellstr(num2str(ones(size(xC,2),1).*[1:size(xC,2)]));
            end
        end



        %% Select the figure to analyse
        function selectFigure(self, i,j)
            if(~verLessThan('matlab','9.7'))
                delete(self.uiPan{1}.Children);
                self.g.currentAxes = copyobj(self.g.axesList{i}(j),self.uiPan{1});
                set(self.g.currentAxes, 'Position', self.getSlot(1, 1, 1, [0 0 1 1], 0.6));
            else
                self.uiPan{1}.Children = [];
                tmp = self.g.axesList{i}(j);

                self.g.currentAxes = uiaxes(self.uiPan{1});

                %copyobj does not work is this case for Matlab 2018
                set(self.g.currentAxes,'Units',uiPan{1}.Units,'Position',[0.15 0.15 0.7 0.7],...
                    'ALim', tmp.ALim, 'ALimMode', tmp.ALimMode, 'AlphaScale', tmp.AlphaScale,...
                    'Alphamap', tmp.Alphamap, 'AmbientLightColor', tmp.AmbientLightColor, 'Box', tmp.Box,...
                    'BoxStyle', tmp.BoxStyle, 'BusyAction', tmp.BusyAction, 'ButtonDownFcn', tmp.ButtonDownFcn, 'CLim', tmp.CLim,...
                    'CLimMode', tmp.CLimMode, 'CameraPosition', tmp.CameraPosition, 'CameraPositionMode', tmp.CameraPositionMode, 'CameraTarget', tmp.CameraTarget,...
                    'CameraTargetMode', tmp.CameraTargetMode, 'CameraUpVector', tmp.CameraUpVector, 'CameraUpVectorMode', tmp.CameraUpVectorMode, 'CameraViewAngle', tmp.CameraViewAngle,...
                    'CameraViewAngleMode', tmp.CameraViewAngleMode, 'Clipping', tmp.Clipping, 'ClippingStyle', tmp.ClippingStyle,...
                    'Color', tmp.Color, 'ColorOrder', tmp.ColorOrder, 'ColorOrderIndex', tmp.ColorOrderIndex, 'ColorScale', tmp.ColorScale,...
                    'Colormap', tmp.Colormap, 'CreateFcn', tmp.CreateFcn, 'DataAspectRatio', tmp.DataAspectRatio, 'DataAspectRatioMode', tmp.DataAspectRatioMode,...
                    'DeleteFcn', tmp.DeleteFcn, 'FontAngle', tmp.FontAngle, 'FontName', tmp.FontName, 'FontSize', tmp.FontSize,...
                    'FontUnits', tmp.FontUnits, 'FontWeight', tmp.FontWeight, 'GridAlpha', tmp.GridAlpha,...
                    'GridAlphaMode', tmp.GridAlphaMode, 'GridColor', tmp.GridColor, 'GridColorMode', tmp.GridColorMode, 'GridLineStyle', tmp.GridLineStyle,...
                    'HandleVisibility', tmp.HandleVisibility, 'Interruptible', tmp.Interruptible, 'LabelFontSizeMultiplier', tmp.LabelFontSizeMultiplier, 'Layer', tmp.Layer,...
                    'LineStyleOrder', tmp.LineStyleOrder, 'LineStyleOrderIndex', tmp.LineStyleOrderIndex, 'LineWidth', tmp.LineWidth,...
                    'MinorGridAlpha', tmp.MinorGridAlpha, 'MinorGridAlphaMode', tmp.MinorGridAlphaMode, 'MinorGridColor', tmp.MinorGridColor, 'MinorGridColorMode', tmp.MinorGridColorMode,...
                    'MinorGridLineStyle', tmp.MinorGridLineStyle, 'NextPlot', tmp.NextPlot,...
                    'Tag', tmp.Tag, 'UserData', tmp.UserData, 'Visible', tmp.Visible,...
                    'Projection', tmp.Projection, 'TickDir', tmp.TickDir,'TickDirMode', tmp.TickDirMode,'TickLabelInterpreter', tmp.TickLabelInterpreter,'TickLength', tmp.TickLength,...
                    'TitleFontWeight', tmp.TitleFontWeight,...
                    'XAxisLocation', tmp.XAxisLocation,'XColor', tmp.XColor,'XColorMode', tmp.XColorMode,'XDir', tmp.XDir,...
                    'XGrid', tmp.XGrid, 'XLim', tmp.XLim,'XLimMode', tmp.XLimMode,...
                    'XMinorGrid', tmp.XMinorGrid,'XMinorTick', tmp.XMinorTick,'XScale', tmp.XScale,'XTick', tmp.XTick,...
                    'XTickLabel', tmp.XTickLabel,'XTickLabelMode', tmp.XTickLabelMode,'XTickLabelRotation', tmp.XTickLabelRotation,'XTickMode', tmp.XTickMode,...
                    'YAxisLocation', tmp.YAxisLocation,'YColor', tmp.YColor,'YColorMode', tmp.YColorMode,'YDir', tmp.YDir,...
                    'YGrid', tmp.YGrid, 'YLim', tmp.YLim,'YLimMode', tmp.YLimMode,...
                    'YMinorGrid', tmp.YMinorGrid,'YMinorTick', tmp.YMinorTick,'YScale', tmp.YScale,'YTick', tmp.YTick,...
                    'YTickLabel', tmp.YTickLabel,'YTickLabelMode', tmp.YTickLabelMode,'YTickLabelRotation', tmp.YTickLabelRotation,'YTickMode', tmp.YTickMode,...
                    'ZColor', tmp.ZColor,'ZColorMode', tmp.ZColorMode,'ZDir', tmp.ZDir,...
                    'ZGrid', tmp.ZGrid, 'ZLim', tmp.ZLim,'ZLimMode', tmp.ZLimMode,...
                    'ZMinorGrid', tmp.ZMinorGrid,'ZMinorTick', tmp.ZMinorTick,'ZScale', tmp.ZScale,'ZTick', tmp.ZTick,...
                    'ZTickLabel', tmp.ZTickLabel,'ZTickLabelMode', tmp.ZTickLabelMode,'ZTickLabelRotation', tmp.ZTickLabelRotation,'ZTickMode', tmp.ZTickMode);
                axis(self.g.currentAxes, [tmp.XAxis.Limits tmp.YAxis.Limits])
                xlabel(self.g.currentAxes,tmp.XLabel.String,'interpreter','latex');
                ylabel(self.g.currentAxes,tmp.YLabel.String);
                grid minor;
                for i = 1:length(tmp.Children)
                    lines(i) = copyobj( tmp.Children(i), self.g.currentAxes);
                end
            end
            self.ax{2}.YLabel.Interpreter = 'latex';
            if(strcmp(self.dd{2}.Value, 'Set Y'))
                self.ax{2}.YLabel.String = self.g.currentAxes.XLabel.String;
            else
                self.ax{2}.YLabel.String = self.g.currentAxes.YLabel.String;
            end

            % Update the second pannel
            [self.x,self.y,self.color,self.displayName] = self.getChildrenFields(self.g.currentAxes);
        end
    end
end

