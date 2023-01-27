% Intersector
% -------------------------------------------------------------------------
% A class that creates an interface that will analyse a figure and collect data
% related to the intersection of curves.
%
% Instantiate with: i = Intersector()
% -------------------------------------------------------------------------
classdef Intersector < GraphAnalyser
    properties
        spinnerLabel
        spinner
        ddLabel
        dd
        buttonLabel
        button

        cData % Lower panel data
        reg   % Regressor

    end
    methods
        %% Constructor
        function self = Intersector(varargin)

            self@GraphAnalyser(varargin{:});
            self.className = 'Intersector';
            % Create buttons and others
            r = 5;
            c = 6;

            % Labels
            self.spinnerLabel{1} = uilabel(self.uiPan{3});
            self.spinnerLabel{1}.HorizontalAlignment = 'right';
            self.spinnerLabel{1}.Position = self.getSlot(r, c, 8, self.Pix_PS .* [0 0 1 1], 0.9);
            self.spinnerLabel{1}.Text = 'Coordinate';
            self.spinnerLabel{1}.FontName = 'Times';
            self.spinnerLabel{1}.Interpreter= 'latex';

            self.ddLabel{3} = uilabel(self.uiPan{3});
            self.ddLabel{3}.HorizontalAlignment = 'right';
            self.ddLabel{3}.Position = self.getSlot(r, c, 7, self.Pix_PS .* [0 0 1 1], 0.9);
            self.ddLabel{3}.Text = 'Parameter X';
            self.ddLabel{3}.Interpreter = 'latex';

            self.ddLabel{4} = uilabel(self.uiPan{3});
            self.ddLabel{4}.HorizontalAlignment = 'right';
            self.ddLabel{4}.Position = self.getSlot(r, c, 18, self.Pix_PS .* [0 0 1 1], 0.9);
            self.ddLabel{4}.Text = 'Regression mode';
            self.ddLabel{4}.Interpreter = 'latex';

            % Figure list
            self.dd{1} = uidropdown(self.uiPan{3},...
                'Position',self.getSlot(r, c, 5, self.Pix_PS .* [0 0 1 1], 0.9),...
                'Items', cellfun(@(x) x.Name, self.g.figList, 'UniformOutput', false));

            % X/Y axis
            self.dd{2} = uidropdown(self.uiPan{3},...
                'Position',self.getSlot(r, c, 14, self.Pix_PS .* [0 0 1 1], 0.9),...
                'Items',[{'Set X'} {'Set Y'}], 'Value','Set Y');

            % Subfig list
            self.dd{4} = uidropdown(self.uiPan{3},...
                'Position',self.getSlot(r, c, 4, self.Pix_PS .* [0 0 1 1], 0.9),...
                'Items',cellfun(@(x) ['> ' x.String], {self.g.axesList{1}.Title}, 'UniformOutput', false));

            % Regression mode
            self.dd{5} = uidropdown(self.uiPan{3},...
                'Position',self.getSlot(r, c, 23, self.Pix_PS .* [0 0 1 1], 0.9),...
                'Items', {'Merged', 'Separate'});



            % Save button
            self.button{1} = uibutton(self.uiPan{3},...
                'Position',self.getSlot(r, c, 26, self.Pix_PS .* [0 0 1 1], 0.9),...
                'Text','Collect figure', 'ButtonPushedFcn', @(app, btn) self.collect(self.button{1}));

            self.button{2} = uibutton(self.uiPan{3},...
                'Position',self.getSlot(r, c, 27, self.Pix_PS .* [0 0 1 1], 0.9),...
                'Text','Inspect figure', 'ButtonPushedFcn', @(app,btn) self.inspect(self.button{2}));

            self.button{3} = uibutton(self.uiPan{3},...
                'Position',self.getSlot(r, c, 24, self.Pix_PS .* [0 0 1 1], 0.9),...
                'Text','Regression', 'ButtonPushedFcn', @(app,btn) self.regression(self.button{3}));

            self.selectFigure(1,1); %

            % Coordinate spinner
            self.spinner{1} = uispinner(self.uiPan{3});
            self.spinner{1}.Position = self.getSlot(r, c, 13, self.Pix_PS .* [0 0 1 1], 0.9);

            self.spinner{1}.Step = min(diff(self.g.currentAxes.YTick))/5; %

            % Get lines data
            [self.x,self.y,self.color,self.displayName] = self.getChildrenFields(self.g.currentAxes);

            % Parameter list dropdown
            try
                dd3Options = cellfun(@(x) regexp(regexp(x,'(\S+)','match'),'^[^\d+ -]+','match','once'), self.displayName,'UniformOutput',false);
                dd3Options = cellfun(@(x) x(~cellfun(@isempty,x)), dd3Options,'UniformOutput',false);
                dd3Options = dd3Options{find(cellfun(@length,dd3Options)==max(cellfun(@length,dd3Options)),1)};
                self.dd{3} = uidropdown(self.uiPan{3},...
                    'Position',self.getSlot(r, c, 12, self.Pix_PS .* [0 0 1 1], 0.9),...
                    'Items', dd3Options, 'Value',dd3Options{1});
                self.ddLabel{3}.Text = ['Parameter (' dd3Options{1} ')'];
            catch
                self.dd{3} = uidropdown(self.uiPan{3},...
                    'Position',self.getSlot(r, c, 12, self.Pix_PS .* [0 0 1 1], 0.9),...
                    'Items', {'Non specified'}, 'Value','Non specified');
                self.ddLabel{3}.Text = ['Parameter (?)'];
            end

            if(length(self.dd{3}.Items) <= 1)
                self.dd{5}.Value = {'Merged'};
            end
            self.reg = [];
            self.reg.UIFigure = [];

            self.createFigure();
        end



        %%  Launch the figure inspector on the lower panel figure
        function inspect(self,btn)
            FigureInspector(self.ax{2});
        end



        %% Apply a regression on the data of the lower panel figure
        function regression(self, btn)
            % Start regression
            self.reg = Regressor();
            if(strcmp(self.dd{2}.Value, 'Set Y'))
                valueIdx = 1;
            elseif(strcmp(self.dd{2}.Value, 'Set X'))
                valueIdx = 2;
            end

            if(matches(self.dd{5}.Value,"Merged"))
                self.reg.setPoints(self.cData.param(:,valueIdx), self.cData.param(:,4:end), self.cData.paramName{1});
            else
                for i = 1:length(self.dd{3}.Items)
                    if(matches(self.dd{3}.Items(i), self.dd{3}.Value))
                        pIdx = i;
                    else
                        npIdx = i;
                        [pValues, uniqueIdx, repeatIdx] = unique(self.cData.param(:, 3+i));
                    end
                end
                self.reg.setPoints(self.cData.param(repeatIdx == 1,valueIdx), self.cData.param(repeatIdx == 1,3+pIdx), self.cData.paramName{1}(pIdx));
                disp(join(["For ", self.cData.paramName{1}(npIdx), " = ", num2str(pValues(1)),":"],""))
            end
            self.reg.setConfirmFct(self, @(x, varargin) x.plotRegression(self.reg));
            self.reg.setFunctions();
        end



        %% Plot the regression results on the lower panel figure
        function plotRegression(self, reg)
            % Delete previous regression
            for k = length(self.ax{2}.Children):-1:1
                if(matches(self.ax{2}.Children(k).Tag, "regression"))
                    delete(self.ax{2}.Children(k));
                end
            end

            if(matches(self.dd{5}.Value,"Merged"))
                lI = length(self.dd{3}.Items);
                if(lI <= 1)
                    plot(self.ax{2},self.reg.pDisplay,self.reg.vDisplay, 'Color', 'k', 'LineStyle','-', 'Tag', 'regression');
                        
                else
                for i = 1:lI
                    if(~matches(self.dd{3}.Items(i), self.dd{3}.Value))
                        [pValues, uniqueIdx] = unique(self.cData.param(:, 3+i));
                        for j = 1:length(pValues)
                            disp(join(["Expression for ",self.dd{3}.Items(i),"=", num2str(pValues(j)),""],""))
                            [x,y] = reg.getProjection(self.dd{3}.Items(i), pValues(j));
                            plot(self.ax{2},x,y, 'Color', self.cData.color(self.cData.param(uniqueIdx(j),3),:), 'LineStyle',self.cData.line{self.cData.param(uniqueIdx(j),3)}, 'Tag', 'regression');
                        end

                    end
                end
                end
            else
                if(strcmp(self.dd{2}.Value, 'Set Y'))
                    valueIdx = 1;
                elseif(strcmp(self.dd{2}.Value, 'Set X'))
                    valueIdx = 2;
                end

                for i = 1:length(self.dd{3}.Items)
                    if(matches(self.dd{3}.Items(i), self.dd{3}.Value))
                        pIdx = i;
                    else
                        npIdx = i;
                        [pValues, uniqueIdx, repeatIdx] = unique(self.cData.param(:, 3+i));
                    end
                end
                plot(self.ax{2}, reg.pDisplay,reg.vDisplay, 'Color', self.cData.color(self.cData.param(uniqueIdx(1),3),:), 'LineStyle',self.cData.line{self.cData.param(uniqueIdx(1),3)}, 'Tag', 'regression');
                for j = 2:length(pValues)
                    reg.setPoints(self.cData.param(repeatIdx == j,valueIdx), self.cData.param(repeatIdx == j,3+pIdx), self.cData.paramName{1});
                    disp(join(["For ", self.cData.paramName{1}(npIdx), " = ", num2str(pValues(j)),":"],""))
                    reg.regression();
                    reg.displayPlot();
                    plot(self.ax{2}, reg.pDisplay,reg.vDisplay, 'Color', self.cData.color(self.cData.param(uniqueIdx(j),3),:), 'LineStyle',self.cData.line{self.cData.param(uniqueIdx(j),3)}, 'Tag', 'regression');

                end
            end
        end 
        
        
        
        %% Close the regression window since another algorithm was selected
        function selectRegressionMode(self, dd)
            if(sum(contains(fieldnames(self.reg), 'UIFigure')))
                delete(self.reg.UIFigure);
            end
        end



        %% Update the figure
        function update(self, y, fig)
            if(strcmp(self.dd{2}.Value, 'Set Y'))
                self.updateY(y);
            elseif(strcmp(self.dd{2}.Value, 'Set X'))
                self.updateX(y);
            end
            self.updateFig(fig);


            % Adjust zoom
            p = cell2mat(cellfun(@str2num,cellfun(@(x) char(regexp(x,'([+-])?\d+(.\d+)?','match')),self.displayName,'UniformOutput',false),'UniformOutput',false));
            mp = min(p(1,:));
            Mp = max(p(1,:));
            if(strcmp(self.dd{2}.Value, 'Set Y'))
                mm = min(min(self.x));
                MM = max(max(self.x));
                if(abs(mm-MM) < 1e-16)
                    mm = mm - 1;
                    MM = MM + 1;
                end
                if(mp~=Mp && min(min(self.x))~=max(max(self.x)))
                    axis(self.ax{2}, [mp-0.1*(Mp-mp) Mp+0.1*(Mp-mp) mm MM]);
                end

                if(mp==Mp)
                    if( min(min(self.x))~=max(max(self.x)))
                        axis(self.ax{2}, [self.ax{2}.XAxis.Limits mm MM]);
                    end
                else
                    if( min(min(self.x))==max(max(self.x)))
                        axis(self.ax{2}, [mp-0.1*(Mp-mp) Mp+0.1*(Mp-mp) self.ax{2}.YAxis.Limits]);
                    else
                        axis(self.ax{2}, [mp-0.1*(Mp-mp) Mp+0.1*(Mp-mp) mm MM]);
                    end
                end
            else
                mm = min(min(self.y));
                MM = max(max(self.y));
                if(abs(mm-MM) < 1e-16)
                    mm = mm - 1;
                    MM = MM + 1;
                end
                if(mp~=Mp && min(min(self.x))~=max(max(self.x)))
                    axis(self.ax{2}, [mp-0.1*(Mp-mp) Mp+0.1*(Mp-mp) mm MM]);
                end

                if(mp==Mp)
                    if( min(min(self.x))~=max(max(self.x)))
                        axis(self.ax{2}, [self.ax{2}.XAxis.Limits mm MM]);
                    end
                else
                    if( min(min(self.x))==max(max(self.x)))
                        axis(self.ax{2}, [mp-0.1*(Mp-mp) Mp+0.1*(Mp-mp) self.ax{2}.YAxis.Limits]);
                    else
                        axis(self.ax{2}, [mp-0.1*(Mp-mp) Mp+0.1*(Mp-mp) mm MM]);
                    end
                end
            end
        end



        %% Select the figure from the available ones
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



        % --------------------------------------------
        %% boxmin(values)
        % Get the lower values of the successive boxes
        function y = boxmin(self,x)
            for n = 1:size(x,1)
                y(n,:) = min(x(n,1:end-1),x(n,2:end));
            end
        end



        % --------------------------------------------
        %% boxMax(values)
        % Get the upper values of the successive boxes
        function y = boxMax(self,x)
            for n = 1:size(x,1)
                y(n,:) = max(x(n,1:end-1),x(n,2:end));
            end
        end



        %% Define the callback functions of the dropdowns
        function setCallbacks(self)
            self.spinner{1}.ValueChangedFcn = @(app, spinner) self.spin(self.spinner{1});
            self.dd{1}.ValueChangedFcn = @(app, dd,event1) self.selection(self.dd{1},1);
            self.dd{2}.ValueChangedFcn = @(app, dd) self.switchSet(self.dd{2});
            self.dd{3}.ValueChangedFcn = @(app, dd) self.switchParam(self.dd{3});
            self.dd{4}.ValueChangedFcn = @(app, dd) self.switchSubFig(self.dd{4});
            self.dd{5}.ValueChangedFcn = @(app, dd) self.selectRegressionMode(self.dd{5});

        end

       

        % ------------- -------------------------------------------------------------------------------------
        %% selection(dropdown, parameter index)
        % --------------------------------------------------------------------------------------------------
        % Select the figure to plot from the one created by the current
        % Graphs().
        function selection(self, dd, pIdx) %% WONT WORK BEFORE Matlab 2019b
            select = dd.Value;
            for i=1:length(self.dd{1}.Items) % Get the figure index
                if(strcmp(self.dd{1}.Items{i}, select))
                    break;
                end
            end

            % Clear the current upper pannel and replace by new figure
            delete(self.uiPan{1}.Children);
            self.g.currentAxes = copyobj(self.g.axesList{i},self.uiPan{1});
            self.uiPan{1}.Children.XLabel.String = self.g.currentAxes.XLabel.String;
            self.uiPan{1}.Children.YLabel.String = self.g.currentAxes.YLabel.String;
            self.uiPan{1}.Children.Title.String = self.uiFig.Name;

            % Update the second pannel
            [self.x,self.y,self.color,self.displayName] = self.getChildrenFields(self.g.currentAxes);

            self.createFigure();

            if(self.isIntersector())
                self.update(0,pIdx);
            end
        end




        %% Check if the class name is Intersector
        function io = isIntersector(self)
            io = strcmp(class(self), 'Intersector');
        end



        % ----------------------------------------------------------------------
        %% updateFig(Graphs, parameter index)
        % ----------------------------------------------------------------------
        % Update the figure of the lower pannel
        function updateFig(self,pIdx)
            if(sum(contains(fieldnames(self.reg), 'UIFigure')))
                delete(self.reg.UIFigure);
            end
            ax = self.g.currentAxes;
            self.index = pIdx;

            % Clear the lower pannel figure
            for n = length(self.ax{2}.Children):-1:1
                if(contains(self.ax{2}.Children(n).Tag,'derived')||contains(self.ax{2}.Children(n).Tag,'regression'))
                    delete(self.ax{2}.Children(n));
                end
            end

            % Children Data properties
            self.cData.param = [];
            self.cData.paramName = {};
            self.cData.color = [];
            self.cData.line = {};
            cmpLabel = strcmp(self.ax{2}.YLabel.String, self.g.currentAxes.XLabel.String);

            % Plot Children on lower figure
            for n = 1:length(ax.Children)
                if(strcmp(ax.Children(n).Tag,'original'))
                    try
                        param = regexp(regexp(ax.Children(n).DisplayName,'(\S+)','match'),'^[^\d+ -]+','match','once');
                        param = param(~cellfun(@isempty,param));

                        %param = regexp(ax.Children(n).DisplayName, '\D+','match');
                        self.ax{2}.XLabel.String = param{pIdx};
                    catch
                        self.ax{2}.XLabel.String = 'Unspecified';
                    end
                    self.ax{2}.XLabel.Interpreter = 'latex';

                    self.cData.color(end+1,:) = ax.Children(n).Color;
                    self.cData.line{end+1,1} = ax.Children(n).LineStyle;
                end
                if(contains(ax.Children(n).Tag,'derived_Children'))
                    X = ax.Children(n).XData;
                    Y = ax.Children(n).YData;
                    cIdx = regexp(ax.Children(n).Tag, '\d+','match'); % Child index
                    paramVal = regexp(self.displayName{str2num(cIdx{1})}, '([+-])?\d+(.\d+)?','match'); % Parameter Value
                    self.cData.param(end+1,:) = [X Y str2num(cIdx{1}) cellfun(@str2num,paramVal) ];
                    self.cData.paramName{end+1} = extractBetween(self.displayName{str2num(cIdx{1})}, whitespacePattern ,whitespacePattern+(digitsPattern | characterListPattern("+-")+digitsPattern));
                    if(cmpLabel)
                        plot(self.ax{2},str2num(paramVal{pIdx}),X, 'd', 'Color', ax.Children(n).Color, 'MarkerSize',8,'MarkerFaceColor',ax.Children(n).MarkerFaceColor,'LineWidth',1.0,'Tag','derived3');
                        hold(self.ax{2},'on');
                    else
                        plot(self.ax{2},str2num(paramVal{pIdx}),Y, 'd', 'Color', ax.Children(n).Color, 'MarkerSize',8,'MarkerFaceColor',ax.Children(n).MarkerFaceColor,'LineWidth',1.0,'Tag','derived3');
                        hold(self.ax{2},'on');
                    end
                end
            end

            % ------------------------------------------
            if(~isempty(self.cData.param))
                filter = [];
                n =1;
                switch pIdx
                    case 1
                        next = 1;%2
                    case 2
                        next = 1;
                end
                % Get points for lines
                for i = sort(unique(self.cData.param(:,3+next))).'
                    filter = find(self.cData.param(:,3+next) == i);
                    P{n} = [self.cData.param(filter,1) self.cData.param(filter,2) self.cData.param(filter,3) self.cData.param(filter,3+pIdx)];
                    n = n+1;
                end

                % Plot lines
                warning ('off','all');
                for i = 1:length(P)
                    lineData = P{i};
                    if(length(lineData) > 1)
                        color = self.cData.color(lineData(1,3),:);
                        lineStyle = self.cData.line{lineData(1,3)};
                        % Linear regression
                        if(strcmp(self.ax{2}.YLabel.String, self.g.currentAxes.XLabel.String))
                            [pn] = polyfit(lineData(:,4),lineData(:,1),1);
                            [pfit] = polyval(pn,lineData(:,4));
                            ym = mean(lineData(:,1));
                            R2 = 1 - (sum((pfit-lineData(:,1)).^2)/sum((lineData(:,1)-ym).^2));
                        else
                            [pn] = polyfit(lineData(:,4),lineData(:,2),1);
                            [pfit] = polyval(pn,lineData(:,4));
                            ym = mean(lineData(:,2));
                            R2 = 1-(sum((pfit-lineData(:,2)).^2)/sum((lineData(:,2)-ym).^2));
                        end

                        %                        l = plot(self.ax{2},lineData(:,4),pfit,'Color',color,'LineStyle',lineStyle,'Tag','derived4');
                        pos = round(size(lineData,1)/2);
                    end
                end
                warning ('on','all');
            end

        end




        % ---------------------------------------------------------------------------------
        %% spin(spinner, dropdown, Graphs, lower panel axes, color, Name tags of the lines)
        % ---------------------------------------------------------------------------------
        % Update the pannels when the set value is modified.
        function spin(self, s)
            pIdx = self.index;
            x = self.x;
            y = self.y;
            ax = self.g.currentAxes;
            xy0 = s.Value;

            % Get the parameter values of the points
            p = cell2mat(cellfun(@str2num,cellfun(@(x) char(regexp(x,'([+-])?\d+(.\d+)?','match')),self.displayName,'UniformOutput',false),'UniformOutput',false));

            %p = cellfun(@str2num,cellfun(@(x) regexp(x,'\d+','match'),DisplayName));
            mp = min(p(pIdx,:));
            Mp = max(p(pIdx,:));
            switch self.dd{2}.Value
                case 'Set X'
                    s.Step = min(diff(ax.XTick))/5;
                    self.updateX(xy0);
                    self.ax{2}.YLabel.String = self.g.currentAxes.YLabel.String;
                    self.ax{2}.YLabel.Interpreter = 'latex';

                    % Adjust the zoom
                    if(mp==Mp)
                        if( min(min(y))~=max(max(y)))
                            axis(self.ax{2}, [self.ax{2}.XAxis.Limits min(min(y)) max(max(y))]);
                        end
                    else
                        if( min(min(y))==max(max(y)))
                            axis(self.ax{2}, [mp-0.1*(Mp-mp) Mp+0.1*(Mp-mp) self.ax{2}.YAxis.Limits]);
                        else
                            axis(self.ax{2}, [mp-0.1*(Mp-mp) Mp+0.1*(Mp-mp) min(min(y)) max(max(y))]);
                        end
                    end
                case 'Set Y'
                    s.Step = min(diff(ax.YTick))/5;
                    self.updateY(xy0);
                    self.ax{2}.YLabel.String = self.g.currentAxes.XLabel.String;
                    self.ax{2}.YLabel.Interpreter = 'latex';

                    % Adjust the zoom
                    if(mp==Mp)
                        if( min(min(x))~=max(max(x)))
                            axis(self.ax{2}, [self.ax{2}.XAxis.Limits min(min(x)) max(max(x))]);
                        end
                    else
                        if( min(min(x))==max(max(x)))
                            axis(self.ax{2}, [mp-0.1*(Mp-mp) Mp+0.1*(Mp-mp) self.ax{2}.YAxis.Limits]);
                        else
                            axis(self.ax{2}, [mp-0.1*(Mp-mp) Mp+0.1*(Mp-mp) min(min(x)) max(max(x))]);
                        end
                    end
                otherwise
            end
            self.updateFig(pIdx);
        end



        % ---------------------------------------------------------------------------------
        %% switchset(dropdown, spinner, Graphs, lower panel axes, colors, Tags of the lines)
        % ---------------------------------------------------------------------------------
        % Reload the spinner when the set value is changed from an X
        % coordinate to a Y coordinate, or the other way round.
        function switchSet(self, dd)
            self.spin(self.spinner{1});
        end




        % -------------------------------------------------------------------------------------------------------------------
        %% switchParam(dropdown, spinner, dropdown, Graphs, lower pannel axes, color, tags of the lines, possible parameters)
        % -------------------------------------------------------------------------------------------------------------------
        % Deal with the change of parameter as the X axis of the lower
        % pannel.
        function switchParam(self, dd)
            idx = find(strcmp(dd.Value, self.dd{3}.Items));
            self.index = idx;
            self.ddLabel{3}.Text = ['Parameter (' dd.Value ')'];

            self.spin(self.spinner{1});
        end



        % ---------------------------------------
        %% updateY(Graphs, Value set for Y, Color)
        % ---------------------------------------
        % Get the intersection of the lines with the set value of y and
        % update the upper panel.
        function updateY(self,y0)
        end



        % ---------------------------------------
        %% updateX(Graphs, Value set for X, Color)
        % ---------------------------------------
        % Get the intersection of the lines with the set value of x and
        % update the upper panel.
        function updateX(self, x0)
        end


        
        %% Get the indices of the new subfigure selected
        function [i,j] = switchSubFig(self,dd)
            select = dd.Value;
            for i=1:length(self.dd{1}.Items) % Get the figure index
                if(strcmp(self.dd{1}.Items{i}, self.dd{1}.Value))
                    break;
                end
            end
            for j=1:length(self.dd{4}.Items) % Get the figure index
                if(strcmp(self.dd{4}.Items{j}, self.dd{4}.Value))
                    break;
                end
            end

            self.selectFigure(i,j)

            self.update(self.spinner{1}.Value, self.index);
        end

    end
end