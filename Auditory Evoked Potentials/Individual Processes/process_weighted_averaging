function varargout = process_weighted_average( varargin )
% PROCESS_WEIGHTED_AVERAGE: Calculates epoch specific weightings, apply to all epochs then evaluates weighted averaging.
% Weighted averaging method inspired from "Evaluating residual background noise in human auditory brain-stem responses by
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
    sProcess.Comment     = 'Weighted average';
    sProcess.FileTag     = 'WAvg';
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
    sProcess.options.info.Comment = ['Calculates epoch specific weightings, apply to all epochs then evaluates weighted averaging.<BR>' ... 
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
    EpochW = ones(epochSize(1),1,length(sInputs))./var((AllMat),0,2); % Calculation of epoch specific weighting.
    AllMat = EpochW.*(AllMat); % Application of epoch specific weighting to all epochs. 
    AllMat = sum(AllMat,3)./sum(EpochW,3); % Calculation of weighted averaging through the weighted epochs. 
    
    % ===== SAVE THE RESULTS =====
    % Get the output study (pick the one from the first file)
    iStudy = sInputs(1).iStudy;
    % Create a new data file structure
    DataMat             = db_template('datamat');
    DataMat.F           = AllMat;
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
end
