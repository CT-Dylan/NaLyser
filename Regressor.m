classdef Regressor < matlab.mixin.Copyable
    properties
        p % parameters matrix
        v % value vector             v = a * p  where a are the coefficient
        a % coefficient vector
        pName       % parameter names
        dimension   % dimension of the parameter space
        fct         % regression functions ( to put in linear combination )
        
        preFct      % function to apply to the value v before the regression
        postFct     % function to apply to the value vreg after the regression (usually the inverse of preFct) 

        vreg        % value obtained with regression

        % Elements of the Graphical User Interface
        UIFigure    
        UITable     
        PreprocessingfunctionDropDownLabel
        PostprocessingfunctionDropDownLabel
        PreprocessingfunctionDropDown
        PostprocessingfunctionDropDown
        ConfirmButton
        SignDropDown
        SignDropDownLabel
        SignTable
        SignLabel

        express             % Expression of the result
        lefthandExpress     % Left-hand side expression of express
        postCstExpress      % Constant expression

        pDisplay            % Parameters for the curve to display
        vDisplay            % Values for the curve to display

        % Related to the function to launch after pressing the confirm button
        confirmFct
        confirmObj
        confirmArg

    end
    methods
        %% Constructor
        function self = Regressor(varargin)
            self.v = [1;
                      -7;
                      4;
                      8;
                      24;
                      25];
            self.p = [0 -1;
                      1 2;
                      2 0;
                      3 1;
                      4 -2
                      5 0];
            self.pName = {"p1", "p2"};
            self.dimension = size(self.p,2);
            self.fct = {{@(x) power(x,1), @(x) power(x,0)}, {@(x) power(x,1), @(x) power(x,0)}};
            self.vreg = zeros(size(self.v));
            self.preFct = @(x) x;
            self.postFct = @(x) x;
            self.confirmFct = @(x) x;
            self.confirmObj = 0;
            self.confirmArg = {};
        end



        %% Display a graphical user interface to determine the functions to use for the regression
        function setFunctions(self)
            catfun = categorical({'-'},{'-','x','x^2','x^3','x^4','x^5', ...
                      'sqrt(x)','sqrt3(x)','sqrt4(x)','sqrt5(x)', ...
                      '2^x','exp(x)', '10^x', 'log2(x)', 'ln(x)', 'log10(x)', ...
                      'sin(x)', 'cos(x)', 'tan(x)', ...
                      'arcsin(x)','arccos(x)','arctan(x)',...
                      'sinh(x)','cosh(x)','tanh(x)',...
                      'asinh(x)','acosh(x)','atanh(x)'});
            varTable = {};

            catsign = categorical({'+'},{'+','-'});
            signTable = {};

            for i = 1:self.dimension
                varTable{i} = [catfun;catfun;catfun;catfun;catfun;catfun;catfun;catfun;catfun;catfun];
                signTable{i} = [catsign];
            end
            t = table(varTable{:});
            st = table(signTable{:});
            

            % Create UIFigure and hide until all components are created
            self.UIFigure = uifigure('Visible', 'off');
            self.UIFigure.Position = [100 100 640 480];
            self.UIFigure.Name = 'Regressor';

            % Create SignDropDown
            self.SignDropDown = uidropdown(self.UIFigure);
            self.SignDropDown.Position = [297 432 40 22];
            self.SignDropDown.Items = {'+','-'};
            % Create SignDropDownLabel
            self.SignDropDownLabel = uilabel(self.UIFigure);
            self.SignDropDownLabel.HorizontalAlignment = 'center';
            self.SignDropDownLabel.Position = [297 455 40 22];
            self.SignDropDownLabel.Text = 'Sign y';

            % Create PreprocessingfunctionDropDownLabel
            self.PreprocessingfunctionDropDownLabel = uilabel(self.UIFigure);
            self.PreprocessingfunctionDropDownLabel.HorizontalAlignment = 'right';
            self.PreprocessingfunctionDropDownLabel.Position = [20 432 127 22];
            self.PreprocessingfunctionDropDownLabel.Text = 'Preprocessing fct(y)';

            % Create PreprocessingfunctionDropDown
            self.PreprocessingfunctionDropDown = uidropdown(self.UIFigure);
            self.PreprocessingfunctionDropDown.Position = [162 432 100 22];
            self.PreprocessingfunctionDropDown.Items = {'x','x^2','x^3','x^4','x^5', ...
                      'sqrt(x)','sqrt3(x)','sqrt4(x)','sqrt5(x)', ...
                      '2^x','exp(x)', '10^x', 'log2(x)', 'ln(x)', 'log10(x)', ...
                      'sin(x)', 'cos(x)', 'tan(x)', ...
                      'arcsin(x)','arccos(x)','arctan(x)',...
                      'sinh(x)','cosh(x)','tanh(x)',...
                      'asinh(x)','acosh(x)','atanh(x)'};

            % Create PostprocessingfunctionDropDownLabel
            self.PostprocessingfunctionDropDownLabel = uilabel(self.UIFigure);
            self.PostprocessingfunctionDropDownLabel.HorizontalAlignment = 'right';
            self.PostprocessingfunctionDropDownLabel.Position = [372 432 132 22];
            self.PostprocessingfunctionDropDownLabel.Text = 'Postprocessing fct(y)';

            % Create PostprocessingfunctionDropDown
            self.PostprocessingfunctionDropDown = uidropdown(self.UIFigure);
            self.PostprocessingfunctionDropDown.Position = [519 432 100 22];
            self.PostprocessingfunctionDropDown.Items = {'x','x^2','x^3','x^4','x^5', ...
                      'sqrt(x)','sqrt3(x)','sqrt4(x)','sqrt5(x)', ...
                      '2^x','exp(x)', '10^x', 'log2(x)', 'ln(x)', 'log10(x)', ...
                      'sin(x)', 'cos(x)', 'tan(x)', ...
                      'arcsin(x)','arccos(x)','arctan(x)',...
                      'sinh(x)','cosh(x)','tanh(x)',...
                      'asinh(x)','acosh(x)','atanh(x)'};

            % Create UITable
            self.UITable = uitable(self.UIFigure,'Data',t,'ColumnEditable',true);
            self.UITable.ColumnName = self.pName;
            self.UITable.RowName = {};
            self.UITable.Position = [20 137 599 262];

            % Create SignLabel
            self.SignLabel = uilabel(self.UIFigure);
            self.SignLabel.HorizontalAlignment = 'left';
            self.SignLabel.Position = [20 111 140 22];
            self.SignLabel.Text = 'Signs of the parameters';

            % Create SignTable
            self.SignTable = uitable(self.UIFigure,'Data',st,'ColumnEditable',true);
            self.SignTable.ColumnName = self.pName;
            self.SignTable.RowName = {};
            self.SignTable.Position = [20 56 599 52];

            % Create ConfirmButton
            self.ConfirmButton = uibutton(self.UIFigure, 'push');
            self.ConfirmButton.FontSize = 18;
            self.ConfirmButton.Position = [271 13 100 30];
            self.ConfirmButton.Text = 'Confirm';
            self.ConfirmButton.ButtonPushedFcn = @(btn, ui) ConfirmButtonPushed(btn);

            % Show the figure after all components are created
            self.UIFigure.Visible = 'on';



            % Button pushed function: ConfirmButton
            function ConfirmButtonPushed(btn, ui)
                % Table
                self.fct = {{@(x) power(x,0)}};
                self.express = " ";
                for i = 1:size(self.UITable.DisplayData,2)
                    funStringArray = setxor(string(self.UITable.Data{:,i}),'-','stable');
                    for j = 1:length(funStringArray)
                        if(strcmp(string(self.SignTable.Data{1,i}),"+"))
                            [self.fct{i+1}{j}, term] = getFunction(funStringArray(j), self.pName{i});
                        else
                            [self.fct{i+1}{j}, term] = getFunction(funStringArray(j), join(["(-",self.pName{i},")"],""));
                        end
                        self.express = [self.express; term];
                    end
                end
                
                % Preprocessing dropdown
                leftArgument = 'y';
                if(strcmp(self.SignDropDown.Value,"-"))
                    leftArgument = join(["-",leftArgument],"");
                end
                [self.preFct, term] = getFunction(self.PreprocessingfunctionDropDown.Value, leftArgument);
                self.lefthandExpress = join([term," = "],"");
                

                % Postprocessing dropdown
                [self.postFct, self.postCstExpress] = getFunction(self.PostprocessingfunctionDropDown.Value, "a0");
                for k = 1:length(self.express)-1
                    [self.postFct, term] = getFunction(self.PostprocessingfunctionDropDown.Value, join(["a",num2str(k)]," "));
                    self.postCstExpress = [self.postCstExpress; term];
                end


                self.regression();
                self.displayPlot();

                self.confirmFct(self.confirmObj, self.confirmArg);
            end



            % Getting actual MATLAB function
            function [fct, term] = getFunction(fctString, pName)
                switch fctString
                    case '-'
                        fct = [];
                        term = "";
                    case 'x'
                        fct = @(x) x;
                        term = pName;
                    case 'x^2'
                        fct = @(x) x.^2;
                        term = join(["(",pName,")²"],"");
                    case 'x^3'
                        fct = @(x) x.^3;
                        term = join(["(",pName,")³"],"");
                    case 'x^4'
                        fct = @(x) x.^4;
                        term = join(["(",pName,")^4"],"");
                    case 'x^5'
                        fct = @(x) x.^5;
                        term = join("(",[pName,")^5"],"");
                    case 'sqrt(x)'
                        fct = @sqrt;
                        term = join(["√",pName],"");
                    case 'sqrt3(x)'
                        fct = @(x) nthroot(x,3);
                        term = join(["³√",pName],"");
                    case 'sqrt4(x)'
                        fct = @(x) nthroot(x,4);
                        term = join([" ","4√",pName],"");
                    case 'sqrt5(x)'
                        fct = @(x) nthroot(x,5);
                        term = join([" ","5√",pName],"");
                    case '2^x' 
                        fct = @(x) power(2,x);
                        term = join([" ","2^",pName],"");
                    case 'exp(x)' 
                        fct = @exp;
                        term = join(["exp(",pName,")"],"");
                    case '10^x' 
                        fct = @(x) power(10,x);
                        term = join([" ","10^",pName],"");
                    case 'log2(x)' 
                        fct = @log2;
                        term = join(["log2(",pName,")"],"");
                    case 'ln(x)'
                        fct = @log;
                        term = join(["ln(",pName,")"],"");
                    case 'log10(x)'
                        fct = @log10;
                        term = join(["log(",pName,")"],"");
                    case 'sin(x)'
                        fct = @sin;
                        term = join(["sin(",pName,")"],"");
                    case 'cos(x)' 
                        fct = @cos;
                        term = join(["cos(",pName,")"],"");
                    case 'tan(x)'
                        fct = @tan;
                        term = join(["tan(",pName,")"],"");
                    case 'arcsin(x)'
                        fct = @asin;
                        term = join(["arcsin(",pName,")"],"");
                    case 'arccos(x)'
                        fct = @acos;
                        term = join(["arccos(",pName,")"],"");
                    case 'arctan(x)'
                        fct = @atan;
                        term = join(["arctan(",pName,")"],"");
                    case 'sinh(x)'
                        fct = @sinh;
                        term = join(["sinh(",pName,")"],"");
                    case 'cosh(x)'
                        fct = @cosh;
                        term = join(["cosh(",pName,")"],"");
                    case 'tanh(x)'
                        fct = @tanh;
                        term = join(["tanh(",pName,")"],"");
                    case 'asinh(x)'
                        fct = @asinh;
                        term = join(["arcsinh(",pName,")"],"");
                    case 'acosh(x)'
                        fct = @acosh;
                        term = join(["arccosh(",pName,")"],"");
                    case 'atanh(x)'
                        fct = @atanh;
                        term = join(["arctanh(",pName,")"],"");
                end
            end
        
        end

        

        %% Set the parameters and values for the regression
        function setPoints(self, values, parameters, parameterNames) % Columns
            self.v = values;
            self.p = parameters;
            self.pName = parameterNames;
            self.dimension = size(self.p,2);
            self.vreg = zeros(size(self.v));
        end



        %% Start the regression
        function [a, vreg] = regression(self)
            
            fctApplied = [];
            fctAppliedDisplay = [];
            matrixSize = 0;
        
            % Get a grid of parameters for the display 
            division = 21;
            self.pDisplay = zeros(division, size(self.p,2));
            self.pDisplay(:,1) = linspace(min(self.p(:,1)), max(self.p(:,1)), division);
            pCoordinates = self.pDisplay(:,1);
            for k = 2:size(self.p,2)
                sizeMat = size(pCoordinates,1);
                pCoordinates = repmat(pCoordinates, division,1);
                self.pDisplay(:,k) = linspace(min(self.p(:,k)), max(self.p(:,k)), division);
                column = repmat(self.pDisplay(:,k).', sizeMat,1);
                pCoordinates(:,k) = reshape(column, numel(column),1);
            end
            
            % Evaluate the function of parameter
            for i = 1:length(self.fct)
                for j = 1:length(self.fct{i})
                    matrixSize = matrixSize + 1;
                    if(i <= 1)
                        fctApplied(:, matrixSize) = arrayfun(self.fct{i}{j}, self.p(:, 1));
                        fctAppliedDisplay(:, matrixSize) = arrayfun(self.fct{i}{j}, pCoordinates(:, 1));
                    else
                        if(strcmp(string(self.SignTable.Data{1,i-1}),"+"))
                            fctApplied(:, matrixSize) = arrayfun(self.fct{i}{j}, self.p(:, i-1));
                            fctAppliedDisplay(:, matrixSize) = arrayfun(self.fct{i}{j}, pCoordinates(:, i-1));
                        else
                            fctApplied(:, matrixSize) = arrayfun(self.fct{i}{j}, -self.p(:, i-1));
                            fctAppliedDisplay(:, matrixSize) = arrayfun(self.fct{i}{j}, -pCoordinates(:, i-1));
                        end
                    end
                end
            end

            % Form the left-hand side matrix
            if(strcmp(self.SignDropDown.Value,"+"))
                values = self.preFct(self.v);
            else
                values = self.preFct(-self.v);
            end
            filter = ~(isinf(values)|isnan(values));
            b = fctApplied(filter,:).' * values(filter);
            A = fctApplied(filter,:).' * fctApplied(filter,:);
            self.a = A\b;
            
            matrixSize = 0;
            self.vreg = zeros(size(self.v));
            self.vDisplay = zeros(size(pCoordinates,1),1);
            for i = 1:length(self.fct)
                for j = 1:length(self.fct{i})
                    matrixSize = matrixSize + 1;
                    self.vreg = self.vreg + self.a(matrixSize) .* fctApplied(:, matrixSize);
                    self.vDisplay = self.vDisplay + self.a(matrixSize) .* fctAppliedDisplay(:, matrixSize);
                end
            end

            a = self.a;
            self.vreg = self.postFct(self.vreg);
            if(strcmp(self.SignDropDown.Value,"-"))
                self.vreg = - self.vreg;
            end
            vreg = self.vreg;
            
            self.vDisplay = self.postFct(self.vDisplay);
            if(strcmp(self.SignDropDown.Value,"-"))
                self.vDisplay = - self.vDisplay;
            end
            for l = 1:size(pCoordinates, 2)
                [tmp1,tmp2, idcs(:,l)] = unique(pCoordinates(:,l));
            end
            self.vDisplay = accumarray(idcs, self.vDisplay).';

            % Display expression
            righthandExpress = num2str(a(1));
            for j = 2:length(a)
                righthandExpress = join([righthandExpress, join([num2str(a(j)), self.express(j)],"")]," + ");
            end
            
            disp("Total expression:")
            out = join([self.lefthandExpress, righthandExpress],"");
            disp(out)
        end



        %% Define the function to launch when the confirm button is pressed
        function setConfirmFct(self, obj, fct, varargin)
            self.confirmFct = fct;
            self.confirmObj = obj;
            self.confirmArg = varargin;
        end



        %% Display the plot of the regression
        function displayPlot(self)
            figure("Name","Regression problem")
        
            switch(self.dimension)
                case 1
                    plot(self.p, self.v, "diamond", "MarkerEdgeColor", 'k', "MarkerFaceColor","b")
                    hold on;

                    plot(self.p, self.vreg, "o", "MarkerEdgeColor", 'k', "MarkerFaceColor","g")
            
                    plot(self.pDisplay, self.vDisplay, "LineWidth", 3.0, "Color", [0.5 0.5 0]);
                case 2
                    plot3(self.p(:,1), self.p(:,2), self.v, "diamond", "MarkerEdgeColor", 'k', "MarkerFaceColor","b")
                    hold on;
                    
                    plot3(self.p(:,1), self.p(:,2), self.vreg, "o", "MarkerEdgeColor", 'k', "MarkerFaceColor","g")
                    
                    surf(self.pDisplay(:,1), self.pDisplay(:,2), self.vDisplay);
                
                otherwise
                    disp("There are too many dimensions to plot.")
            end
        end



        %% Get the projection of the regression curve obtained for a given value of parameter
        function [x,y] = getProjection(self, pName, pValue)
            division = 21;
            x = zeros(division, size(self.p,2)-1);
            filter = logical(zeros(size(self.a)));
            fctApplied = [];

            pIdx = 1 + find(matches(self.pName, pName));
            
            % Prepare the x matrix while removing the specified parameter
            xIdx = 0;
            xCoordinates = [];
            for i = 2:length(self.fct)
                if(i ~= pIdx)
                    xIdx = xIdx + 1;
                    x(:, xIdx) = linspace(min(self.p(:,i-1)), max(self.p(:,i-1)), division);
                    if(xIdx == 1)
                        xCoordinates = x(:, xIdx); 
                    else
                        sizeMat = size(xCoordinates,1);
                        xCoordinates = repmat(xCoordinates, division,1);
                        column = repmat(x(:,xIdx).', sizeMat,1);
                        xCoordinates(:,xIdx) = reshape(column, numel(column),1);
                    end
                end
            end

            % Getting the new expression
            cst = self.a(1);
            termIdx = 1;
            express = "";
            matrixSize = 1;
            fctApplied(:, matrixSize) = arrayfun(self.fct{1}{1}, xCoordinates(:,1));
            filter(1) = 1;
            xIdx = 0;
            for i = 2:length(self.fct)
                if(i ~= pIdx)
                    xIdx = xIdx + 1;
                end
                for j = 1:length(self.fct{i})
                    termIdx = termIdx + 1;
                    if(i == pIdx)
                        if(strcmp(string(self.SignTable.Data{1,i-1}),"+"))
                            cst = cst + self.a(termIdx) * self.fct{i}{j}(pValue);
                        else
                            cst = cst + self.a(termIdx) * self.fct{i}{j}(-pValue);
                        end
                    else
                        filter(termIdx) = 1;
                        express = join([express, join([num2str(self.a(termIdx)), self.express(termIdx)],"")]," + ");
                        matrixSize = matrixSize + 1;
                        fctApplied(:, matrixSize) = arrayfun(self.fct{i}{j}, xCoordinates(:, xIdx));
                    end
                end
            end

            y = zeros(size(xCoordinates,1),1);
            newA = self.a(filter);
            newA(1) = cst;
            y = fctApplied * newA;
            y = self.postFct(y);

            express = join([self.lefthandExpress, num2str(cst), express],"");
            
            disp(express)
        end
    end
end