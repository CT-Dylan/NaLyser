disp('Searching for data...')

if(strcmp(Machine, 'TTF Box'))
    %% Characteristics
    if(~isempty(ch_fetchedP) && Section_Charac)
        disp('Characteristics data found.')
        [ch_Data, ch_parametersList, SavedTableData] = getConfirmationInfo('Ch', pM);

        disp('Reading TTF Box files.')
        for file = 1:length(ch_DATFileArray)
            disp(['Reading ' ch_DATFileArray(file, 1).name '...']);

            % Get the extrinsic parameters of the file
            dataTableRow = getExtrinsicParameters(file, ch_fetchedP, ch_parametersList, length(ch_parametersList)+1, SavedTableData);

            % Get the intrinsic parameter values from the file data (VDS,
            % VGS, Channel)
            fileData = importdata([Path ch_DATFileArray(file,1).name]);
            VGS_lim = {};
            VDS_lim = {};
            infoLine = 5;

            sweepVoltage = string(extractBetween(fileData.textdata{infoLine},"vs ",")"));
            if(strcmp(sweepVoltage,"GS"))
                stepVoltage = "DS";
                swVIdx = find(strcmp(SavedTableData.Name(1:end,1), "VGS"));
                stVIdx = find(strcmp(SavedTableData.Name(1:end,1), "VDS"));
            else
                stepVoltage = "GS";
                swVIdx = find(strcmp(SavedTableData.Name(1:end,1), "VDS"));
                stVIdx = find(strcmp(SavedTableData.Name(1:end,1), "VGS"));
            end

            if(contains(fileData.textdata{infoLine+1}, sweepVoltage))
                swV_lim = str2double( regexp(fileData.textdata{infoLine+1}, '[\d.]+|-[\d.]+', 'match') );
            elseif(contains(text.textdata{infoLine+1}, stepVoltage))
                stV_lim = str2double( regexp(fileData.textdata{infoLine+1}, '[\d.]+|-[\d.]+', 'match') );
            end
            if(contains(fileData.textdata{infoLine+2}, stepVoltage))
                stV_lim = str2double( regexp(fileData.textdata{infoLine+2}, '[\d.]+|-[\d.]+', 'match') );
            elseif(contains(fileData.textdata{infoLine+2}, sweepVoltage))
                swV_lim = str2double( regexp(fileData.textdata{infoLine+2}, '[\d.]+|-[\d.]+', 'match') );
            end

            swV = [swV_lim(2):(swV_lim(3)-swV_lim(2))/(swV_lim(1)-1):swV_lim(3)] * prefixMultiplier(string(SavedTableData.Unit_Prefix(swVIdx)));
            stV = [stV_lim(2):(stV_lim(3)-stV_lim(2))/(stV_lim(1)-1):stV_lim(3)] * prefixMultiplier(string(SavedTableData.Unit_Prefix(stVIdx)));
            L_swV = length(swV);
            L_stV = length(stV);

            % Order of magnitude multiplier
            ooM = 1;
            if(contains(fileData.textdata{infoLine+5}, "uA"))
                ooM = 1e-6;
            elseif(contains(fileData.textdata{infoLine+5}, "mA"))
                ooM = 1e-3;
            end
            ooM = ooM * prefixMultiplier(string(SavedTableData.Unit_Prefix(1)));

            % Read data
            for col = 2:size(fileData.data,2)
                dataTableRow(1, stVIdx) = stV(1 + mod(col-2, L_stV));
                dataTableRow(1, strcmp(SavedTableData.Name(1:end,1), "Channel")) = 1 + floor((col-2)/L_stV);
                swVTableRow = repmat(dataTableRow, L_swV, 1);
                swVTableRow(:, swVIdx) = swV.';

                swVTableRow(:, 1) = fileData.data(:, col) .* ooM;
                ch_Data.add2Table(swVTableRow);
            end
        end
        ch_Data.filter(SavedTableData(2:end,:));
        if(~isempty(patternG))
            ch_Data.keepSubfigure(SavedTableData(2:end,:), patternG);
        end
        ch_Data.convertTable2Values();
        disp('Finished reading.')
    end

    %% Transfer function
    if(~isempty(tf_fetchedP) && Section_Trans)
        disp('Transfer function files found.')
        [tf_Data, tf_parametersList, SavedTableData] = getConfirmationInfo('Tf', pM);

        disp('Reading transfer function files...')
        for file = 1:length(tf_DATFileArray)
            disp(['Reading ' tf_DATFileArray(file, 1).name '...'])

            % Get the extrinsic parameters of the file
            dataTableRow = getExtrinsicParameters(file, tf_fetchedP, tf_parametersList, length(tf_parametersList)+1, SavedTableData);

            % Get the intrinsic parameter values from the file data (VDS,
            % VGS, Channel)
            fileData = importdata([Path tf_DATFileArray(file,1).name]);
            infoLine = 5;

            % Differentiate simple transfer function from continuous
            % measurement with cycles.
            if(contains(fileData.textdata{2}, 'Continuous Measurement'))
                shift = 1;
            else
                shift = 0;
            end

            % Set voltages
            WP = str2double( regexp(fileData.textdata{infoLine + shift}, '[\d.]+|-[\d.]+', 'match') );
            parameterIdx = find(strcmp(SavedTableData.Name(1:end,1), "VGS"));
            dataTableRow(1, parameterIdx) = WP(1) * prefixMultiplier(string(SavedTableData.Unit_Prefix(parameterIdx)));
            parameterIdx = find(strcmp(SavedTableData.Name(1:end,1), "VDS"));
            dataTableRow(1, parameterIdx) = WP(2) * prefixMultiplier(string(SavedTableData.Unit_Prefix(parameterIdx)));
            parameterIdx = find(strcmp(SavedTableData.Name(1:end,1), "Tint"));
            dataTableRow(1, parameterIdx) = str2double( regexp(fileData.textdata{infoLine + 1 + shift}, '[\d.]+|-[\d.]+', 'match') );

            frequencies = cell2mat(cellfun(@str2num, fileData.textdata(infoLine + 9 + shift:end),'un',0));
            L_freq = length(frequencies);
            channelOrder = str2double( regexp(fileData.textdata{infoLine + 7 + shift}, '[\d.]+|-[\d.]+', 'match') );

            % Order of magnitude multiplier
            ooM = 1;
            if(contains(fileData.textdata{infoLine+4}, "uS"))
                ooM = 1e-6;
            elseif(contains(fileData.textdata{infoLine+4}, "mS"))
                ooM = 1e-3;
            end
            ooM = ooM * prefixMultiplier(string(SavedTableData.Unit_Prefix(1)));

            % Read data
            for col = 1:size(fileData.data,2)
                dataTableRow(1, strcmp(SavedTableData.Name(1:end,1), "Channel")) = channelOrder(col);
                freqTableRow = repmat(dataTableRow, L_freq, 1);
                parameterIdx = find(strcmp(SavedTableData.Name(1:end,1), "Freq"));
                freqTableRow(:, parameterIdx) = frequencies  * prefixMultiplier(string(SavedTableData.Unit_Prefix(parameterIdx)));
                freqTableRow(:, 1) = fileData.data(2:end, col) .* ooM;
                tf_Data.add2Table(freqTableRow);
            end
        end
        tf_Data.filter(SavedTableData(2:end,:));
        if(~isempty(patternG))
            tf_Data.keepSubfigure(SavedTableData(2:end,:), patternG);
        end
        tf_Data.convertTable2Values();
        disp('Finished reading.')
    end

    %% Time series
    if(~isempty(time_fetchedP) && Section_TimeSeries)
        disp('Time Series data found.')
        [time_Data, time_parametersList, SavedTableData] = getConfirmationInfo('Time', pM);

        disp('Reading TTF Box files.')
        for file = 1:length(time_DATFileArray)
            disp(['Reading ' time_DATFileArray(file, 1).name '...'])

            % Get the extrinsic parameters of the file
            dataTableRow = getExtrinsicParameters(file, time_fetchedP, time_parametersList, length(time_parametersList)+1, SavedTableData);


            % Get the intrinsic parameter values from the file data (VDS,
            % VGS, Channel)
            fileData = importdata([Path time_DATFileArray(file,1).name]);
            infoLine = 5;

            % Set voltages
            WP = str2double( regexp(fileData.textdata{infoLine}, '[\d.]+|-[\d.]+', 'match') );
            parameterIdx = find(strcmp(SavedTableData.Name(1:end,1), "VGS"));
            dataTableRow(1, parameterIdx) = WP(1) * prefixMultiplier(string(SavedTableData.Unit_Prefix(parameterIdx)));
            parameterIdx = find(strcmp(SavedTableData.Name(1:end,1), "VDS"));
            dataTableRow(1, parameterIdx) = WP(2) * prefixMultiplier(string(SavedTableData.Unit_Prefix(parameterIdx)));

            % Order of magnitude multiplier
            ooM = 1;
            if(contains(fileData.textdata{infoLine+2}, "uA"))
                ooM = 1e-6;
            elseif(contains(fileData.textdata{infoLine+2}, "mA"))
                ooM = 1e-3;
            end
            ooM = ooM * prefixMultiplier(string(SavedTableData.Unit_Prefix(1)));

            times = cell2mat(cellfun(@str2num, fileData.textdata(infoLine+7:end, 1),'un',0));
            L_times = length(times);
            channelOrder = str2double( regexp(fileData.textdata{infoLine + 4}, '[\d.]+|-[\d.]+', 'match') );

            % Read data
            for col = 1:size(fileData.data,2)
                dataTableRow(1, strcmp(SavedTableData.Name(1:end,1), "Channel")) = channelOrder(col);
                timeTableRow = repmat(dataTableRow, L_times, 1);
                parameterIdx = find(strcmp(SavedTableData.Name(1:end,1), "Time"));
                timeTableRow(:, parameterIdx) = times * prefixMultiplier(string(SavedTableData.Unit_Prefix(parameterIdx)));
                timeTableRow(:, 1) = fileData.data(3:end, col) .* ooM;
                time_Data.add2Table(timeTableRow);
            end
        end
        time_Data.filter(SavedTableData(2:end,:));
        if(~isempty(patternG))
            time_Data.keepSubfigure(SavedTableData(2:end,:), patternG);
        end
        time_Data.convertTable2Values();
        disp('Finished reading.')


    end

elseif(strcmp(Machine, 'Keithley'))

    disp('Work in progress...')
    %% Characteristics
    if(~isempty(ch_fetchedP) && Section_Charac)
        disp('Characteristics data found.')
        [ch_Data, ch_parametersList, SavedTableData] = getConfirmationInfo('Ch', pM);

        disp('Reading Keithley files.')
        run = {};
        runV = {};
        runI = {};
        while(contains(ED.sheetnames(ED.readIdx),"Settings"))
            sheetData = ED.read(ED.readIdx); % Get Setting sheet content

            %Run number
            runPos = find(contains(table2array(sheetData(:,1)),'Run'));
            run = [run; regexp(sheetData{runPos,1}, '\d+','match','forceCellOutput','once')]; % Find Run numbers in the Setting sheet

            % Column names of the data sheets
            namePos = find(matches(table2array(sheetData(:,1)),'Name'));
            nameV = sheetData{namePos,2:end};
            [prefix, suffix] =  cellfun(@(x) splitKeithleyColumnName(x),nameV,'UniformOutput',false);
            runV = [runV;  cellfun(@(x,y) join([x,"V",y],""), prefix, suffix)];
            runI = [runI; cellfun(@(x,y) join([x,"I",y],""), prefix, suffix)];

            % Get the number of points
            pointsPos = find(matches(table2array(sheetData(:,1)),'Number of Points'));
            for i = 1:length(pointsPos)
                nbPoints(i,:) = cellfun(@str2num,sheetData{pointsPos(i), 2:end});

                starts(i,:) = sheetData{pointsPos(i)-3, 2:end};
                steps(i,:) = sheetData{pointsPos(i)-1, 2:end};
                stops(i,:) = sheetData{pointsPos(i)-2, 2:end};

            end
        end

        run = cellfun(@str2num,run);
        runTableIdx = find(strcmp(SavedTableData.Name(1:end,1), "Run"));
        for sheet = 1:length(ch_DATFileArray)
            disp(['Reading ' ch_DATFileArray(sheet, 1).name ' > ' ch_DATFileArray(sheet, 1).sheet ' ...']);

            % Get the extrinsic parameters of the file
            [dataTableRow, rest] = getExtrinsicParameters(sheet, ch_fetchedP, ch_parametersList, length(ch_parametersList)+1, SavedTableData);

            runSettingIdx = find(run == dataTableRow(runTableIdx));
            % Get the intrinsic parameter values from the file data (VDS,
            % VGS, Channel)
            sheetData = ED.read(ED.readIdx); % Get Setting sheet content
            gatePos = contains(runV(runSettingIdx,:), "Gate");
            if(sum(gatePos))
                VGS = sheetData{:, contains(sheetData.Properties.VariableNames, runV{runSettingIdx, gatePos})};
                VGSVector = str2num([starts{runSettingIdx, gatePos} ':' steps{runSettingIdx, gatePos} ':' stops{runSettingIdx, gatePos}]);
                VGS = correctVoltage(VGS, VGSVector.');
                parameterIdx = find(strcmp(SavedTableData.Name(1:end,1), "VGS"));
                dataTableRows = repmat(dataTableRow, numel(VGS), 1);
                dataTableRows(:, parameterIdx) = reshape(VGS, numel(VGS), 1);
            else
                dataTableRows = dataTableRow;
            end

            ooM = prefixMultiplier(string(SavedTableData.Unit_Prefix(1)));

            pos = 1;
            posLimit = 1;
            if(~isempty(rest.keys))
                posLimit = length(rest.keys);
            end
            while((pos <= posLimit) && (pos <= length(nbPoints(runTableIdx,:))))
                if((nbPoints(runTableIdx, pos) > 0) & (gatePos(pos) ~= 1))
                    if(~isempty(rest.keys))
                        for r = 1:length(rest.values(pos).v)
                            dataTableRows(:, rest.values(pos).v(r).idx) = repmat(rest.values(pos).v(r).val, size(dataTableRows,1), 1);
                        end
                    end
                    VDS = sheetData{:, contains(sheetData.Properties.VariableNames, runV{runSettingIdx, pos})};
                    VDSVector = str2num([starts{runSettingIdx, pos} ':' steps{runSettingIdx, pos} ':' stops{runSettingIdx, pos}]);
                    VDS = correctVoltage(VDS, VDSVector.');
                    parameterIdx = find(strcmp(SavedTableData.Name(1:end,1), "VDS"));
                    if(size(dataTableRows,1) ~= numel(VDS))
                        dataTableRows = repmat(dataTableRows, numel(VDS), 1);
                    end
                    dataTableRows(:, parameterIdx) = reshape(VDS, numel(VDS), 1);

                    ID = sheetData{:, contains(sheetData.Properties.VariableNames, runI{runSettingIdx, pos})};
                    if(~all(size(VDS) == size(ID)))
                        ID = sheetData{:, find(contains(sheetData.Properties.VariableNames, runV{runSettingIdx, pos})) - 1} .* ooM;
                    end
                    dataTableRows(:, 1) = reshape(ID, numel(ID), 1);

                    ch_Data.add2Table(dataTableRows);
                end

                pos = pos+1;
            end
        end
        ch_Data.filter(SavedTableData(2:end,:));
        if(~isempty(patternG))
            ch_Data.keepSubfigure(SavedTableData(2:end,:), patternG);
        end
        ch_Data.convertTable2Values();
        disp('Finished reading.')
    end


end
disp('Reading data section completed. Proceeding to the next step.')
disp('.')
disp('.')
disp('.')



%--------------------------------------------------------------------------
%% Functions
%--------------------------------------------------------------------------
% Split the name of a column of a given sheet of a Keithley file, which was found
% in a Setting sheet, into what comes before and after the "V" character.
function [prefix, suffix] = splitKeithleyColumnName(name)
a = split(name,"-");
La = length(a);
if(La == 1)
    b = split(a{1},"V");
    prefix = b{1};
    suffix = "";
elseif(La > 1)
    for sa = 1:La
        if(endsWith(a{sa}, "V"))
            b = join(a(1:sa),"");
            c = split(b{1}, "V");
            prefix = c{1};
            suffix = join(["", a(sa+1:end)],"_");
        end
    end
else
    error("Invalid rowname");
end
end



% Get the factor to multiply from a given international unit prefix
function magnitudeMultiplier = prefixMultiplier(prefix)
magnitudeMultiplier = 1;
switch prefix
    case "q"
        magnitudeMultiplier = 1e30;
    case "r"
        magnitudeMultiplier = 1e27;
    case "y"
        magnitudeMultiplier = 1e24;
    case "z"
        magnitudeMultiplier = 1e21;
    case "a"
        magnitudeMultiplier = 1e18;
    case "f"
        magnitudeMultiplier = 1e15;
    case "p"
        magnitudeMultiplier = 1e12;
    case "n"
        magnitudeMultiplier = 1e9;
    case "$\mu$"
        magnitudeMultiplier = 1e6;
    case "m"
        magnitudeMultiplier = 1e3;
    case "c"
        magnitudeMultiplier = 1e2;
    case "d"
        magnitudeMultiplier = 1e1;
    case "-"
    case "da"
        magnitudeMultiplier = 1e-1;
    case "h"
        magnitudeMultiplier = 1e-2;
    case "k"
        magnitudeMultiplier = 1e-3;
    case "M"
        magnitudeMultiplier = 1e-6;
    case "G"
        magnitudeMultiplier = 1e-9;
    case "T"
        magnitudeMultiplier = 1e-12;
    case "P"
        magnitudeMultiplier = 1e-15;
    case "E"
        magnitudeMultiplier = 1e-18;
    case "Z"
        magnitudeMultiplier = 1e-21;
    case "Y"
        magnitudeMultiplier = 1e-24;
    case "R"
        magnitudeMultiplier = 1e-27;
    case "Q"
        magnitudeMultiplier = 1e-30;
    otherwise
        error("Unit Prefix not recognised.")
end
end



% Extract information saved from a Confirmation object
function [data, parametersList, SavedTableData] = getConfirmationInfo(type, parameterManager)
load(['ParameterManager' type '.mat']);
parametersList = parameterManager.makeList(SavedTableData(2:end, :));

prefix = string(SavedTableData.Unit_Prefix(1));
if(strcmp(prefix, "-"))
    prefix = "";
end
name = string(extractBefore(SavedTableData.Display_Name{1},"$"+wildcardPattern+"$"));
data = Data(name, join([name,...
    string(extract(SavedTableData.Display_Name(1),"$"+wildcardPattern+"$"))],""), ...
    join([prefix, SavedTableData.Unit{1}],""), parametersList);

data.createTable();
end



% Get the extrinsic parameters of a TTF Box file
function [dataTableRow, rest] = getExtrinsicParameters(file, fetchedP, parametersList, L, SavedTableData)
dataTableRow = nan(1, L);
rest = Dictionary();
fileParameters = fieldnames(fetchedP);

parameterIdx = find(strcmp(SavedTableData.Name(1:end,1), "File"));
value = fetchedP.File(file).v;
dataTableRow(1, parameterIdx) = value;

% Get the extrinsic parameters of the file (except File since
% it is already done)
for p = 2:length(fileParameters)
    parameterIdx = find(strcmp(SavedTableData.Name(1:end,1), fileParameters{p}));
    value = fetchedP.(fileParameters{p})(file).v;
    numValue = str2double(value);
    if(~isnan(numValue)) % If the value is numerical
        dataTableRow(1, parameterIdx) = numValue;

    elseif(isstruct(value)) % If the value is a struct
        flds = fields(value);
        for f = 1:length(flds)
            if(isnan(rest.findparameter(flds{f})))
                rest.addKey(flds{f},'','');
            end
            numValue = str2double(value.(flds{f}));
            if(isnan(numValue))
                numValue = value.(flds{f});
            end

            rest.addValue(flds{f}, struct('idx', parameterIdx,'val', numValue));
        end

    elseif(ischar(value) || isstring(value)) % If the value is characters
        if(isempty(parametersList{parameterIdx}.values))
            valueIdx = [];
        else
            valueIdx = find(matches(parametersList{parameterIdx}.values, value));
        end
        if(isempty(valueIdx)) % If the string does not exist
            dataTableRow(1, parameterIdx) = length(parametersList{parameterIdx}.values) + 1;
            parametersList{parameterIdx}.values{end+1} = value;
        else % If the string is already recorded
            dataTableRow(1, parameterIdx) = valueIdx;
        end
    end
end
end



% Replace the measured voltages by the applied (theoretical) ones in order
% not to use too much memory resources.
function B = correctVoltage(A,v)
B = A;
[H,W] = size(A);
if(length(v) == H)
    if(size(v,1) == 1)
        v = v.';
    end
    for w = 1:W
        if(2*mean(abs(A(:,w) - v)) < mean(abs(diff(A(:,w)))))
            B(:,w) = v;
        end
    end
elseif(length(v) == W)
    if(size(v,2) == 1)
        v = v.';
    end
    for h = 1:H
        if(2*mean(abs(A(h,:) - v)) < mean(abs(diff(A(h,:)))))
            B(h,:) = v;
        end
    end
else
    error("Voltage data within data sheet is incomplete.");
end
end