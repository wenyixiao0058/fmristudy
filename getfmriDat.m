% This script is the data processing pipeline for analyzing fMRI data 
% from the ABIDEI dataset. It sets up data structures, 
% reads subject information, defines file paths, 
% and prepares data for further analysis. 
% The script also specifies scaling parameters 
% and saves the results at different scales and for resampled data. 
% Finally, it sends the data to the setfmriAggregate function for further processing.

% Set the file path prefix based on the computing environment
% Local path (commented out):
% prefix = 'Z:/User/pcp20wx/fmri/';
% HPC path:
prefix = '/shared/dede_group/User/pcp20wx/fmri/';

% Add necessary paths for code and SPM12
addpath([prefix 'CODE'])
addpath([prefix 'CODE/spm12'])

% Specify the directory for saving figures and summary data
savedir = [prefix 'FIGURES/'];
summaryDatSave = [prefix 'SUMDAT/datamat/resampleAllfiltered/'];

%% ABIDEI data
data = struct;

% Read subject information from a CSV file
subInfo = readtable([prefix 'resampleDat.csv']);

% Define the groups and scaling parameters
groups = {'autism', 'control'};
scale = 5;
substr = ["leuven", "olin", "pitt", "stanford", "trinity", "yale"];

% Loop through each subject's information
for ii = 1:height(subInfo)
    % Extract subject filename and format it if needed
    tf = startsWith([subInfo.fn{ii}], substr, IgnoreCase = true);
    if tf == 1
        data(ii).fn = strcat(upper([subInfo.fn{ii}(1)]), lower([subInfo.fn{ii}(2:end)]));
    else
        data(ii).fn = [subInfo.fn{ii}];
    end
    
    % Define paths for data files and other information
    data(ii).datFolder = [prefix 'ABIDEI/Rawdata/' groups{subInfo.GROUP(ii)} '/Outputs/dparsf/'];
    data(ii).filterpath = join([data(ii).datFolder 'filt_noglobal/func_preproc/' data(ii).fn '_func_preproc.nii.gz']);
    data(ii).maskpath = join([data(ii).datFolder 'func_mask/' data(ii).fn '_func_mask.nii.gz']);
    data(ii).age = subInfo.AGE(ii);
    data(ii).gender = subInfo.SEX(ii);
    data(ii).SR = subInfo.SR(ii);
    data(ii).P = subInfo.P(ii);
    data(ii).Q = subInfo.Q(ii);
    data(ii).FIQ = subInfo.FIQ(ii);
    data(ii).VIQ = subInfo.VIQ(ii);
    data(ii).PIQ = subInfo.PIQ(ii);

    % Define paths for saving results at different scales
    for ss = 1:scale
        data(ii).(join(['scale' num2str(ss) 'filterSenmapSave'])) = [prefix 'SUBDAT1/filt_noglobal/' groups{subInfo.group(ii)} '/senmap/rawmap/scale' num2str(ss) '/'];
        data(ii).(join(['scale' num2str(ss) 'filterFenmapSave'])) = [prefix 'SUBDAT1/filt_noglobal/' groups{subInfo.group(ii)} '/fenmap/rawmap/scale' num2str(ss) '/'];
        
        % szmap
        data(ii).(join(['scale' num2str(ss) 'filterSZSenmapSave'])) = [prefix 'SUBDAT1/filt_noglobal/' groups{subInfo.group(ii)} '/senmap/szmap/scale' num2str(ss) '/'];
        data(ii).(join(['scale' num2str(ss) 'filterSZFenmapSave'])) = [prefix 'SUBDAT1/filt_noglobal/' groups{subInfo.group(ii)} '/fenmap/szmap/scale' num2str(ss) '/'];
        
        % smmap
        data(ii).(join(['scale' num2str(ss) 'filterSMSenmapSave'])) = [prefix 'SUBDAT1/filt_noglobal/' groups{subInfo.group(ii)} '/senmap/smmap/scale' num2str(ss) '/'];
        data(ii).(join(['scale' num2str(ss) 'filterSMFenmapSave'])) = [prefix 'SUBDAT1/filt_noglobal/' groups{subInfo.group(ii)} '/fenmap/smmap/scale' num2str(ss) '/'];
    end

    % Define paths for saving results of resampled data
    for ss = 1:scale
        data(ii).(join(['scale' num2str(ss) 'filterResampledSenmapSave'])) = [prefix 'SUMDAT/resampled_filt_noglobal/' groups{subInfo.GROUP(ii)} '/senmap/rawmap/scale' num2str(ss) '/'];
        data(ii).(join(['scale' num2str(ss) 'filterResampledFenmapSave'])) = [prefix 'SUMDAT/resampled_filt_noglobal/' groups{subInfo.GROUP(ii)} '/fenmap/rawmap/scale' num2str(ss) '/'];
        
        % szmap
        data(ii).(join(['scale' num2str(ss) 'filterResampledSZSenmapSave'])) = [prefix 'SUMDAT/resampled_filt_noglobal/' groups{subInfo.GROUP(ii)} '/senmap/szmap/scale' num2str(ss) '/'];
        data(ii).(join(['scale' num2str(ss) 'filterResampledSZFenmapSave'])) = [prefix 'SUMDAT/resampled_filt_noglobal/' groups{subInfo.GROUP(ii)} '/fenmap/szmap/scale' num2str(ss) '/'];
        
        % smmap
        data(ii).(join(['scale' num2str(ss) 'filterResampledSMSenmapSave'])) = [prefix 'SUMDAT/resampled_filt_noglobal/' groups{subInfo.GROUP(ii)} '/senmap/smmap/scale' num2str(ss) '/'];
        data(ii).(join(['scale' num2str(ss) 'filterResampledSMFenmapSave'])) = [prefix 'SUMDAT/resampled_filt_noglobal/' groups{subInfo.GROUP(ii)} '/fenmap/smmap/scale' num2str(ss) '/'];
    end
end

% Display progress message and select a subset of data
disp(join(['going for subs: ' num2str(start) ':' num2str(stop) ' of ' num2str(length(data))],''))
data = data(start:stop);

% Send data to the pipeline for further processing
setfmriAggregate(data, join([summaryDatSave  num2str(start) '_' num2str(stop) '_ABIDEI.mat']));
