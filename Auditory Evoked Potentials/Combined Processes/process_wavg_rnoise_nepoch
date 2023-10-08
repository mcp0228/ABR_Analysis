function varargout = process_wavg_rnoise_nepoch( varargin )
% PROCESS_WAVG_RNOISE_NEPOCH: Calculates weighted average, classic and weighted residual noise, and noise per epoch of all epochs as inspired from
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
    sProcess.Comment     = 'WAvg RNoise NEpoch';
    sProcess.FileTag     = 'WAvg RNoise NEpoch';
    sProcess.Category    = 'Custom';
    sProcess.SubGroup    = 'Custom Processes';
    sProcess.Index       = 1000;
    sProcess.Description = 'https://pubmed.ncbi.nlm.nih.gov/7983280/';
    % Definition of the input accepted by this process
    sProcess.InputTypes  = {'data'};
    sProcess.OutputTypes = {'data'};
    sProcess.nInputs     = 1;
    sProcess.nMinFiles   = 2;

    % Description of the process
    sProcess.options.info.Comment = ['1. Calculates epoch specific weightings then evaluates weighted averaging.<BR>'...
                                     '2. Calculates classic and weighted residual noise from all epochs.<BR>' ... 
                                     '3. Calculates noise per epoch for X number of epochs.<BR><BR>' ... 
                                     'Methods were inspired from "Evaluating residual background noise in human ABR<BR>'... 
                                     'by Manuel Don, and Claus Elberling, (1994)."<BR><BR>' ...
                                     'Note1: In residual noise and noise per epoch calculations, the x-axis = epoch number<BR>'...
                                     'but the units will = "Time (s)". Unfortunately this cannot be changed.<BR><BR>' ...
                                     'Note2: This process will generate four files - weighted average, classic residual noise,<BR>'...
                                     'weighted residual noise and noise per epoch.<BR><BR>'...
                                     'Note3: The noise value is essentially the standard deviation of each epoch.<BR><BR>'];
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
    % Calculation of Weighted Average
    EpochW = ones(epochSize(1),1,length(sInputs))./var((AllMat),0,2); % Calculation of epoch specific weighting.
    WEpoch = EpochW.*(AllMat); % Application of epoch specific weighting to all epochs. 
    WAvg = sum(WEpoch,3)./sum(EpochW,3); % Calculation of weighted averaging through the weighted epochs. 
    
    % Calculation of Classic Residual Noise.
    Nchannels = epochSize(1); % Number of channels. 
    Nepochs   = length(sInputs); % Number of epochs.
    ESqrt     = sqrt(linspace (1,(Nepochs),(Nepochs))); % Sqrt of 1 to epoch number n. 
    EpochW    = ones(Nchannels,1,Nepochs)./var((AllMat),0,2); % Calculation of epoch specific weighting.
    EpochW2D  = reshape(EpochW, [Nchannels Nepochs]); % Changes EpochW 3D matrix into 2D matrix for easier manipulation. 
    EpochNum  = linspace (1,(Nepochs),(Nepochs)); % Changes the x-axis from time (s) to epoch number n. 

    CRN       = zeros(Nchannels, Nepochs); % Creates Nchannels X Nepochs matrix of zeros.

        for j = 1 : Nepochs % for loop to calculate std of data in rows and over pages of epochs. 
            CRN(:,j) = std(AllMat(:, :, 1:j), 0, [2 3]);
        end
        
    CRN       = CRN./ESqrt; % Final calculation of classic residual noise. Generates 6 X 6000 double matrix. 

    % Calculation of Weighted Residual Noise. 
    WRNN      = zeros(Nchannels, Nepochs); % Creates Nchannels X Nepochs matrix of zeros
    WRND      = zeros(Nchannels, Nepochs); % Creates Nchannels X Nepochs matrix of zeros

        for j = 1 : Nepochs % for loop to calculate std of weighted data in [2 3] dimension the mean of epoch weighting in rows. 
            WRNN(:,j) = std(WEpoch(:, :, 1:j), 0, [2 3]);
            WRND(:,j) = mean(EpochW2D(:, 1:j), 2);
        end

    WRNN      = WRNN./ESqrt;
    WRN       = WRNN./WRND; % Final calculation of weighted residual noise. Generates 6 X 6000 double matrix. 

    % Note: In an attempt to make the running time of the process faster, the two loops were once combined.
    % However this actually made the process slower so the process is how it is now.

    % Calculation of Noise per Epoch.
    NEpoch     = zeros(Nchannels, Nepochs); % Creates Nchannels X Nepochs matrix of zeros.
    
        for k = 1 : Nepochs % for loop to calculate std of data in rows of epochs. 
            NEpoch(:,k) = std(AllMat(:, :, k), 0, 2);
        end
        
    % ===== SAVE THE RESULTS =====
    % Get the output study (Weighted Average)
    iStudy = sInputs(1).iStudy;
    % Create a new data file structure
    DataMat             = db_template('datamat');
    DataMat.F           = WAvg;
    DataMat.Comment     = sprintf('WAvg (%d)', length(sInputs)); % Names the output file as 'WAvg' with the number of epochs used to generate the file.
    DataMat.ChannelFlag = ones(epochSize(1), 1);   % List of good/bad channels (1=good, -1=bad)
    DataMat.Time        = Time; 
    DataMat.DataType    = 'recordings';
    DataMat.nAvg        = length(sInputs);         % Number of epochs that were averaged to get this file
    % Create a default output filename 
    OutputFiles{1} = bst_process('GetNewFilename', fileparts(sInputs(1).FileName), 'data_WAvg');
    % Save on disk
    save(OutputFiles{1}, '-struct', 'DataMat');
    % Register in database
    db_add_data(iStudy, OutputFiles{1}, DataMat);
    
    % Get the output study (Classic Residual Noise)
    iStudy = sInputs(1).iStudy;
    % Create a new data file structure
    DataMat             = db_template('datamat');
    DataMat.F           = CRN;
    DataMat.Comment     = sprintf('RNoise_C (%d)', length(sInputs)); % Names the output file as 'RNoise' with the number of epochs used to generate the file.
    DataMat.ChannelFlag = ones(epochSize(1), 1);   % List of good/bad channels (1=good, -1=bad)
    DataMat.Time        = EpochNum; % In this case this will show the number of epochs. But the units will still be "Time (s)" which cannot be changed. 
    DataMat.DataType    = 'recordings';
    DataMat.nAvg        = length(sInputs);         % Number of epochs that were averaged to get this file
    % Create a default output filename 
    OutputFiles{1} = bst_process('GetNewFilename', fileparts(sInputs(1).FileName), 'data_RNoise_C');
    % Save on disk
    save(OutputFiles{1}, '-struct', 'DataMat');
    % Register in database
    db_add_data(iStudy, OutputFiles{1}, DataMat);

    % Get the output study (Weighted Residual Noise)
    iStudy = sInputs(1).iStudy;
    % Create a new data file structure
    DataMat             = db_template('datamat');
    DataMat.F           = WRN;
    DataMat.Comment     = sprintf('RNoise_W (%d)', length(sInputs)); % Names the output file as 'RNoise' with the number of epochs used to generate the file.
    DataMat.ChannelFlag = ones(epochSize(1), 1);   % List of good/bad channels (1=good, -1=bad)
    DataMat.Time        = EpochNum; % In this case this will show the number of epochs. But the units will still be "Time (s)" which cannot be changed. 
    DataMat.DataType    = 'recordings';
    DataMat.nAvg        = length(sInputs);         % Number of epochs that were averaged to get this file
    % Create a default output filename 
    OutputFiles{1} = bst_process('GetNewFilename', fileparts(sInputs(1).FileName), 'data_RNoise_W');
    % Save on disk
    save(OutputFiles{1}, '-struct', 'DataMat');
    % Register in database
    db_add_data(iStudy, OutputFiles{1}, DataMat);

    % Get the output study (Noise per epoch)
    iStudy = sInputs(1).iStudy;
    % Create a new data file structure
    DataMat             = db_template('datamat');
    DataMat.F           = NEpoch;
    DataMat.Comment     = sprintf('NEpoch (%d)', length(sInputs)); % Names the output file as 'NEpoch' with the number of epochs used to generate the file.
    DataMat.ChannelFlag = ones(epochSize(1), 1);   % List of good/bad channels (1=good, -1=bad)
    DataMat.Time        = EpochNum; % In this case this will show the number of epochs. But the units will still be "Time (s)" which cannot be changed. 
    DataMat.DataType    = 'recordings';
    DataMat.nAvg        = length(sInputs);         % Number of epochs that were averaged to get this file
    % Create a default output filename 
    OutputFiles{1} = bst_process('GetNewFilename', fileparts(sInputs(1).FileName), 'data_NEpoch');
    % Save on disk
    save(OutputFiles{1}, '-struct', 'DataMat');
    % Register in database
    db_add_data(iStudy, OutputFiles{1}, DataMat);
end
