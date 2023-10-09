function varargout = process_noise_per_epoch ( varargin )
% PROCESS_NOISE_PER_EPOCH: Calculates noise per epoch for X number of epochs.
% Author: by MinChul Park (March 2023)
% University of Canterbury | Te Whare Wānanga o Waitaha
% Christchurch | Ōtautahi
% New Zealand | Aotearoa
% Contributors: François Tadel and Raymundo Cassani

eval(macro_method);
end

%% ===== GET DESCRIPTION =====
function sProcess = GetDescription() %#ok<DEFNU>
    % Description the process
    sProcess.Comment     = 'Noise per epoch';
    sProcess.FileTag     = 'NEpoch';
    sProcess.Category    = 'Custom';
    sProcess.SubGroup    = 'Custom Processes';
    sProcess.Index       = 1000;
    sProcess.Description = '';
    % Definition of the input accepted by this process
    sProcess.InputTypes  = {'data'};
    sProcess.OutputTypes = {'data'};
    sProcess.nInputs     = 1;
    sProcess.nMinFiles   = 1;

    % Description of the process
    sProcess.options.info.Comment = ['Calculates noise per epoch for X number of epochs.<BR>' ... 
                                     'That is, if you input 100 epochs it will return a single file with noise values on the y-axis and<BR>'...
                                     '100 epochs on the x-axis. You can visualise how noisy each epoch was over the entire X number of epochs.<BR><BR>'...
                                     'Note1: The x-axis units will still be in "Time (s)". This cannot be changed.<BR>'...
                                     'Note2: The noise value is essentially the standard deviation of each epoch.<BR><BR>'];
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
    % This is where the actual process of data manipulation and calculation takes place.
    Nchannels = epochSize(1); % Number of channels. 
    Nepochs   = length(sInputs); % Number of epochs.
    Time      = linspace (1,(Nepochs),(Nepochs)); % Changes the x-axis from time (s) to epoch number n. 

    NEpoch     = zeros(Nchannels, Nepochs); % Creates Nchannels X Nepochs matrix of zeros.
        for i = 1 : Nepochs % for loop to calculate std of data in rows of epochs. 
            NEpoch(:,i) = std(AllMat(:, :, i), 0, 2);
        end

    % ===== SAVE THE RESULTS =====
    % Get the output study (Noise per epoch)
    iStudy = sInputs(1).iStudy;
    % Create a new data file structure
    DataMat             = db_template('datamat');
    DataMat.F           = NEpoch;
    DataMat.Comment     = sprintf('NEpoch (%d)', length(sInputs)); % Names the output file as 'NEpoch' with the number of epochs used to generate the file.
    DataMat.ChannelFlag = ones(epochSize(1), 1);   % List of good/bad channels (1=good, -1=bad)
    DataMat.Time        = Time; % In this case this will show the number of epochs. But the units will still be "Time (s)" which cannot be changed. 
    DataMat.DataType    = 'recordings';
    DataMat.nAvg        = length(sInputs);         % Number of epochs that were averaged to get this file
    % Create a default output filename 
    OutputFiles{1} = bst_process('GetNewFilename', fileparts(sInputs(1).FileName), 'data_NEpoch');
    % Save on disk
    save(OutputFiles{1}, '-struct', 'DataMat');
    % Register in database
    db_add_data(iStudy, OutputFiles{1}, DataMat);
end
