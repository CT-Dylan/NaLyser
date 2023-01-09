disp('Looking for parameters...')
%% Fetch or create Dictionary
pM = ParametersManager();
pM.createDictionary();

%% Fetch parameters
%- Characteristics with the TTF Box -
if(~exist('ch_DATFileArray', 'var'))
    ch_DATFileArray = struct([]);
end
if(~exist('tf_DATFileArray', 'var'))
    tf_DATFileArray = struct([]);
end
if(~exist('time_DATFileArray', 'var'))
    time_DATFileArray = struct([]);
end
ch_fetchedP = struct([]);
tf_fetchedP = struct([]);
time_fetchedP = struct([]);

%% TTF Box
if(strcmp(Machine, 'TTF Box'))
    if(~Section_Charac && ~Section_Trans && ~Section_Times)
        error('The required sections to read are disabled. Please uncheck them.');
    end

    % Extract parameters - fonction located at the end of the script
    if(Section_Charac)
        [ch_fetchedP, ch_DATFileArray] = extractTTFParameters(pM, [Path '**/*' chipName '*' 'Charac' '*' 'dat'], ch_fetchedP, ch_DATFileArray, 1);
    end
    if(Section_Trans)
        [tf_fetchedP, tf_DATFileArray] = extractTTFParameters(pM, [Path '**/*' chipName '*'  TransSymbol '*' '.dat'], tf_fetchedP, tf_DATFileArray, 2);
    end
    if(Section_TimeSeries)
        [time_fetchedP, time_DATFileArray] = extractTTFParameters(pM, [Path '**/*' chipName '*' 'TimeSeries' '*' '.dat'], time_fetchedP, time_DATFileArray, 3);
    end



%% Keithley
elseif(strcmp(Machine, 'Keithley') && Section_Charac)
    % Get the files
    if(isempty(ch_DATFileArray))
        error("No related data files found. Please check the GUI entries.");
    end
    [size_list_ch_DATFile] = size(ch_DATFileArray,1);

    % Create Exceldatabase
    disp('Compiling excel sheets...');
    ED = ExcelDatabase();
    warning('off');

    [files, uniqueIdx, groupIdx] = unique({ch_DATFileArray(:).name});
    settingIdx = 0;
    for fileIdx = 1:length(uniqueIdx)
        % Compile Settings Sheets
        fileAddress = [ch_DATFileArray(uniqueIdx(fileIdx)).folder, '/', files{uniqueIdx(fileIdx)}];
        settings = sheetnames(fileAddress);
        settings = settings(contains(settings,'Settings'));
        for fileSetting = 1:length(settings)
            settingIdx = settingIdx+1;
            readFlag = false;
            ED.addSheet(files{uniqueIdx(fileIdx)}, ['Settings' num2str(settingIdx)], readtable(fileAddress, 'Sheet', ...
                settings(fileSetting),'ReadRowNames',false,'ReadVariableNames', ...
                readFlag, 'Format', 'auto', 'basic', true, 'UseExcel', true));
            %             compileFileList(fileIdx) = uniqueIdx(fileIdx);
        end

        % Extract extrinsic parameters information from the file name
        filename = ch_DATFileArray(fileIdx).name;

        splitName = regexp(filename, '\_', 'split');
        for split = 3:length(splitName)
            if(matches(splitName{split},regexpPattern("([^-0-9]+)?([-+]?(\d+)([.]+)?(\d+)?)")))
                parameterName = extract(splitName{split},asManyOfPattern(lettersPattern));
                parameterValue = extractAfter(splitName{split},asManyOfPattern(lettersPattern));
                ch_fetchedP(1).(parameterName{1})(fileIdx) = pM.paramDictionary.getValue(parameterName{1});
                ch_fetchedP(1).(parameterName{1})(groupIdx == fileIdx).v =  parameterValue;
            end
        end
    end

    for sheet = 1:size_list_ch_DATFile
        ch_fetchedP(1).File(sheet) = pM.paramDictionary.getValue('File');
        ch_fetchedP(1).File(sheet).v = groupIdx(sheet);

        % Compile Run Sheets
        readFlag = true;

        ED.addSheet(ch_DATFileArray(sheet).name, ch_DATFileArray(sheet).sheet, readtable([ch_DATFileArray(sheet).folder, '/', ch_DATFileArray(sheet).name], 'Sheet', ...
            ch_DATFileArray(sheet).sheet,'ReadRowNames',false,'ReadVariableNames', ...
            readFlag, 'Format', 'auto', 'basic', true, 'UseExcel', true));

        % Extract extrinsic parameters information from the sheet name
        sheetname = ch_DATFileArray(sheet).sheet;

        splitName = regexp(sheetname, '\_', 'split');
        for split = 1:length(splitName)
            if(matches(splitName{split},regexpPattern("([^-0-9]+)?([-+]?(\d+)([.]+)?(\d+)?)")))
                parameterName = extract(splitName{split},asManyOfPattern(lettersPattern));
                parameterValue = extractAfter(splitName{split},asManyOfPattern(lettersPattern));
                [v, returnType, returnString] = pM.paramDictionary.getValue(parameterName{1});
                switch returnType
                    case 1
                        ch_fetchedP(1).(parameterName{1})(sheet) = v;
                        ch_fetchedP(1).(parameterName{1})(sheet).v =  parameterValue;
                    case 0
                        if(~isfield(ch_fetchedP(1), v.name) || (sheet > length(ch_fetchedP(1).(v.name))))
                            ch_fetchedP(1).(v.name)(sheet) = v;
                            ch_fetchedP(1).(v.name)(sheet).v = struct(returnString, parameterValue);
                        else
                            ch_fetchedP(1).(v.name)(sheet).v.(returnString) = parameterValue;
                        end
                    otherwise
                        error(['The parameter ' parameterName{1} ' did not correspond to any entry of the dictionary.']);
                end


            end
        end

        if(HDColumn || LDColumn)
            ch_fetchedP(1).VDS(sheet) = pM.paramDictionary.getValue('VDS');
        end

        if(GColumn)
            ch_fetchedP(1).VGS(sheet) = pM.paramDictionary.getValue('VGS');
        end
    end

    warning('on')
    disp('Finished compiling the sheets.')
else
    error('The required sections to read are disabled. Please uncheck them.');

end

%% Verification and Confirmation
disp('Waiting for user confirmation...')

% Characteristics
if(Section_Charac)
    ch_paramInterest = {ch_xVar, ch_colVar, ch_subFigVar, ch_figVar, ch_lineVar, ch_markerVar};
    ch_paramDetected = fieldnames(ch_fetchedP);
    variableInfo = {'I', 'Current', '$I_\textrm{D}$', 'A'};
    pM.addCh(ch_paramInterest);
    [common, missing, working_P] = pM.cmpParameters(ch_paramDetected,'ch');
    C = Confirmation(variableInfo,ch_fetchedP, ch_paramInterest,common,missing,working_P);
    C.defineTag("Ch");
    waitfor(C);
end

% Transfer function
if(strcmp(Machine, 'TTF Box'))
    if(Section_Trans)
        tf_paramInterest = {tf_xVar, tf_colVar, tf_subFigVar, tf_figVar, tf_lineVar, tf_markerVar};
        tf_paramDetected = fieldnames(tf_fetchedP);

        if(strcmp(TransSymbol, 'GM'))
            variableInfo = {TransSymbol, TransVar, '$g_m$','S'};
        elseif(strcmp(TransSymbol, 'V'))
            variableInfo = {TransSymbol, TransVar, ['$' TransSymbol '$'], 'V'};
        elseif(strcmp(TransSymbol, 'H'))
            variableInfo = {TransSymbol, TransVar, ['$' TransSymbol '$'], ' '};
        end
        pM.addTf(tf_paramInterest);
        [common, missing, working_P] = pM.cmpParameters(tf_paramDetected,'tf');
        C = Confirmation(variableInfo, tf_fetchedP, tf_paramInterest,common,missing,working_P);
        C.defineTag("Tf");
        waitfor(C);

    end
% Time series
    if(Section_TimeSeries)
        time_paramInterest = {time_xVar, time_colVar, time_subFigVar, time_figVar, time_lineVar, time_markerVar};
        time_paramDetected = fieldnames(time_fetchedP);
        variableInfo = {'I', 'Current', '$I$', 'A'};
        pM.addTime(time_paramInterest);
        [common, missing, working_P] = pM.cmpParameters(time_paramDetected,'time');
        C = Confirmation(variableInfo,time_fetchedP, time_paramInterest,common,missing,working_P);
        C.defineTag("Time");
        waitfor(C);

    end

end

disp('Confirmation received. Proceeding to the next step.')
disp('.')
disp('.')
disp('.')



%--------------------------------------------------------------------------
%% Functions
%--------------------------------------------------------------------------
% Extract parameters from TTF Box files
function [fetchedP, DATFileArray] = extractTTFParameters(pM, namePattern, fetchedP, DATFileArray, type)
% Get the files
if(isempty(DATFileArray))
    DATFileArray = dir(namePattern);
end
if(isempty(DATFileArray))
    error("No related data files found. Please check the GUI entries.");
end
[size_list_DATFile] = size(DATFileArray);

for file = 1:size_list_DATFile
    fetchedP(1).File(file) = pM.paramDictionary.getValue('File');
    fetchedP(1).File(file).v = file;
    filename = DATFileArray(file).name;
    % Extract extrinsic parameters information from the file name
    splitName = regexp(filename, '\_', 'split');
    for split = 3:length(splitName)
        if(matches(splitName{split},regexpPattern("([^-0-9]+)?([-+]?(\d+)([.]+)?(\d+)?)")))
            parameterName = extract(splitName{split},asManyOfPattern(lettersPattern));
            parameterValue = extractAfter(splitName{split},asManyOfPattern(lettersPattern));
            fetchedP(1).(parameterName{1})(file) = pM.paramDictionary.getValue(parameterName{1});
            fetchedP(1).(parameterName{1})(file).v =  parameterValue;
        end
    end
end

% Extract intrinsic parameters information from the data inside
for file = 1:size_list_DATFile
    fetchedP(1).VDS(file) = pM.paramDictionary.getValue('VDS');
    fetchedP(1).VGS(file) = pM.paramDictionary.getValue('VGS');
    fetchedP(1).Channel(file) = pM.paramDictionary.getValue('Channel');
    switch type
        case 2
            fetchedP(1).Tint(file) = pM.paramDictionary.getValue('Tint');
            fetchedP(1).Freq(file) = pM.paramDictionary.getValue('Freq');
        case 3
            fetchedP(1).Tint(file) = pM.paramDictionary.getValue('Tint');
            fetchedP(1).Time(file) = pM.paramDictionary.getValue('Time');
        otherwise
    end
end
end

