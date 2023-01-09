%% Chip Data Analysis files v1.10 (Matlab 2022b)
%  ----------------------------
%   Script to analyse the data of the chips and plot graphs (transfer
%   characteristics, transfer function,...
%
%   TTF Box files should have the following formalism:
%            chipName_testName_ParameterX.XX_ParameterY.YY_ParameterZ.ZZ_[...]_Type.dat
%   where  Parameter        are parameter names with no digit inside
%          X.XX, Y.YY, Z.ZZ are double with unlimited number of figures
%          Type             is the type of file (Charac,TransFunc,TimeSeries,...)
%  
%
%  Table of content:
%       ° Options to modify
%       ° Extraction of data
%              ° TTF Box
%              ° Keithley 
%       ° Characteristics
%       ° Transfer functions
%       ° Time series
%
%  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
%  Variables
%       ° Current
%       ° Conductivity
%       ° Transfer function
%       ° Voltage (Transfer function)
%
%  Intrinsic parameters
%      TTF Box                          Keithley
%       ° Channel                        ° VDS
%       ° VDS                            ° VGS
%       ° VGS
%       ° Frequency
%       ° Time
%
%  Extrinsic parameters
%      TTF Box                          Keithley
%       ° pH                             ° pH
%       ° Temperature                    ° Temperature
%       ° Start time                     ° Channel
%       ° Position                       ° Start time
%       ° Chip                           ° Position
%       ° Et caetera                     ° Chip
%                                        ° Et caetera
% -------------------------------------------------------------------------
function [ch_Graph, tf_Graph, time_Graph] = main()
ch_Graph = [];
tf_Graph = [];
time_Graph = [];
window = 'screensize';

%% Get instructions and options for the run
addpath(genpath("ExpansionFcts"));
addpath(genpath("Geometry")); 
if(isfile('MainData.mat'))
    
    load('MainData.mat');
    
end
if(isfile('app2EbUTxRJk7tfV6nRL33oDL1hjD.mat')) % If run from application
    % -------------------------------------------------------------------------
    disp('Extracting data from the GUI.')
    load('AppData.mat');
    disp('Data extracted.')
    
    % Set the colours and markers of the curves
    colors = [0.0000 0.4470 0.7410; % Up to 21 colours
              0.8500 0.3250 0.0980;
              0.9290 0.6940 0.1250;
              0.4940 0.1840 0.5560;
              0.4660 0.6740 0.1880;
              0.3010 0.7450 0.9330;
              0.6350 0.0780 0.1840;
              getColors(40)];
    
    if(strcmp(colorPlot , 'gradient'))
        blue = [69,202,255]/255;
        red = [255,27,107]/255;
        colors = [linspace(blue(1),red(1),colorSize)', linspace(blue(2),red(2),colorSize)', linspace(blue(3),red(3),colorSize)'];
    end
    
    lineType = {'-', '--', ':', '-.'}; % Up to 4 line types
    markerType = {'v', '^', 'o', '+', 'x', '.', '*', 'square', 'diamond', '>', '<', 'pentagram', 'hexagram','_','|'}; % Up to 15 marker types

    % -------------------------------------------------------------------------
    else % If run from the code
    % -------------------------------------------------------------------------
    options;  
    % -------------------------------------------------------------------------
end
   
% --------------------------------------------------------------------------
% --------------------------------------------------------------------------

%% Open & Read the data
if(Section_OpenNRead)
    text.textdata ={};
    fetchedParameters2;
    fetchData2;   
end

% --------------------------------------------------------------------------
% --------------------------------------------------------------------------

%% Plot Characteristics
disp('Starting to plot graphs.')
if(Section_Charac)
    disp('Plotting characteristics graphs...')
    ch_Graph = Graphs([chipName '_Characteristics'], ch_Data, colors, lineType, markerType);
    ch_Graph.modifyOptions('outputPath', outputPath, 'png',1, 'fig', 1,'lineWidth',lineWidth,'fontSize',fontSize, 'gridOption', gridOption, 'autoscaleOption', autoscaleOption);
    ch_Graph.setWindowSize(windowOption);
    ch_Graph.createFigure(displayFigure, saveOption, ch_figDisplay, patternG, ...
        ch_xVar, ch_colVar, ch_subFigVar, ch_figVar, ch_lineVar, ch_markerVar);
   
%     if(0)
%         % Copy data
%         Charac_CurrentDist =  Charac_G.expandData(@distance, GateGeometryTable);
%         % Create graph
%         Charac_Dist = Graphs([chipName '_Characteristics'], Charac_CurrentDist, colors, lineType, markerType);
%         Charac_Dist.modifyOptions('outputPath', outputPath, 'png',1, 'fig', 1, 'XScale', 'lin','lineWidth',lineWidth,'fontSize',fontSize);
%         Charac_Dist.createFigure('on', 'on', ch_figDisplay, [], ch_xVar, 'X', 'none', 'none', ch_lineVar, ch_markerVar);
%         %Charac_Dist.analysisLine();
%     end
    filename = join([outputPath 'CharacDataTable.xlsx']);
    writematrix(ch_Data.table ,filename,'Sheet',1);
end


% --------------------------------------------------------------------------
% --------------------------------------------------------------------------

%% Plot Transfer functions
if(Section_Trans)
    disp('Plotting transfer functions graphs...')
    tf_Graph = Graphs([chipName '_Transfer_' TransVar], tf_Data, colors, lineType, markerType);
    tf_Graph.modifyOptions('outputPath', outputPath, 'png',1, 'fig', 1, 'XScale', 'log','lineWidth',lineWidth,'fontSize',fontSize, 'gridOption', gridOption, 'autoscaleOption', autoscaleOption);
    tf_Graph.setWindowSize(windowOption);
    tf_Graph.createFigure(displayFigure, saveOption, tf_figDisplay, patternG, tf_xVar, tf_colVar, tf_subFigVar, tf_figVar, tf_lineVar, tf_markerVar);
    
%     if(0)
%         % Copy data
%         TF_TransVarDist =  TF_G.expandData(@distance, GateGeometryTable);
%         TF_Dist = Graphs([chipName '_TransferDist_' TransVar], TF_TransVarDist, colors, lineType, markerType);
%         TF_Dist.modifyOptions('outputPath', outputPath, 'png',1, 'fig', 1, 'XScale', 'log','lineWidth',lineWidth,'fontSize',fontSize);
%         TF_Dist.createFigure('on', 'on', tf_figDisplay, [], tf_xVar, 'X', 'none','none', tf_lineVar, tf_markerVar);
%         %TF_Dist.analysisLine();
%     end
    filename = join([outputPath 'TFDataTable.xlsx']);
    writematrix(tf_Data.table, filename,'Sheet',1);

end
% --------------------------------------------------------------------------
% --------------------------------------------------------------------------


%% Plot Time Series
if(Section_TimeSeries)
    disp('Plotting time series graphs...')
    time_Graph = Graphs([chipName '_TimeSeries'], time_Data, colors, lineType, markerType);
    time_Graph.modifyOptions('outputPath', outputPath, 'png',1, 'fig', 1,'lineWidth',lineWidth,'fontSize',fontSize, 'gridOption', gridOption, 'autoscaleOption', autoscaleOption);
    time_Graph.setWindowSize(windowOption);
    time_Graph.createFigure(displayFigure, saveOption, time_figDisplay, patternG, time_xVar, time_colVar, time_subFigVar, time_figVar, time_lineVar, time_markerVar);
    filename = join([outputPath 'TimeDataTable.xlsx']);
    writematrix(time_Data.table, filename,'Sheet',1);

end

disp('Finished plotting graphs.')
disp('.')
disp('.')
disp('.')



%% Save data
disp('Saving process data...')
% Get a list of all variables
allvars = whos;

% Identify the variables that ARE NOT graphics handles. This uses a regular
% expression on the class of each variable to check if it's a graphics object
tosave = cellfun(@isempty, regexp({allvars.class}, '^matlab\.(ui|graphics|apps)\.|^Graphs|RunMain'));

% Pass these variable names to save
save('MainData.mat', allvars(tosave).name)
disp('Run completed.')
end


%% Get a list of n different colours
function colors = getColors(n_colors)
x = linspace(0,1,5);
[R,G,B] = ndgrid(x,x,x);
rgb = [R(:) G(:) B(:)];
if (n_colors > floor(size(rgb,1)/3))
    error('You have exceeded the number of available colours.');
end

xyz2rgb = [3.2404542 -0.9692660  0.0556434;
    -1.5371385  1.8760108 -0.2040259;
    -0.4985314  0.0415560  1.0572252];
rgb2xyz = inv(xyz2rgb);
xyz = rgb * rgb2xyz;

mindist2 = inf(size(rgb,1),1);
bgrgb = [0.0000 0.4470 0.7410;
    0.8500 0.3250 0.0980;
    0.9290 0.6940 0.1250;
    0.4940 0.1840 0.5560;
    0.4660 0.6740 0.1880;
    0.3010 0.7450 0.9330;
    0.6350 0.0780 0.1840];
bgxyz = bgrgb * rgb2xyz;

for i = 1:size(bgrgb,1)-1
    dX = bsxfun(@minus,xyz,bgxyz(i,:)); % displacement all colors from bg
    dist2 = sum(dX.^2,2);  % square distance
    mindist2 = min(dist2,mindist2);  % dist2 to closest previously-chosen color
end

lastColor = [1 1 1];
for i = 1:n_colors
    dX = bsxfun(@minus, xyz, lastColor);
    dist2 = sum(dX.^2,2);  % square distance
    mindist2 = min(dist2,mindist2);  % dist2 to closest previously-chosen color
    [~,index] = max(mindist2);  % find the entry farthest from all previously-chosen colors

    lastColor = xyz(index,:);
    colors(i,:) = rgb(index,:);  % save for output
end
colors(colors > 1) = 1;
end