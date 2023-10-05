function varargout = process_residual_noise( varargin )
% PROCESS_RESIDUAL_NOISE: Calculates classic and weighted residual noise of all epochs as inspired from
% "Evaluating residual background noise in human auditory brain-stem responses by
% Manuel Don, and Claus Elberling, 1994"
% Author: by MinChul Park (June 2022)
% University of Canterbury | Te Whare Wānanga o Waitaha
% Christchurch | Ōtautahi
% New Zealand | Aotearoa
% Contributors: François Tadel and Raymundo Cassani

eval(macro_method);
end

%% ===== GET DESCRIPTION =====
function sProcess = GetDescription() %#ok<DEFNU>
    % Description the process
    sProcess.Comment     = 'Residual noise';
    sProcess.FileTag     = 'RNoise';
    sProcess.Category    = 'Custom';
    sProcess.SubGroup    = 'Custom Processes';
    sProcess.Index       = 1000;
    sProcess.Description = 'https://pubmed.ncbi.nlm.nih.gov/7983280/';
    % Definition of the input accepted by this process
    sProcess.InputTypes  = {'data'};
    sProcess.OutputTypes = {'data'};
    sProcess.nInputs     = 1;
    sProcess.nMinFiles   = 2;

    % Description
    sProcess.options.info.Comment = ['Calculates classic and weighted residual noise of all epochs as inspired from<BR>' ... 
                                     '"Evaluating residual background noise in human auditory brain-stem responses by Manuel Don, and Claus Elberling, (1994)."<BR><BR>' ...
                                     'Note1: The x-axis will show the epoch number but the units will still be in "Time (s)".<BR>'...
                                     'Unfortunately this cannot be changed.<BR><BR>' ...
                                     'Note2: This process will generate two files. One each for classic and weighted residual noise.<BR>'];
    sProcess.options.info.Type    = 'label';
    sProcess.options.info.Value   = [];
end


%% ===== FORMAT COMMENT =====
function Comment = FormatComment(sProcess) %#ok<DEFNU>
     Comment = sProcess.Comment;
end


%% ===== RUN =====
function OutputFiles = Run(sProcess, sInputs) %#ok<DEFNU>
    % Initialize returned list of files
    OutputFiles = {};

    % ===== LOAD THE DATA =====
    % Read the first file in the list, to initialize the loop
    DataMat = in_bst(sInputs(1).FileName, [], 0);
    epochSize = size(DataMat.F);
    Time = DataMat.Time;
    % Initialize the load matrix: [Nchannels x Ntime x Nepochs]
    AllMat = zeros(epochSize(1), epochSize(2), length(sInputs));
    % Reading all the input files in a big matrix
    for i = 1:length(sInputs)
        % Read the file #i
        DataMat = in_bst(sInputs(i).FileName, [], 0);
        % Check the dimensions of the recordings matrix in this file
        if ~isequal(size(DataMat.F), epochSize)
            % Add an error message to the report
            bst_report('Error', sProcess, sInputs, 'One file has a different number of channels or a different number of time samples.');
            % Stop the process
            return;
        end
        % Add the current file in the big load matrix
        AllMat(:,:,i) = DataMat.F;
    end
    
    % ===== PROCESS =====
    % Calculation of Classic and Weighted Residual Noise. 
    Nchannels = epochSize(1); % Number of channels. 
    Nepochs   = length(sInputs); % Number of epochs.
    ESqrt     = sqrt(linspace (1,(Nepochs),(Nepochs))); % Sqrt of 1 to epoch number n. 
    EpochW    = ones(Nchannels,1,Nepochs)./var((AllMat),0,2); % Calculation of epoch specific weighting.
    EpochW2D  = reshape(EpochW, [Nchannels Nepochs]); % Changes EpochW 3D matrix into 2D matrix for easier manipulation. 
    WEpoch    = EpochW.*(AllMat); % Application of epoch specific weighting to all epochs. 
    Time      = linspace (1,(Nepochs),(Nepochs)); % Changes the x-axis from time (s) to epoch number n. 

    CRN       = zeros(Nchannels, Nepochs); % Creates Nchannels X Nepochs matrix of zeros.
    WRNN      = zeros(Nchannels, Nepochs); % Creates Nchannels X Nepochs matrix of zeros
    WRND      = zeros(Nchannels, Nepochs); % Creates Nchannels X Nepochs matrix of zeros    

    % The for loops down below were originally separated but upon testing,
    % combining them together proved slightly faster, thus they are in this
    % current form.

        for i = 1 : Nepochs 
            CRN(:,i) = std(AllMat(:, :, 1:i), 0, [2 3]); % for loop to calculate std of data in rows and over pages of epochs. 

            WRNN(:,i) = std(WEpoch(:, :, 1:i), 0, [2 3]); % for loop to calculate std of weighted data and the mean of epoch weighting in rows and over pages of epochs. 
            WRND(:,i) = mean(EpochW2D(:, 1:i), 2);
        end

    CRN       = CRN./ESqrt; % Final calculation of classic residual noise. Generates Nchannels X Nepochs double matrix. 

    WRNN      = WRNN./ESqrt;
    WRN       = WRNN./WRND; % Final calculation of weighted residual noise. Generates Nchannels X Nepochs double matrix. 
       
    % ===== SAVE THE RESULTS =====
    % Get the output study (pick the one from the first file)
    iStudy = sInputs(1).iStudy;
    % Create a new data file structure
    DataMat             = db_template('datamat');
    DataMat.F           = CRN;
    DataMat.Comment     = sprintf('RNoise_C (%d)', length(sInputs)); % Names the output file as 'RNoise' with the number of epochs used to generate the file.
    DataMat.ChannelFlag = ones(epochSize(1), 1);   % List of good/bad channels (1=good, -1=bad)
    DataMat.Time        = Time; % In this case this will show the number of epochs. But the units will still be "Time (s)" which cannot be changed. 
    DataMat.DataType    = 'recordings';
    DataMat.nAvg        = length(sInputs);         % Number of epochs that were averaged to get this file
    % Create a default output filename 
    OutputFiles{1} = bst_process('GetNewFilename', fileparts(sInputs(1).FileName), 'data_RNoise_C');
    % Save on disk
    save(OutputFiles{1}, '-struct', 'DataMat');
    % Register in database
    db_add_data(iStudy, OutputFiles{1}, DataMat);

    % ===== SAVE THE RESULTS =====
    % Get the output study (pick the one from the first file)
    iStudy = sInputs(1).iStudy;
    % Create a new data file structure
    DataMat             = db_template('datamat');
    DataMat.F           = WRN;
    DataMat.Comment     = sprintf('RNoise_W (%d)', length(sInputs)); % Names the output file as 'RNoise' with the number of epochs used to generate the file.
    DataMat.ChannelFlag = ones(epochSize(1), 1);   % List of good/bad channels (1=good, -1=bad)
    DataMat.Time        = Time; % In this case this will show the number of epochs. But the units will still be "Time (s)" which cannot be changed. 
    DataMat.DataType    = 'recordings';
    DataMat.nAvg        = length(sInputs);         % Number of epochs that were averaged to get this file
    % Create a default output filename 
    OutputFiles{1} = bst_process('GetNewFilename', fileparts(sInputs(1).FileName), 'data_RNoise_W');
    % Save on disk
    save(OutputFiles{1}, '-struct', 'DataMat');
    % Register in database
    db_add_data(iStudy, OutputFiles{1}, DataMat);

    % If you want to select the final RN value and combine them into one file use the following code. 
    % RN = [CRN(:,end), WRN(:,end)]; % Selects the end column of CRN and WRN and groups them into one matrix.
    % Time = [1 2]; % 2 seconds needed; 1 = CRN and 2 = WRN
    % ===== SAVE THE RESULTS =====
    % Get the output study (pick the one from the first file)
    % iStudy = sInputs(1).iStudy;
    % Create a new data file structure
    % DataMat             = db_template('datamat');
    % DataMat.F           = RN;
    % DataMat.Comment     = sprintf('RNoise (%d)', length(sInputs)); % Names the output file as 'RNoise' with the number of epochs used to generate the file.
    % DataMat.ChannelFlag = ones(epochSize(1), 1);   % List of good/bad channels (1=good, -1=bad)
    % DataMat.Time        = Time; % In this case this will show the number of epochs. But the units will still be "Time (s)" which cannot be changed. 
    % DataMat.DataType    = 'recordings';
    % DataMat.nAvg        = length(sInputs);         % Number of epochs that were averaged to get this file
    % Create a default output filename 
    % OutputFiles{1} = bst_process('GetNewFilename', fileparts(sInputs(1).FileName), 'data_RNoise');
    % Save on disk
    % save(OutputFiles{1}, '-struct', 'DataMat');
    % Register in database
    % db_add_data(iStudy, OutputFiles{1}, DataMat);
end
