function varargout = process_weighted_merging_rn( varargin )
% PROCESS_WEIGHTED_MERGING_RN: Merges left and right ABR channels.
% Merging process is using weighted averaging process based on residual noise.
% Method taken from "Acoustic change complex for assessing speech
% discrimination in normal-hearing and hearing-impaired infants"
% By Ching et al. (2023) Clin Neurophysiol, 149, 121-132.
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
    sProcess.Comment     = 'Weighted merging_RN';
    sProcess.FileTag     = 'WMerg_RN';
    sProcess.Category    = 'Custom';
    sProcess.SubGroup    = 'Custom Processes';
    sProcess.Index       = 1000;
    % Definition of the input accepted by this process
    sProcess.InputTypes  = {'data'};
    sProcess.OutputTypes = {'data'};
    sProcess.nInputs     = 1;
    sProcess.nMinFiles   = 1;

    % Description
    sProcess.options.info.Comment = ['Merges left and right ABR channels through weighted averaging process based on residual noise.<BR>' ... 
                                     'Method inspired from "Acoustic change complex for assessing speech discrimination<BR>'...
                                     'in normal-hearing and hearing-impaired infants".<BR>' ...
                                     'Ching et al. (2023) Clin Neurophysiol, 149, 121-132."<BR><BR>'...
                                     'Merges the left and right ABR channels and produces one ABR waveform.<BR>'];
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
    Nchannels  = epochSize(1); % Number of channels. 
    Nepochs    = length(sInputs); % Number of epochs.  
    ESqrt      = sqrt(linspace (1,(Nepochs),(Nepochs))); % Sqrt of 1 to epoch number n. 
    EpochW     = ones(Nchannels,1,Nepochs)./var((AllMat),0,2); % Calculation of epoch specific weighting.
    EpochW2D   = reshape(EpochW, [Nchannels Nepochs]); % Changes EpochW 3D matrix into 2D matrix for easier manipulation. 
    WEpoch     = EpochW.*(AllMat); % Application of epoch specific weighting to all epochs. 
    WAvg       = sum(WEpoch,3)./sum(EpochW,3); % Calculation of weighted averaging through the weighted epochs.
    WAvgL      = WAvg(4,:); % Selects the left channel; this will be swapped if the channel rows are swapped
    WAvgR      = WAvg(5,:); % Selects the right channel; this will be swapped if the channel rows are swapped
 
    WRNN      = zeros(Nchannels, Nepochs); % Creates Nchannels X Nepochs matrix of zeros
    WRND      = zeros(Nchannels, Nepochs); % Creates Nchannels X Nepochs matrix of zeros    

    % The for loops down below were originally separated but upon testing,
    % combining them together proved slightly faster, thus they are in this
    % current form.

        for i = 1 : Nepochs 
            WRNN(:,i) = std(WEpoch(:, :, 1:i), 0, [2 3]); % for loop to calculate std of weighted data and the mean of epoch weighting in rows and over pages of epochs. 
            WRND(:,i) = mean(EpochW2D(:, 1:i), 2);
        end

    WRNN      = WRNN./ESqrt;
    WRN       = WRNN./WRND; % Final calculation of weighted residual noise. Generates Nchannels X Nepochs double matrix. 
    WRN       = WRN(:,end); % Selects the WRN of the last epoch

    WRN_L     = 1/(WRN(4,:)); % Selects the left channel and changes the RN into weighting factor
    WRN_R     = 1/(WRN(5,:)); % Selects the right channel and changes the RN into weighting factor
    WMerging  = (WAvgL*WRN_L + WAvgR*WRN_R)./(WRN_L + WRN_R); % Final weighted merging calculation

    WMerg_RN      = WAvg; % Renames WAvg to WMerg
    WMerg_RN(4,:) = WMerging;
    WMerg_RN(5,:) = WMerging;

    % ===== SAVE THE RESULTS =====
    % Get the output study (pick the one from the first file)
    iStudy = sInputs(1).iStudy;
    % Create a new data file structure
    DataMat             = db_template('datamat');
    DataMat.F           = WMerg_RN;
    DataMat.Comment     = sprintf('WMerg_RN (%d)', length(sInputs)); % Names the output file as 'WMerg_RN' with the number of epochs used to generate the file.
    DataMat.ChannelFlag = ones(epochSize(1), 1);   % List of good/bad channels (1=good, -1=bad)
    DataMat.Time        = Time;
    DataMat.DataType    = 'recordings';
    DataMat.nAvg        = length(sInputs);         % Number of epochs that were averaged to get this file
    % Create a default output filename 
    OutputFiles{1} = bst_process('GetNewFilename', fileparts(sInputs(1).FileName), 'data_WMerg_RN');
    % Save on disk
    save(OutputFiles{1}, '-struct', 'DataMat');
    % Register in database
    db_add_data(iStudy, OutputFiles{1}, DataMat);
end
