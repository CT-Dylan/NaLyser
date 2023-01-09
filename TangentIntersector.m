% TangentIntersector
% -------------------------------------------------------------------------
% A class that will display an interface wherein the linear regression of a portion
% of curves of a given figure are intersected with a line and the resulting points 
% are plotted in a window below.
%
% Instantiate with: t = TangentIntersector()
% 
classdef TangentIntersector < Intersector
    properties
        reg
    end
    methods
        % ----------------------------------------
        %% constructor(Graphs)
        % ----------------------------------------
        
        function self = TangentIntersector(varargin)
            
            self@Intersector(varargin{:});
            self.className = 'Tangent Intersector';
            
            % Create buttons and others
            r = 5;
            c = 6;

            self.spinnerLabel{2} = uilabel(self.uiPan{3});
            self.spinnerLabel{2}.HorizontalAlignment = 'right';
            self.spinnerLabel{2}.Position = self.getSlot(r, c, 6, self.Pix_PS .* [0 0 1 1], 0.9);
            self.spinnerLabel{2}.Text = 'Regression range';
            self.spinnerLabel{2}.Interpreter = 'latex';

            self.spinner{2} = uispinner(self.uiPan{3}, 'Value', min(self.g.currentAxes.XLim));
            self.spinner{2}.Position = self.getSlot(r, c, 11, self.Pix_PS .* [0 0 1 1], 0.9);
            self.spinner{2}.Step = min(diff(self.g.currentAxes.XTick))/5;

            self.spinner{3} = uispinner(self.uiPan{3}, 'Value', max(self.g.currentAxes.XLim));
            self.spinner{3}.Position = self.getSlot(r, c, 16, self.Pix_PS .* [0 0 1 1], 0.9);
            self.spinner{3}.Step = min(diff(self.g.currentAxes.XTick))/5;

            self.spinner{2}.Limits = [min(self.g.currentAxes.XLim) self.spinner{3}.Value];
            self.spinner{3}.Limits = [self.spinner{2}.Value max(self.g.currentAxes.XLim)];


            %evaluate
            warning ('off','all');
            for j = 1:size(self.x,1)
                self.reg(j,:) = polyval(polyfit(self.x(j,:),self.y(j,:),1),self.x(j,:));
            end
            warning ('on','all');
            self.mx = self.boxmin(self.x);
            self.my = self.boxmin(self.reg);
            self.Mx = self.boxMax(self.x);
            self.My = self.boxMax(self.reg);
            self.index = 1;

            self.setCallbacks();
            self.update(0,1);
        end



        %% Set the callbacks of the spinners ( on top of the dropdowns)
        function setCallbacks(self)
            self.setCallbacks@Intersector()
            self.spinner{2}.ValueChangedFcn = @(app, spinA, spinB) self.regSpin(self.spinner{2},self.spinner{3});
            self.spinner{3}.ValueChangedFcn = @(app, spinA, spinB) self.regSpin(self.spinner{3},self.spinner{2});

        end



        %% Define the limits of the values of the interval spinner
        function regSpin(self, spinA, spinB)
            if(spinA < spinB) %spinner1 call
                mS = spinA.Value;
                MS = spinB.Value;
                spinA.Limits(2) = MS;
                spinB.Limits(1) = mS;
            else  %spinner2 call
                mS = spinB.Value;
                MS = spinA.Value;
                spinB.Limits(2) = MS;
                spinA.Limits(1) = mS;
            end


            for j = 1:size(self.x,1)
                range = find(mS<=(self.x(j,:))&(self.x(j,:)<=MS));
                self.reg(j,:) = polyval(polyfit(self.x(j,range),self.y(j,range),1),self.x(j,:));
            end

            self.my = self.boxmin(self.reg);
            self.My = self.boxMax(self.reg);

            self.spin(self.spinner{1});
            line(self.g.currentAxes, [mS mS],[min(min(self.y)) max(max(self.y))],'LineStyle',':', 'Color', 'k','LineWidth',0.5,'Tag','derived2');
            line(self.g.currentAxes, [MS MS],[min(min(self.y)) max(max(self.y))],'LineStyle',':', 'Color', 'k','LineWidth',0.5,'Tag','derived2');

        end



        % ------------- -------------------------------------------------------------------------------------
        %% selection(dropdown, Graphs, upper panel, list of figures, axes of the lower panel, parameter index)
        % --------------------------------------------------------------------------------------------------
        % Select the figure to plot from the one created by the current
        % Graphs().
        function selection(self, dd, pIdx) %% WONT WORK BEFORE Matlab 2019b
            self.selectFigure(find(strcmp(dd.Items,dd.Value)), pIdx);

            warning ('off','all');
            for j = 1:size(self.x,1)
                self.reg(j,:) = polyval(polyfit(self.x(j,:),self.y(j,:),1),self.x(j,:));
            end
            warning ('on','all');
            self.mx = self.boxmin(self.x);
            self.my = self.boxmin(self.reg);
            self.Mx = self.boxMax(self.x);
            self.My = self.boxMax(self.reg);
            
            self.createFigure();

            self.update(0,pIdx);

        end


        % ---------------------------------------
        %% updateX(Graphs, Value set for X, Color)
        % ---------------------------------------
        % Get the intersection of the lines with the set value of x and
        % update the upper panel.
        function updateX(self, x0)
            mx = self.mx;
            my = self.my;
            Mx = self.Mx;
            My = self.My;
            x = self.x;
            y = self.y;
            ax = self.g.currentAxes;
            [row,col] = find(mx <= x0 & Mx > x0); % Index of boxes where there are intersections.
            idx = sub2ind(size(my),row,col);
            if(col~=size(my,2))
                slopeSign = sign(y(sub2ind(size(my),row,col+1))-y(idx));
            else
                slopeSign = sign(y(idx)-y(sub2ind(size(my),row,col-1)));
            end
            % Compute y values of the intersections
            Y = my(idx) + ((slopeSign<0) + slopeSign.' .* ((x0 - mx(idx))./(Mx(idx) - mx(idx)))) .* (My(idx) - my(idx));

            % Delete previous lines and intersections
            for n = length(ax.Children):-1:1
                if(contains(ax.Children(n).Tag,'derived'))
                    delete(ax.Children(n));
                end
            end

            % Draw new lines and intersections
            for k = 1:size(x,1)
                plot(ax,x(k,:),self.reg(k,:),'-','Color',self.color(k,:),'LineWidth',0.05,'Tag',['derived_Regression' num2str(k)]);
            end
            line(ax, [x0 x0],[min(min(y)) max(max(y))], 'Color', 'k','LineWidth',1.0,'Tag','derived2');
            for c = 1:size(my,1) % number of Children
                for m = find(row == c)
                    if(~isempty(Y(m)))
                        plot(ax,x0,Y(m), 'd', 'Color', 'k', 'MarkerSize',3,'MarkerFaceColor',self.color(c,:),'LineWidth',1.0,'Tag',['derived_Children' num2str(c)]);

                    end
                end
            end
        end



        % ---------------------------------------
        %% updateY(Graphs, Value set for Y, Color)
        % ---------------------------------------
        % Get the intersection of the lines with the set value of y and
        % update the upper panel.
        function updateY(self,y0)
            mx = self.mx;
            my = self.my;
            Mx = self.Mx;
            My = self.My;
            x = self.x;
            y = self.y;
            ax = self.g.currentAxes;
            [row,col] = find(my <= y0 & My > y0); % Index of boxes where there are intersections.
            idx = sub2ind(size(my),row,col);
            if(col~=size(my,2))
                slopeSign = sign(y(sub2ind(size(my),row,col+1))-y(idx));
            else
                slopeSign = sign(y(idx)-y(sub2ind(size(my),row,col-1)));
            end
            % Compute x values of the intersections
            X = mx(idx) + ((slopeSign<0) + slopeSign.' .* ((y0 - my(idx))./(My(idx) - my(idx)))) .* (Mx(idx) - mx(idx));

            % Delete previous lines and intersections
            for n = length(ax.Children):-1:1
                if(contains(ax.Children(n).Tag,'derived'))
                    delete(ax.Children(n));
                end
            end

            % Draw new lines and intersections

            for k = 1:size(x,1)
                plot(ax,x(k,:),self.reg(k,:),'-','Color',self.color(k,:),'LineWidth',0.05,'Tag',['derived_Regression' num2str(k)]);
            end
            line(ax,[x(1) x(end)], [y0 y0], 'Color', 'k','LineWidth',1.0,'Tag','derived2');
            for c = 1:size(my,1) % number of Children
                for m = find(row == c)
                    if(~isempty(X(m)))
                        plot(ax,X(m),y0, 'd', 'Color', 'k', 'MarkerSize',3,'MarkerFaceColor',self.color(c,:),'LineWidth',1.0,'Tag',['derived_Children' num2str(c)]);
                    end
                end
            end

        end



        %% Select the figure to analyse
        function selectFigure(self,i,j)
            self.selectFigure@Intersector(i,j);
            warning ('off','all');
            for j = 1:size(self.x,1)
                self.reg(j,:) = polyval(polyfit(self.x(j,:),self.y(j,:),1),self.x(j,:));
            end
            warning ('on','all');
            self.mx = self.boxmin(self.x);
            self.my = self.boxmin(self.reg);
            self.Mx = self.boxMax(self.x);
            self.My = self.boxMax(self.reg);
        end

    end
end