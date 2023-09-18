function [data] = setfmriAggregate(varargin)
% Function for aggregating and analyzing fMRI data with multiscale entropy.
% this function processes fMRI data, calculates multiscale entropy, 
% and saves the results in various files. 
% It takes input data, performs data preprocessing, 
% calculates multiscale entropy, and saves the results in NIfTI format. 
% Input:
% - varargin: Variable-length input arguments.
%   - When there are two inputs:
%     - data: Input data structure.
%     - saveLoc: Location to save the results.
%
% Output:
% - data: Updated data structure with multiscale entropy results.

switch nargin
    case 2
        % When there are two input arguments, assign them to data and saveLoc
        data = varargin{1};
        saveLoc = varargin{2};
    otherwise
        % Display an error message for an incorrect number of inputs
        disp("Error: incorrect number of inputs!")
end

% Parameters for multiscale entropy calculation
scale = 5;  % Number of scales
m = 2;      % Embedding dimension
r = 0.6;    % Tolerance parameter
n = 2;      % Number of neighbors
tau = 1;    % Time delay

% Loop through each subject's data
for ii = 1:length(data)
    disp(['subject: ' data(ii).fn])

    %% Read in fMRI data
    % Read data from the specified paths
    v = spm_vol(data(ii).nofilterpath); % Unfiltered data
    dat = spm_read_vols(v);
    
    % Read the brain mask
    vmask = spm_vol(data(ii).maskpath);
    mask = logical(spm_read_vols(vmask));
    
    % Reorganize the data to be voxels by time series
    dat = reshape(dat, size(dat, 1) * size(dat, 2) * size(dat, 3), size(dat, 4));
    dat = dat(mask, :); % Keep only internal brain data

    % Resample the data if needed
    dat = dat';
    dat = resample(dat, data(ii).P, data(ii).Q);
    dat = dat';
    
    %% Calculate multiscale entropy on raw data
    disp('calculating multiscale entropy')
    
    % Calculate multiscale entropy and feature entropy
    [data(ii).rawsenmap, data(ii).rawfenmap] = multiscale_entropy4fmri(dat, mask, scale, m, r, n, tau);
    
    % Calculate szmap for further two-sample t-tests
    [data(ii).szsenmap, data(ii).szfenmap] = szmap(data(ii).rawsenmap, data(ii).rawfenmap, mask, scale);
    
    % Calculate smmap for further one-sample t-tests
    [data(ii).smsenmap, data(ii).smfenmap] = smmap(data(ii).rawsenmap, data(ii).rawfenmap, mask, scale);
    
    %% Save entropy map files
    % Loop through scales and save SEN and FEN maps
    for ss = 1:scale
        vo = v(1);
        vo.dt = [16 0];
        
        % Save rawsenmap
        vo.fname = fullfile(data(ii).(join(['scale' num2str(ss) 'noFilterResampledSenmapSave'])), sprintf('SEN_scale_%d_D%d_r%.2f_%s.nii', ss, m, r, data(ii).fn));
        vo = spm_write_vol(vo, data(ii).rawsenmap{ss});

        % Save rawfenmap
        vo2 = v(1);
        vo2.dt = [16 0];
        vo2.fname = fullfile(data(ii).(join(['scale' num2str(ss) 'noFilterResampledFenmapSave'])), sprintf('FEN_scale_%d_D%d_n%d_r%.2f_%s.nii', ss, m, n, r, data(ii).fn));
        vo2 = spm_write_vol(vo2, data(ii).rawfenmap{ss});

        % Save sz senmap
        vo3 = v(1);
        vo3.dt = [16 0];
        vo3.fname = fullfile(data(ii).(join(['scale' num2str(ss) 'noFilterResampledSZSenmapSave'])), sprintf('SZSEN_scale_%d_D%d_r%.2f_%s.nii', ss, m, r, data(ii).fn));
        vo3 = spm_write_vol(vo3, data(ii).szsenmap{ss});

        % Save sz fenmap
        vo4 = v(1);
        vo4.dt = [16 0];
        vo4.fname = fullfile(data(ii).(join(['scale' num2str(ss) 'noFilterResampledSZFenmapSave'])), sprintf('SZFEN_scale_%d_D%d_r%.2f_%s.nii', ss, m, r, data(ii).fn));
        vo4 = spm_write_vol(vo4, data(ii).szfenmap{ss});

        % Save sm senmap
        vo5 = v(1);
        vo5.dt = [16 0];
        vo5.fname = fullfile(data(ii).(join(['scale' num2str(ss) 'noFilterResampledSMSenmapSave'])), sprintf('SMSEN_scale_%d_D%d_r%.2f_%s.nii', ss, m, r, data(ii).fn));
        vo5 = spm_write_vol(vo5, data(ii).smsenmap{ss});

        % Save sm fenmap
        vo6 = v(1);
        vo6.dt = [16 0];
        vo6.fname = fullfile(data(ii).(join(['scale' num2str(ss) 'noFilterResampledSMFenmapSave'])), sprintf('SMFEN_scale_%d_D%d_r%.2f_%s.nii', ss, m, r, data(ii).fn));
        vo6 = spm_write_vol(vo6, data(ii).smfenmap{ss});
    end

    %% Display completion message
    disp(['subject: ' data(ii).fn ' complete!! '])

end

% Save the updated data structure
save(saveLoc, 'data')
end
