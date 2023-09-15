%local:
%prefix = 'Z:/User/pcp20wx/fmri/'; start = 69; stop = 69;
%HPC:
prefix = '/shared/dede_group/User/pcp20wx/fmri/';


addpath([prefix 'CODE'])
addpath([prefix 'CODE/spm12'])
savedir = [prefix 'FIGURES/'];
summaryDatSave = [prefix 'SUMDAT/datamat/resampleAllnoFiltered/'];


%% ABIDEI data
data = struct;

% ABIDEI dataset
% subInfo = readtable([prefix '0.5HzQCABIDEI.csv']);
%
% subInfo = readtable([prefix 'subdataset1.csv']);

% Resampled ABIDEI dataset
subInfo = readtable([prefix 'resampleDat.csv']);
groups = {'autism','control'};
scale =5;
substr = ["leuven","olin","pitt","stanford","trinity","yale"];
for ii = 1:height(subInfo)
    %col1: subject filename
    tf = startsWith([subInfo.fn{ii}] , substr ,IgnoreCase=true);
    if tf == 1
        data(ii).fn = strcat(upper([subInfo.fn{ii}(1)]),lower([subInfo.fn{ii}(2:end)]));
    else
        data(ii).fn = [subInfo.fn{ii}];
    end
    %col2:directory
    data(ii).datFolder = [prefix 'ABIDEI/Rawdata/' groups{subInfo.GROUP(ii)} '/Outputs/dparsf/'];
    %col3:path of filtered data
%     data(ii).filterpath = join([data(ii).datFolder 'filt_noglobal/func_preproc/' data(ii).fn '_func_preproc.nii.gz']);
    %     %col4:path of non-filtered data
    data(ii).nofilterpath = join([data(ii).datFolder 'nofilt_noglobal/func_preproc/' data(ii).fn '_func_preproc.nii.gz']);
    %col5: mask path
    data(ii).maskpath = join([data(ii).datFolder 'func_mask/' data(ii).fn '_func_mask.nii.gz']);
    %col6:age
    data(ii).age = subInfo.AGE(ii);
    %col7:sex
    data(ii).gender = subInfo.SEX(ii);
    %col8:sampling rate
    data(ii).SR = subInfo.SR(ii);
    %col9:P (parameter in resample)
    data(ii).P = subInfo.P(ii);
    %col10:Q (parameter in resample)
    data(ii).Q = subInfo.Q(ii);
    %col11:FIQ
    data(ii).FIQ = subInfo.FIQ(ii);
    %col12:FIQ
    data(ii).VIQ = subInfo.VIQ(ii);
    %col13:FIQ
    data(ii).PIQ = subInfo.PIQ(ii);
    %col15:head motion parameter

        %col17:saveloc
        for ss =1:scale
        data(ii).(join(['scale' num2str(ss) 'noFilterSenmapSave'])) = [prefix 'SUBDAT1/nofilt_noglobal/' groups{subInfo.group(ii)} '/senmap/rawmap/scale' num2str(ss) '/'];
        data(ii).(join(['scale' num2str(ss) 'noFilterFenmapSave'])) = [prefix 'SUBDAT1/nofilt_noglobal/' groups{subInfo.group(ii)} '/fenmap/rawmap/scale' num2str(ss) '/'];
        % szmap
        data(ii).(join(['scale' num2str(ss) 'noFilterSZSenmapSave'])) = [prefix 'SUBDAT1/nofilt_noglobal/' groups{subInfo.group(ii)} '/senmap/szmap/scale' num2str(ss) '/'];
        data(ii).(join(['scale' num2str(ss) 'noFilterSZFenmapSave'])) = [prefix 'SUBDAT1/nofilt_noglobal/' groups{subInfo.group(ii)} '/fenmap/szmap/scale' num2str(ss) '/'];
        % smmap
        data(ii).(join(['scale' num2str(ss) 'noFilterSMSenmapSave'])) = [prefix 'SUBDAT1/nofilt_noglobal/' groups{subInfo.group(ii)} '/senmap/smmap/scale' num2str(ss) '/'];
        data(ii).(join(['scale' num2str(ss) 'noFilterSMFenmapSave'])) = [prefix 'SUBDAT1/nofilt_noglobal/' groups{subInfo.group(ii)} '/fenmap/smmap/scale' num2str(ss) '/'];
        end

    %col17:saveloc
    for ss =1:scale
        data(ii).(join(['scale' num2str(ss) 'noFilterResampledSenmapSave'])) = [prefix 'SUMDAT/resampled_nofilt_noglobal/' groups{subInfo.GROUP(ii)} '/senmap/rawmap/scale' num2str(ss) '/'];
        data(ii).(join(['scale' num2str(ss) 'noFilterResampledFenmapSave'])) = [prefix 'SUMDAT/resampled_nofilt_noglobal/' groups{subInfo.GROUP(ii)} '/fenmap/rawmap/scale' num2str(ss) '/'];
        % szmap
        data(ii).(join(['scale' num2str(ss) 'noFilterResampledSZSenmapSave'])) = [prefix 'SUMDAT/resampled_nofilt_noglobal/' groups{subInfo.GROUP(ii)} '/senmap/szmap/scale' num2str(ss) '/'];
        data(ii).(join(['scale' num2str(ss) 'noFilterResampledSZFenmapSave'])) = [prefix 'SUMDAT/resampled_nofilt_noglobal/' groups{subInfo.GROUP(ii)} '/fenmap/szmap/scale' num2str(ss) '/'];
        % smmap
        data(ii).(join(['scale' num2str(ss) 'noFilterResampledSMSenmapSave'])) = [prefix 'SUMDAT/resampled_nofilt_noglobal/' groups{subInfo.GROUP(ii)} '/senmap/smmap/scale' num2str(ss) '/'];
        data(ii).(join(['scale' num2str(ss) 'noFilterResampledSMFenmapSave'])) = [prefix 'SUMDAT/resampled_nofilt_noglobal/' groups{subInfo.GROUP(ii)} '/fenmap/smmap/scale' num2str(ss) '/'];
    end
end
disp(join(['going for subs: ' num2str(start) ':' num2str(stop) ' of ' num2str(length(data))],''))
data = data(start:stop);
% send data to the pipeline
setfmriAggregate(data, join([summaryDatSave  num2str(start) '_' num2str(stop) '_ABIDEI.mat']));
