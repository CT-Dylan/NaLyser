classdef FunctionApplyer < GraphAnalyser
    properties
        fun             % Function
        funOutputType   % Type of output (single value, another function,...)

        % Graphical User Interface elements
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
        function self = FunctionApplyer(varargin)

            self@GraphAnalyser(varargin{:});
            self.fun = @trapz;
            self.funOutputType = 'point';
            self.className = 'Function Applyer';

            % Create buttons and others
            r = 5;
            c = 6;
            self.ddLabel{3} = uilabel(self.uiPan{3});
            self.ddLabel{3}.HorizontalAlignment = 'right';
            self.ddLabel{3}.Position = self.getSlot(r, c, 7, self.Pix_PS .* [0 0 1 1], 0.9);
            self.ddLabel{3}.Text = 'Parameter X';
            self.ddLabel{3}.Interpreter = 'latex';

            self.ddLabel{4} = uilabel(self.uiPan{3});
            self.ddLabel{4}.HorizontalAlignment = 'right';
            self.ddLabel{4}.Position = self.getSlot(r, c, 8, self.Pix_PS .* [0 0 1 1], 0.9);
            self.ddLabel{4}.Text = 'Function';
            self.ddLabel{4}.Interpreter = 'latex';

            self.ddLabel{5} = uilabel(self.uiPan{3});
            self.ddLabel{5}.HorizontalAlignment = 'right';
            self.ddLabel{5}.Position = self.getSlot(r, c, 18, self.Pix_PS .* [0 0 1 1], 0.9);
            self.ddLabel{5}.Text = 'Regression mode';
            self.ddLabel{5}.Interpreter = 'latex';

            % Figure list
            self.dd{1} = uidropdown(self.uiPan{3},...
                'Position',self.getSlot(r, c, 5, self.Pix_PS .* [0 0 1 1], 0.9),...
                'Items',cellfun(@(x) x.Name, self.g.figList, 'UniformOutput', false));

            % X/Y axis
            self.dd{2} = uidropdown(self.uiPan{3},...
                'Position',self.getSlot(r, c, 14, self.Pix_PS .* [0 0 1 1], 0.9),...
                'Items',[{'(X,Y)'} {'(Y,X)'} {'(X)'} {'(Y)'}], 'Value','(X,Y)');

            % Subfig list
            self.dd{4} = uidropdown(self.uiPan{3},...
                'Position',self.getSlot(r, c, 4, self.Pix_PS .* [0 0 1 1], 0.9),...
                'Items',cellfun(@(x) ['> ' x.String], {self.g.axesList{1}.Title}, 'UniformOutput', false));

            % Function list
            self.dd{5} = uidropdown(self.uiPan{3},...
                'Position',self.getSlot(r, c, 13, self.Pix_PS .* [0 0 1 1], 0.9),...
                'Items',{'Integral','Derivative','IntegralLog10'});

            % Regression mode
            self.dd{6} = uidropdown(self.uiPan{3},...
                'Position',self.getSlot(r, c, 23, self.Pix_PS .* [0 0 1 1], 0.9),...
                'Items', {'Merged', 'Separate'});

            % Save button
            self.button{1} = uibutton(self.uiPan{3},...
                'Position',self.getSlot(r, c, 26, self.Pix_PS .* [0 0 1 1], 0.9),...
                'Text','Collect figure', 'ButtonPushedFcn', @(app, btn) self.collect(self.button{1}));

            % Inspect figure button
            self.button{2} = uibutton(self.uiPan{3},...
                'Position',self.getSlot(r, c, 27, self.Pix_PS .* [0 0 1 1], 0.9),...
                'Text','Inspect figure', 'ButtonPushedFcn', @(app,btn) self.inspect(self.button{2}));

            % Regression button
            self.button{3} = uibutton(self.uiPan{3},...
                'Position',self.getSlot(r, c, 24, self.Pix_PS .* [0 0 1 1], 0.9),...
                'Text','Regression', 'ButtonPushedFcn', @(app,btn) self.regression(self.button{3}));

            % Select first figure by default
            self.selectFigure(1,1);


            % Get lines data
            [self.x,self.y,self.color,self.displayName] = self.getChildrenFields(self.g.currentAxes);

            % Parameter list dropdown
            dd3Options = cellfun(@(x) regexp(regexp(x,'(\S+)','match'),'^[^\d+ -]+','match','once'), self.displayName,'UniformOutput',false);
            dd3Options = cellfun(@(x) x(~cellfun(@isempty,x)), dd3Options,'UniformOutput',false);
            dd3Options = dd3Options{find(cellfun(@length,dd3Options)==max(cellfun(@length,dd3Options)),1)};
            if(isempty(dd3Options))
                self.dd{3} = uidropdown(self.uiPan{3},...
                    'Position',self.getSlot(r, c, 12, self.Pix_PS .* [0 0 1 1], 0.9),...
                    'Items', {'none'}, 'Value',{'none'});
                self.ddLabel{3}.Text = ['Parameter (none)'];
            else
                self.dd{3} = uidropdown(self.uiPan{3},...
                    'Position',self.getSlot(r, c, 12, self.Pix_PS .* [0 0 1 1], 0.9),...
                    'Items', dd3Options, 'Value',dd3Options{1});
                self.ddLabel{3}.Text = ['Parameter (' dd3Options{1} ')'];
            end

            if(length(self.dd{3}.Items) <= 1)
                self.dd{6}.Value = {'Merged'};
            end
            self.reg = [];
            self.reg.UIFigure = [];

            self.setCallbacks();
            self.update(1);

            self.createFigure();
        end


        %% Start figure inspector
        function inspect(self,btn)
            FigureInspector(self.ax{2});
        end


        %% Start a regression of the lower panel data
        function regression(self, btn)
            % Start regression
            self.reg = Regressor();

            if(matches(self.dd{6}.Value,"Merged"))
                self.reg.setPoints(self.cData.param(:,1), self.cData.param(:,3:end), self.cData.paramName{1});
            else
                for i = 1:length(self.dd{3}.Items)
                    if(matches(self.dd{3}.Items(i), self.dd{3}.Value))
                        pIdx = i;
                    else
                        npIdx = i;
                        [pValues, uniqueIdx, repeatIdx] = unique(self.cData.param(:, 2+i));
                    end
                end
                self.reg.setPoints(self.cData.param(repeatIdx == 1,1), self.cData.param(repeatIdx == 1,2+pIdx), self.cData.paramName{1}(pIdx));
                disp(join(["For ", self.cData.paramName{1}(npIdx), " = ", num2str(pValues(1)),":"],""))
            end
            self.reg.setConfirmFct(self, @(x, varargin) x.plotRegression(self.reg));
            self.reg.setFunctions();
        end



        %% Plot the regression results of the lower panel data
        function plotRegression(self, reg)
            % Delete previous regression
            for k = length(self.ax{2}.Children):-1:1
                if(matches(self.ax{2}.Children(k).Tag, "regression"))
                    delete(self.ax{2}.Children(k));
                end
            end

            if(matches(self.dd{6}.Value,"Merged"))
                lI = length(self.dd{3}.Items);
                if(lI <= 1)
                    plot(self.ax{2},self.reg.pDisplay,self.reg.vDisplay, 'Color', 'k', 'LineStyle','-', 'Tag', 'regression');
                        
                else
                for i = 1:lI
                    if(~matches(self.dd{3}.Items(i), self.dd{3}.Value))
                        [pValues, uniqueIdx] = unique(self.cData.param(:, 2+i));
                        for j = 1:length(pValues)
                            disp(join(["Expression for ",self.dd{3}.Items(i),"=", num2str(pValues(j)),""],""))
                            [x,y] = reg.getProjection(self.dd{3}.Items(i), pValues(j));
                            plot(self.ax{2},x,y, 'Color', self.cData.color(self.cData.param(uniqueIdx(j),2),:), 'LineStyle',self.cData.line{self.cData.param(uniqueIdx(j),2)}, 'Tag', 'regression');
                        end

                    end
                end
                end
            else
                for i = 1:length(self.dd{3}.Items)
                    if(matches(self.dd{3}.Items(i), self.dd{3}.Value))
                        pIdx = i;
                    else
                        [pValues, uniqueIdx, repeatIdx] = unique(self.cData.param(:, 2+i));
                    end
                end
                plot(self.ax{2}, reg.pDisplay,reg.vDisplay, 'Color', self.cData.color(self.cData.param(uniqueIdx(1),2),:), 'LineStyle',self.cData.line{self.cData.param(uniqueIdx(1),2)}, 'Tag', 'regression');
                for j = 2:length(pValues)
                    reg.setPoints(self.cData.param(repeatIdx == j,1), self.cData.param(repeatIdx == j,2+pIdx), self.cData.paramName{1});
                    disp(join(["For ", reg.pName{pIdx}, " = ", num2str(pValues(j)),":"],""))
                    reg.regression();
                    reg.displayPlot();
                    plot(self.ax{2}, reg.pDisplay,reg.vDisplay, 'Color', self.cData.color(self.cData.param(uniqueIdx(j),2),:), 'LineStyle',self.cData.line{self.cData.param(uniqueIdx(j),2)}, 'Tag', 'regression');

                end
            end
        end



        %% Delete any existing regression window since the algorithm is changed
        function selectRegressionMode(self, dd)
            if(sum(contains(fieldnames(self.reg), 'UIFigure')))
                delete(self.reg.UIFigure);
            end
        end



        %% Update the values of the lower panel
        function update(self, pIdx)
            if(sum(contains(fieldnames(self.reg), 'UIFigure')))
                delete(self.reg.UIFigure);
            end
            ax = self.g.currentAxes;
            self.index = pIdx;
            % Clear the lower pannel figure
            for n = length(self.ax{2}.Children):-1:1
                if(contains(self.ax{2}.Children(n).Tag,'derived')|contains(self.ax{2}.Children(n).Tag,'regression'))
                    delete(self.ax{2}.Children(n));
                end
            end

            % Children Data properties
            self.cData.param = [];
            self.cData.paramName = {};
            self.cData.color = [];
            self.cData.line = {};
            cmpLabel = strcmp(self.ax{2}.YLabel.String, self.g.currentAxes.XLabel.String);

            % Plot Children on lower figure and store their data
            for n = 1:length(ax.Children)
                if(strcmp(ax.Children(n).Tag,'original'))
                    param = regexp(regexp(ax.Children(n).DisplayName,'(\S+)','match'),'^[^\d+ -]+','match','once');
                    param = param(~cellfun(@isempty,param));

                    paramVal = regexp(ax.Children(n).DisplayName,'([+-])?((\d+)(.\d+)?)','match');
                    paramVal = paramVal(~cellfun(@isempty,paramVal));

                    if(strcmp(self.funOutputType, 'point'))
                        try
                            self.ax{2}.XLabel.String = param{pIdx};
                        catch
                            self.ax{2}.XLabel.String = 'none';
                        end
                        self.ax{2}.XLabel.Interpreter = 'latex';

                    elseif(strcmp(self.funOutputType, 'line'))
                        if(strcmp(self.dd{2}.Value, '(X,Y)'))
                            self.ax{2}.XLabel.String = self.g.currentAxes.XLabel.String;
                        elseif(strcmp(self.dd{2}.Value, '(Y,X)'))
                            self.ax{2}.XLabel.String = self.g.currentAxes.YLabel.String;
                        end
                        self.ax{2}.XLabel.Interpreter = 'latex';
                    end
                    self.cData.color(end+1,:) = ax.Children(n).Color;
                    self.cData.line{end+1,1} = ax.Children(n).LineStyle;

                    if(strcmp(self.funOutputType, 'point'))
                        if(strcmp(self.dd{2}.Value, '(X,Y)'))
                            funResult(n) = self.fun(ax.Children(n).XData,ax.Children(n).YData);

                        elseif(strcmp(self.dd{2}.Value, '(Y,X)'))
                            funResult(n) = self.fun(ax.Children(n).YData,ax.Children(n).XData);

                        elseif(strcmp(self.dd{2}.Value, '(X)'))
                            funResult(n) = self.fun(ax.Children(n).XData);

                        elseif(strcmp(self.dd{2}.Value, '(Y)'))
                            funResult(n) = self.fun(ax.Children(n).YData);

                        end
                        try
                            plot(self.ax{2},str2num(paramVal{pIdx}), funResult(n), 'd', 'Color', 'k', 'MarkerSize',8,'MarkerFaceColor',ax.Children(n).Color,'LineWidth',1.0,'Tag','derived3','DisplayName',  ax.Children(n).DisplayName);
                        catch
                            plot(self.ax{2},zeros(size(self.ax{2})), funResult(n), 'd', 'Color', 'k', 'MarkerSize',8,'MarkerFaceColor',ax.Children(n).Color,'LineWidth',1.0,'Tag','derived3','DisplayName',  ax.Children(n).DisplayName);

                        end
                        hold(self.ax{2},'on');


                        paramVal = regexp(self.displayName{n}, '(([+-])?\d+(.\d+)?[e]([+-])?\d+)|(([+-])?\d+(.\d+)?)','match'); % Parameter Value
                        self.cData.param(end+1,:) = [funResult(n) n cellfun(@str2num,paramVal) ];
                        self.cData.paramName{end+1} = extractBetween(self.displayName{n}, whitespacePattern ,whitespacePattern+(digitsPattern | characterListPattern("+-")+digitsPattern));

                        self.dd{6}.Enable = 'on';
                        self.button{3}.Enable = 'on';


                    elseif(strcmp(self.funOutputType, 'line'))
                        if(strcmp(self.dd{2}.Value, '(X,Y)'))
                            funResult(n,:) = self.fun(ax.Children(n).XData,ax.Children(n).YData);
                            plot(self.ax{2},ax.Children(n).XData, funResult(n,:), '-', 'Color', ax.Children(n).Color,'LineWidth',1.0,'Tag','derived3','DisplayName', ax.Children(n).DisplayName);

                        elseif(strcmp(self.dd{2}.Value, '(Y,X)'))
                            funResult(n,:) = self.fun(ax.Children(n).YData,ax.Children(n).XData);
                            plot(self.ax{2},ax.Children(n).YData, funResult(n,:), '-', 'Color', ax.Children(n).Color,'LineWidth',1.0,'Tag','derived3','DisplayName',  ax.Children(n).DisplayName);

                        elseif(strcmp(self.dd{2}.Value, '(X)'))
                            funResult(n,:) = self.fun(ax.Children(n).XData);
                            plot(self.ax{2},ax.Children(n).XData, funResult(n,:), '-', 'Color', ax.Children(n).Color,'LineWidth',1.0,'Tag','derived3','DisplayName',  ax.Children(n).DisplayName);

                        elseif(strcmp(self.dd{2}.Value, '(Y)'))
                            funResult(n,:) = self.fun(ax.Children(n).YData);
                            plot(self.ax{2},ax.Children(n).YData, funResult(n,:), '-', 'Color', ax.Children(n).Color,'LineWidth',1.0,'Tag','derived3', ax.Children(n).DisplayName);

                        end

                        hold(self.ax{2},'on');

                        self.dd{6}.Enable = 'off';
                        self.button{3}.Enable = 'off';
                    end
                end
            end


            % Adjust zoom
            p = cell2mat(cellfun(@str2num,cellfun(@(x) char(regexp(x,'(([+-])?\d+(.\d+)?[e]([+-])?\d+)|(([+-])?\d+(.\d+)?)','match')),self.displayName,'UniformOutput',false),'UniformOutput',false));

            if(isempty(p))
                p = 0;
            end
            idx = find(strcmp(self.dd{3}.Value, self.dd{3}.Items));
            mp = min(p(idx,:));
            Mp = max(p(idx,:));
            if(strcmp(self.dd{2}.Value, '(Y,X)') | strcmp(self.dd{2}.Value, '(Y)' ))
                mm = min(funResult,[],'all');
                MM = max(funResult,[],'all');
                if(abs(mm-MM) < 1e-16)
                    mm = mm - 1;
                    MM = MM + 1;
                end
                % Check if value is infinite or does not exist.
                if(sum(isinf(mm)+isnan(mm)) && sum(isinf(MM)+isnan(MM)))
                    error("A result is infinite or not a number.");
                end
                XAxisBounds(1,:) = [mp-0.1*(Mp-mp) Mp+0.1*(Mp-mp)];
                XAxisBounds(2,:) = self.ax{2}.YAxis.Limits;
                XAxisBounds(3,:) = self.g.currentAxes.YAxis.Limits;
                YAxisBounds(1,:) = [mm MM];
                YAxisBounds(2,:) = self.ax{2}.XAxis.Limits;
                if(mp~=Mp && min(min(self.x))~=max(max(self.x)))
                    xAB = 1;
                    yAB = 1;
                end

                if(mp==Mp)
                    if( min(min(self.x))~=max(max(self.x)))
                        xAB = 2;
                        yAB = 1;
                    end
                else
                    if( min(min(self.x))==max(max(self.x)))
                        xAB = 1;
                        yAB = 2;
                    else
                        xAB = 1;
                        yAB = 1;
                    end
                end
                if(strcmp(self.funOutputType, 'line'))
                    xAB = 3;
                end
                axis(self.ax{2}, [XAxisBounds(xAB,:) YAxisBounds(yAB, :)]);
            else
                mm = min(funResult,[],'all');
                MM = max(funResult,[],'all');
                if(abs(mm-MM) < 1e-16)
                    mm = mm - 1;
                    MM = MM + 1;
                end
                % Check if value is infinite or does not exist.
                if(sum(isinf(mm)+isnan(mm)) && sum(isinf(MM)+isnan(MM)))
                    error("A result is infinite or not a number.");
                end
                XAxisBounds(1,:) = [mp-0.1*(Mp-mp) Mp+0.1*(Mp-mp)];
                XAxisBounds(2,:) = self.ax{2}.XAxis.Limits;
                XAxisBounds(3,:) = self.g.currentAxes.XAxis.Limits;
                YAxisBounds(1,:) = [mm MM];
                YAxisBounds(2,:) = self.ax{2}.YAxis.Limits;
                if(mp~=Mp && min(min(self.x))~=max(max(self.x)))
                    xAB = 1;
                    yAB = 1;
                end

                if(mp==Mp)
                    if( min(min(self.x))~=max(max(self.x)))
                        xAB = 2;
                        yAB = 1;
                    end
                else
                    if( min(min(self.x))==max(max(self.x)))
                        xAB = 1;
                        yAB = 2;
                    else
                        xAB = 1;
                        yAB = 1;
                    end
                end
                if(strcmp(self.funOutputType, 'line'))
                    xAB = 3;
                end
                axis(self.ax{2}, [XAxisBounds(xAB,:) YAxisBounds(yAB, :)]);
            end
        end



        %% Set the callback function of the dropdowns
        function setCallbacks(self)
            self.dd{1}.ValueChangedFcn = @(app, dd,event1) self.selection(self.dd{1},1);
            self.dd{2}.ValueChangedFcn = @(app, dd) self.switchSet(self.dd{2});
            self.dd{3}.ValueChangedFcn = @(app, dd) self.switchParam(self.dd{3});
            self.dd{4}.ValueChangedFcn = @(app, dd) self.switchSubFig(self.dd{4});
            self.dd{5}.ValueChangedFcn = @(app, dd) self.selectFunction(self.dd{5});
            self.dd{6}.ValueChangedFcn = @(app, dd) self.selectRegressionMode(self.dd{6});
        end

        

        %% Select the figure among the ones available
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
                axis(self.g.currentAxes, [tmp.XAxis.Limits tmp.YAxis.Limits]);
                xlabel(self.g.currentAxes,tmp.XLabel.String,'interpreter','latex');
                ylabel(self.g.currentAxes,tmp.YLabel.String);
                grid minor;
                for i = 1:length(tmp.Children)
                    lines(i) = copyobj( tmp.Children(i), self.g.currentAxes);
                end
            end
            self.ax{2}.YLabel.Interpreter = 'latex';
            if(strcmp(self.dd{2}.Value, '(Y,X)'))
                self.ax{2}.YLabel.String = ['$f($  ' self.g.currentAxes.XLabel.String ' $)$'];
            else
                self.ax{2}.YLabel.String = ['$f($  ' self.g.currentAxes.YLabel.String ' $)$'];
            end

            % Update the second pannel
            [self.x,self.y,self.color,self.displayName] = self.getChildrenFields(self.g.currentAxes);

        end



        %% Apply the selection of the upper right panel
        function selection(self, dd, pIdx) %% WONT WORK BEFORE Matlab 2019b
            self.selectFigure(find(strcmp(dd.Items,dd.Value)), pIdx);
            self.createFigure();

            self.update(pIdx);

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

            self.update(idx);
        end


        
        %% Select another subfigure
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

            self.selectFigure(i,j);

            self.update(self.index);
        end



        % ---------------------------------------------------------------------------------
        %% switchset(dropdown, spinner, Graphs, lower panel axes, colors, Tags of the lines)
        % ---------------------------------------------------------------------------------
        % Reload the spinner when the set value is changed from an X
        % coordinate to a Y coordinate, or the other way round.
        function switchSet(self, dd)
            switch self.dd{2}.Value
                case '(X,Y)'
                    self.ax{2}.YLabel.String = ['$f($  ' self.g.currentAxes.YLabel.String ' $)$'];
                    self.ax{2}.YLabel.Interpreter = 'latex';

                case '(Y,X)'
                    self.ax{2}.YLabel.String = ['$f($  ' self.g.currentAxes.XLabel.String ' $)$'];
                    self.ax{2}.YLabel.Interpreter = 'latex';
                case '(X)'
                    self.ax{2}.YLabel.String = ['$f($  ' self.g.currentAxes.XLabel.String ' $)$'];
                    self.ax{2}.YLabel.Interpreter = 'latex';

                case '(Y)'
                    self.ax{2}.YLabel.String = ['$f($  ' self.g.currentAxes.YLabel.String ' $)$'];
                    self.ax{2}.YLabel.Interpreter = 'latex';
                otherwise
            end
            if(length(self.dd{2}.Value) < 4)
                self.dd{5}.Items = {'Mean','Median','Standard deviation','Maximum','Minimum'};
                self.selectFunction(self.dd{5});
            elseif(length(self.dd{2}.Value) < 6)
                self.dd{5}.Items = {'Integral','Derivative','IntegralLog10'};
                self.selectFunction(self.dd{5});
            end
            self.update(self.index);

        end



        %% Select the function to apply
        function selectFunction(self, dd)
            switch self.dd{5}.Value
                case 'Integral'
                    self.fun = @trapz;
                    self.funOutputType = 'point';
                case 'IntegralLog10'
                    self.fun = @(x,y) trapz(log10(x),y);
                    self.funOutputType = 'point';
                case 'Derivative'
                    self.fun = @self.derivativeAlternative;
                    self.funOutputType = 'line';
                case 'Mean'
                    self.fun = @mean;
                    self.funOutputType = 'point';
                case 'Maximum'
                    self.fun = @max;
                    self.funOutputType = 'point';
                case 'Minimum'
                    self.fun = @min;
                    self.funOutputType = 'point';
                case 'Median'
                    self.fun = @median;
                    self.funOutputType = 'point';
                case 'Standard deviation'
                    self.fun = @std;
                    self.funOutputType = 'point';
                otherwise
            end
            self.update(self.index);
        end



        %% Define the derivative operation
        function dydx = derivative(self,X,Y)
            y = Y;
            dydx = zeros(size(X));
            N = 3;
            SavitzkyGolay(N,1:length(Y)-N+1);
            for NSG = N-2:-2:3
                SavitzkyGolay(NSG, 1);
                SavitzkyGolay(NSG, length(Y)-NSG+1);
            end

            ratio = diff(y) ./ diff(X);
            dydx(1:end-1) = dydx(1:end-1) + ratio;
            dydx(2:end) = dydx(2:end) + ratio;
            dydx = dydx ./2;



            %% Define the data smoothing algorithm used for derivating
            function SavitzkyGolay(n,range)
                for i = range
                    sample = Y(i:i+n-1);
                    z = (X(i:i+n-1) - mean(X(i:i+n-1))) ./ mean(diff(X(i:i+n-1)));
                    for dim = 0:n-2
                        J(1:length(z),dim+1) = z.^dim;

                    end
                    C = inv(J.' * J) * J.';
                    a = C * sample.';
                    %dydx(i+floor(n/2)) = a(2) ./ mean(diff(X(i:i+n-1)));
                    y(i+floor(n/2)) = a(1);
                end

            end
        end



        %% Define another derivative operation algorithm
        function dydx = derivativeAlternative(self,X,Y)
            ratio = diff(Y) ./ (2*diff(X));
            dydx = zeros(size(X));
            dydx(1:end-1) = dydx(1:end-1) + ratio;
            dydx(2:end) = dydx(2:end) + ratio;

            N = 3;
            SavitzkyGolay(N,1:length(dydx)-N+1);
            for NSG = N-2:-2:3
                SplotavitzkyGolay(NSG, 1);
                SavitzkyGolay(NSG, length(dydx)-NSG+1);
            end

            function SavitzkyGolay(n,range)
                for i = range
                    sample = dydx(i:i+n-1);
                    z = (X(i:i+n-1) - mean(X(i:i+n-1))) ./ mean(diff(X(i:i+n-1)));
                    for dim = 0:n-2
                        J(1:length(z),dim+1) = z.^dim;

                    end
                    C = inv(J.' * J) * J.';
                    a = C * sample.';
                    dydx(i+floor(n/2)) = a(1);
                end

            end
        end
    end
end