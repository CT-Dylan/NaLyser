classdef CurveIntersector < Intersector
    properties
    end
    methods
        % ----------------------------------------
        % constructor(Graphs)
        % ----------------------------------------
        function self = CurveIntersector(varargin)
            self@Intersector(varargin{:});
            self.className = 'Curve Intersector';

            %evaluate
            self.mx = self.boxmin(self.x);
            self.my = self.boxmin(self.y);
            self.Mx = self.boxMax(self.x);
            self.My = self.boxMax(self.y);
            self.index = 1;

            self.setCallbacks();
            self.update(0,1);
        end



        % ------------- -------------------------------------------------------------------------------------
        % selection(dropdown, Graphs, upper panel, list of figures, axes of the lower panel, parameter index)
        % --------------------------------------------------------------------------------------------------
        % Select the figure to plot from the one created by the current
        % Graphs().
        %
        % selection@Intersector(dd, pIdx);
        function selection(self, dd, pIdx) %% WONT WORK BEFORE Matlab 2019b

            self.selectFigure(find(strcmp(dd.Items,dd.Value)), pIdx);
            %evaluate
            self.mx = self.boxmin(self.x);
            self.my = self.boxmin(self.y);
            self.Mx = self.boxMax(self.x);
            self.My = self.boxMax(self.y);

            self.createFigure();

            self.update(0,pIdx);
        end



        % ---------------------------------------
        % updateX(Graphs, Value set for X, Color)
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

            % Sign of the slope (Forward)
            slopeSign(col~=size(my,2)) = sign(y(sub2ind(size(my), row(col~=size(my,2)), col(col~=size(my,2))+1)) - y(idx(col~=size(my,2))));
            % Sign of the slope (Backward since we are at the end)
            slopeSign(col==size(my,2)) = sign(y(idx(col==size(my,2))) - y(sub2ind(size(my), row(col==size(my,2)), col(col==size(my,2))-1)));

            % Compute y values of the intersections
            Y = my(idx) + ((slopeSign<0) + slopeSign.' .* ((x0 - mx(idx))./(Mx(idx) - mx(idx)))) .* (My(idx) - my(idx));

            % Delete previous lines and intersections
            for n = length(ax.Children):-1:1
                if(contains(ax.Children(n).Tag,'derived'))
                    delete(ax.Children(n));
                end
            end

            % Draw new lines and intersections
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
        % updateY(Graphs, Value set for Y, Color)
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

            % Sign of the slope (Forward)
            slopeSign(col~=size(my,2)) = sign(y(sub2ind(size(my),row(col~=size(my,2)),col(col~=size(my,2))+1))-y(idx(col~=size(my,2))));
            % Sign of the slope (Backward since we are at the end)
            slopeSign(col==size(my,2)) = sign(y(idx(col==size(my,2)))-y(sub2ind(size(my),row(col==size(my,2)),col(col==size(my,2))-1)));

            % Compute x values of the intersections
            X = mx(idx) + ((slopeSign<0) + slopeSign.' .* ((y0 - my(idx))./(My(idx) - my(idx)))) .* (Mx(idx) - mx(idx));

            % Delete previous lines and intersections
            for n = length(ax.Children):-1:1
                if(contains(ax.Children(n).Tag,'derived'))
                    delete(ax.Children(n));
                end
            end

            % Draw new lines and intersections
            line(ax,[x(1) x(end)], [y0 y0], 'Color', 'k','LineWidth',1.0,'Tag','derived2');
            for c = 1:size(my,1) % number of Children
                for m = find(row == c)
                    if(~isempty(X(m)))
                        plot(ax,X(m),y0, 'd', 'Color', 'k', 'MarkerSize',3,'MarkerFaceColor',self.color(c,:),'LineWidth',1.0,'Tag',['derived_Children' num2str(c)]);
                    end
                end
            end
        end


        % ---------------------------------------------------
        % selectFigure(figure, subfigure)
        % ---------------------------------------------------
        function selectFigure(self,i,j)
            self.selectFigure@Intersector(i,j);
            self.mx = self.boxmin(self.x);
            self.my = self.boxmin(self.y);
            self.Mx = self.boxMax(self.x);
            self.My = self.boxMax(self.y);
        end

    end
end