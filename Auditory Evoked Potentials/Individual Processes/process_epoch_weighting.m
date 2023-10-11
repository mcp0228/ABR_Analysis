function varargout = process_epoch_weighting ( varargin )
% PROCESS_EPOCH_WEIGHTING: Calculates epoch specific weightings then applies them to all epochs.
% Method inspired from "Evaluating residual background noise in human auditory brain-stem responses by
% Manuel Don, and Claus Elberling, 1994"
% Author: by MinChul Park (August 2022)
% University of Canterbury | Te Whare Wānanga o Waitaha
% Christchurch | Ōtautahi
% New Zealand | Aotearoa
% Contributors: François Tadel and Raymundo Cassani

eval(macro_method);
end

%% ===== GET DESCRIPTION =====
function sProcess = GetDescription() %#ok<DEFNU>
    % Description the process
    sProcess.Comment     = 'Epoch weighting';
    sProcess.FileTag     = 'WEpoch';
    sProcess.Category    = 'Custom';
    sProcess.SubGroup    = 'Custom Processes';
    sProcess.Index       = 1000;
    sProcess.Description = '';
    % Definition of the input accepted by this process
    sProcess.InputTypes  = {'data'};
    sProcess.OutputTypes = {'data'};
    sProcess.nInputs     = 1;
    sProcess.nMinFiles   = 1;

    % Description
    sProcess.options.info.Comment = ['Calculates epoch specific weightings then applies them to all epochs.<BR>' ... 
                                     'That is, if you input 100 epochs it will process them and return 100 weighted epochs.<BR>'...
                                     'This is inspired from "Evaluating residual background noise in human auditory brain-stem responses by<BR>' ...
                                     'Manuel Don, and Claus Elberling, (1994)." <BR><BR>'];
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
    for i = 1:length(sInputs)
        EpochW = ones(epochSize(1),1,1)./var((AllMat(:,:,i)),0,2); % Calculation of epoch specific weighting.
        WEpoch = EpochW.*(AllMat(:,:,i)); % Application of epoch specific weighting to all epochs.
        WEpoch = WEpoch.*10^(-12);
        trial_num = regexp(sInputs(i).Comment, '\(#[0-9]*\)', 'match', 'once');
        
    % ===== SAVE THE RESULTS =====
    % Get the output study (Epoch weighting)
    iStudy = sInputs(i).iStudy;
    % Create a new data file structure
    DataMat             = db_template('datamat');
    DataMat.F           = WEpoch;
    DataMat.Comment     = ['WEpoch', ' ', trial_num]; % Names the output file as 'WEpoch' and adds the trial No. as a file tag.
    DataMat.ChannelFlag = ones(epochSize(1), 1);   % List of good/bad channels (1=good, -1=bad)
    DataMat.Time        = Time;
    DataMat.DataType    = 'recordings';
    DataMat.nAvg        = length(sInputs);         % Number of epochs that were averaged to get this file
    % Create a default output filename 
    OutputFiles{i} = bst_process('GetNewFilename', fileparts(sInputs(i).FileName), 'data_WEpoch');
    % Save on disk
    save(OutputFiles{i}, '-struct', 'DataMat');
    % Register in database and group them into a trial group node
    db_reload_studies(iStudy);
    end
end
