%% Loop (loop number, ranges of the loops to do (ex: "1:8"), function to execute, arguments of function)
% Used as a recursive version of a nested loops 
function Loop(loop, rangeCells, evalFunc, varargin)

    if(~isnan(str2num(rangeCells{loop})))
    for i = str2num(rangeCells{loop})
        if(loop >= length(rangeCells))
            % End sequence, it is the last loop
            evalFunc(varargin{:},i);
        else
            % Continue with another loop
            Loop(loop+1, rangeCells, evalFunc, varargin{:}, i);
        end
    end
    else
        if(loop >= length(rangeCells))
            % End sequence, it is the last loop
            evalFunc(varargin{:},':');
        else 
            % Continue with another loop
            Loop(loop+1, rangeCells, evalFunc, varargin{:}, ':');
        end
    end
    
end