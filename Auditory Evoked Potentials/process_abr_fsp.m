function varargout = process_abr_fsp( varargin )
% PROCESS_ABR_FSP: Calculates the classic and weighted Fsp values from the given ABR epochs
% Seminal article on ABR Fsp is by "Elberling and Don (1984) Quality estimation of 
% averaged auditory brainstem responses." Scandinavian Audiology 13: 187-197
% Author: by MinChul Park (May 2023)
% University of Canterbury | Te Whare Wānanga o Waitaha
% Christchurch | Ōtautahi
% New Zealand | Aotearoa
% Contributors: François Tadel and Raymundo Cassani

eval(macro_method);
end

%% ===== GET DESCRIPTION =====
function sProcess = GetDescription() %#ok<DEFNU>
    % Description the process
    sProcess.Comment     = 'ABR Fsp';
    sProcess.FileTag     = 'ABR Fsp';
    sProcess.Category    = 'Custom';
    sProcess.SubGroup    = 'Custom Processes';
    sProcess.Index       = 1000;
    sProcess.Description = 'https://www.tandfonline.com/doi/abs/10.3109/01050398409043059';
    % Definition of the input accepted by this process
    sProcess.InputTypes  = {'data'};
    sProcess.OutputTypes = {'data'};
    sProcess.nInputs     = 1;
    sProcess.nMinFiles   = 2;

    % Description
    sProcess.options.info.Comment = ['Calculates the Fsp values (classic and weighted) from the given ABR epochs.<BR><BR>' ...
                                     'The seminal article on ABR Fsp is from Elberling and Don (1984)<BR>'...
                                     'Quality estimation of averaged auditory brainstem responses.<BR>'...
                                     'Scandinavian Audiology 13: 187-197.<BR><BR>'...
                                     'Notes<BR>' ...
                                     '1. The process generates classic and weighted Fsps.<BR>'...
                                     '2. Degrees of Freedom = 15.<BR>'...
                                     '3. Time = 1 to be able to open the figure.<BR><BR>'];
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
    AllMatFsp = AllMat;
    Nchannels = epochSize(1); % Number of channels. 
    Nepochs   = length(sInputs); % Number of epochs.
    EpochWFsp = ones(Nchannels,1,Nepochs)./var((AllMatFsp),0,2); % Calculation of epoch specific weighting.
    WEpochFsp = EpochWFsp.*(AllMatFsp); % Application of epoch specific weighting to all epochs. 
    % WEpoch is still in [Nchannels x Ntime x Nepochs].
    AvgWEpoch = mean(WEpochFsp,3); % Weighted epoch averaging over epochs (i.e. averaging in time points).
    % Changes [Nchannels x Ntime x Nepochs] into [Nchannels X Ntime].
    AvgWEpoch = AvgWEpoch(:,[150 162 173 185 196 208 219 231 242 253 265 276 288 299 311]); 
    % Selects 15 time points (degrees of freedom). [Nchannels X Ntime points]
    AvgEpoch  = mean(AllMatFsp,3); % Unweighted epoch averaging over epochs.
    AvgEpoch  = AvgEpoch(:,[150 162 173 185 196 208 219 231 242 253 265 276 288 299 311]); 
    % Selects 15 time points (degrees of freedom). [Nchannels X Ntime points]
    Time      = 2; % Fsp_C and Fsp_W both produce a single value therefore need time = 1 to open the file. 

    SpWEpoch  = zeros(Nchannels, Nepochs); % Creates Nchannels X Nepochs matrix of zeros.
    SpEpoch   = zeros(Nchannels, Nepochs); % Creates Nchannels X Nepochs matrix of zeros.

    % for loop selects the single time point (column) of every epoch and adds it to the zeros matrix.
        for i = 1 : Nepochs
            SpWEpoch (:,i) = WEpochFsp (:,231,i); % [Nchannels X Nepochs]
            SpEpoch  (:,i) = AllMatFsp (:,231,i); % [Nchannels X Nepochs]
        end

    Numerator_W   = var(AvgWEpoch,0,2); % [Nchannels X 1]
    Denominator_W = var(SpWEpoch,0,2)./(Nepochs); % [Nchannels X 1]

    Numerator_C   = var(AvgEpoch,0,2); % [Nchannels X 1]
    Denominator_C = var(SpEpoch,0,2)./(Nepochs); % [Nchannels X 1]

    Fsp_W = Numerator_W./Denominator_W; % Weighted Fsp final calculation
    Fsp_C = Numerator_C./Denominator_C; % Classic Fsp final calculation

    % ===== SAVE THE RESULTS =====
    % Get the output study (pick the one from the first file)
    iStudy = sInputs(1).iStudy;
    % Create a new data file structure
    DataMat             = db_template('datamat');
    DataMat.F           = Fsp_C;
    DataMat.Time        = Time; 
    DataMat.Comment     = sprintf('ABR_Fsp_C (%d)', Nepochs); % Names the output file as 'ABR_Fsp_C' with the number of epochs used to generate the file.
    DataMat.ChannelFlag = ones(epochSize(1), 1);   % List of good/bad channels (1=good, -1=bad)
    DataMat.DataType    = 'recordings';
    DataMat.nAvg        = Nepochs;         % Number of epochs that were used to get this file
    % Create a default output filename 
    OutputFiles{1} = bst_process('GetNewFilename', fileparts(sInputs(1).FileName), 'data_ABR_Fsp_C');
    % Save on disk
    save(OutputFiles{1}, '-struct', 'DataMat');
    % Register in database
    db_add_data(iStudy, OutputFiles{1}, DataMat);

    % ===== SAVE THE RESULTS =====
    % Get the output study (pick the one from the first file)
    iStudy = sInputs(1).iStudy;
    % Create a new data file structure
    DataMat             = db_template('datamat');
    DataMat.F           = Fsp_W;
    DataMat.Time        = Time; 
    DataMat.Comment     = sprintf('ABR_Fsp_W (%d)', Nepochs); % Names the output file as 'ABR_Fsp_W' with the number of epochs used to generate the file.
    DataMat.ChannelFlag = ones(epochSize(1), 1);   % List of good/bad channels (1=good, -1=bad)
    DataMat.DataType    = 'recordings';
    DataMat.nAvg        = Nepochs;         % Number of epochs that were used to get this file
    % Create a default output filename 
    OutputFiles{1} = bst_process('GetNewFilename', fileparts(sInputs(1).FileName), 'data_ABR_Fsp_W');
    % Save on disk
    save(OutputFiles{1}, '-struct', 'DataMat');
    % Register in database
    db_add_data(iStudy, OutputFiles{1}, DataMat);
end
    
    % If you want to combine Fsp_C and Fsp_W into one file use the following code. 
    % Fsp   = [Fsp_C, Fsp_W]; % Groups Fsp_C and Fsp_W into one matrix. 
    % Time  = [1 2]; % 2 seconds needed; 1 = Fsp_C and 2 = Fsp_W.
    % ===== SAVE THE RESULTS =====
    % Get the output study (pick the one from the first file)
    % iStudy = sInputs(1).iStudy;
    % Create a new data file structure
    % DataMat             = db_template('datamat');
    % DataMat.F           = Fsp;
    % DataMat.Time        = Time; 
    % DataMat.Comment     = sprintf('ABR_Fsp (%d)', Nepochs); % Names the output file as 'ABR_Fsp' with the number of epochs used to generate the file.
    % DataMat.ChannelFlag = ones(epochSize(1), 1);   % List of good/bad channels (1=good, -1=bad)
    % DataMat.DataType    = 'recordings';
    % DataMat.nAvg        = Nepochs;         % Number of epochs that were used to get this file
    % Create a default output filename 
    % OutputFiles{1} = bst_process('GetNewFilename', fileparts(sInputs(1).FileName), 'data_ABR_Fsp');
    % Save on disk
    % save(OutputFiles{1}, '-struct', 'DataMat');
    % Register in database
    % db_add_data(iStudy, OutputFiles{1}, DataMat);
