function [data] = setfmriAggregate(varargin)  %data, saveLoc, prefix

switch nargin
    case 2
        data = varargin{1};
        saveLoc = varargin{2};
        

    otherwise
        "Error: incorrect number of inputs!"
end
%parameters for multiscale entropy calculation
scale = 5;
m=2;
r=.6;
n=2;
tau=1;

for ii = 1:length(data)
    disp(['subject: '  data(ii).fn])

    %% read in fmri data
    % read data
    % filtered data
%     v=spm_vol(data(ii).filterpath);
%     % nofiltered data
    v=spm_vol(data(ii).nofilterpath);
    dat=spm_read_vols(v);
    disp('reading in data')
    % read mask
    vmask=spm_vol(data(ii).maskpath);
    mask=logical(spm_read_vols(vmask));

    % reorganize data to be voxels by time series. This is important.
    dat=reshape(dat,size(dat,1)*size(dat,2)*size(dat,3),size(dat,4));

    % only keep the intracephalic data
    dat=dat(mask,:); % now we get the internal brain data (voxel * time)

%     resample the sample frequency if needed
    dat=dat';
    dat=resample(dat,data(ii).P,data(ii).Q);
    dat=dat';
    
    %% multiscale entropy on raw data
    disp('calculating multiscale entropy')
    [data(ii).rawsenmap,data(ii).rawfenmap] = multiscale_entropy4fmri(dat,mask,scale,m,r,n,tau);
    % szmap for further two sample t test
    [data(ii).szsenmap,data(ii).szfenmap] = szmap(data(ii).rawsenmap,data(ii).rawfenmap,mask,scale);
    % smmap for further one sample t test
    [data(ii).smsenmap,data(ii).smfenmap] = smmap(data(ii).rawsenmap,data(ii).rawfenmap,mask,scale);
    %% save entropy map file
    % save rawsenmap
    for ss = 1:scale
        vo=v(1);
        vo.dt=[16 0];
        vo.fname=fullfile(data(ii).(join(['scale' num2str(ss) 'noFilterResampledSenmapSave'])),sprintf('SEN_scale_%d_D%d_r%.2f_%s.nii',ss,m,r,data(ii).fn));
        vo=spm_write_vol(vo,data(ii).rawsenmap{ss});

        % save rawfenmap
        vo2=v(1);
        vo2.dt=[16 0];
        vo2.fname=fullfile(data(ii).(join(['scale' num2str(ss) 'noFilterResampledFenmapSave'])),sprintf('FEN_scale_%d_D%d_n%d_r%.2f_%s.nii',ss,m,n,r,data(ii).fn));
        vo2=spm_write_vol(vo2,data(ii).rawfenmap{ss});

        % save sz senmap
        vo3=v(1);
        vo3.dt=[16 0];
        vo3.fname=fullfile(data(ii).(join(['scale' num2str(ss) 'noFilterResampledSZSenmapSave'])),sprintf('SZSEN_scale_%d_D%d_r%.2f_%s.nii',ss,m,r,data(ii).fn));
        vo3=spm_write_vol(vo3,data(ii).szsenmap{ss});

        % save sz fenmap
        vo4=v(1);
        vo4.dt=[16 0];
        vo4.fname=fullfile(data(ii).(join(['scale' num2str(ss) 'noFilterResampledSZFenmapSave'])),sprintf('SZFEN_scale_%d_D%d_r%.2f_%s.nii',ss,m,r,data(ii).fn));
        vo4=spm_write_vol(vo4,data(ii).szfenmap{ss});

        % save sm senmap
        vo5=v(1);
        vo5.dt=[16 0];
        vo5.fname=fullfile(data(ii).(join(['scale' num2str(ss) 'noFilterResampledSMSenmapSave'])),sprintf('SMSEN_scale_%d_D%d_r%.2f_%s.nii',ss,m,r,data(ii).fn));
        vo5=spm_write_vol(vo5,data(ii).smsenmap{ss});

        % save sm fenmap
        vo6=v(1);
        vo6.dt=[16 0];
        vo6.fname=fullfile(data(ii).(join(['scale' num2str(ss) 'noFilterResampledSMFenmapSave'])),sprintf('SMFEN_scale_%d_D%d_r%.2f_%s.nii',ss,m,r,data(ii).fn));
        vo6=spm_write_vol(vo6,data(ii).smfenmap{ss});
    end


    %% multiscale entropy on resampled data
    disp(['subject: ' data(ii).fn ' complete!! '])

end
save(saveLoc,'data')
end