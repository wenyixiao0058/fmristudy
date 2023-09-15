FileDir = 'Z:\User\pcp20wx\fmri\ABIDEI\Rawdata\autism\Outputs\dparsf\filt_noglobal\func_preproc\';
file = dir(FileDir);
file =file(~ismember({file.name},{'.','..'}));
ii = 58;
temp = spm_vol(join([FileDir file(ii).name]));
dat = spm_read_vols(temp);
filename='Z:\User\pcp20wx\fmri\CODE\Mask\GroupMask90Percent.nii';
% filename='Z:\User\pcp20wx\fmri\CODE\Mask\7Default.nii';
v = spm_vol(filename);
mask =logical(spm_read_vols(v));
% reorganize data to be voxels by time series. This is important.
dat=reshape(dat,size(dat,1)*size(dat,2)*size(dat,3),size(dat,4));

% only keep the intracephalic data
dat=dat(mask,:); % now we get the internal brain data (voxel * time)

Test = dat;


%%

for ii = 1:size(Test,1)
    original_time_series = Test(ii,:)';

    % Number of iterations
    num_iterations = 100;

    % Perform FFT on the original time series
    fft_original = fft(original_time_series);

    % Initialize the surrogate time series
    surrogate_time_series = original_time_series;

    for iteration = 1:num_iterations
        % Perform FFT on the surrogate time series
        fft_surrogate = fft(surrogate_time_series);

        % Match amplitude of the original FFT and surrogate FFT
        amplitude_matched_fft = abs(fft_original) .* (fft_surrogate ./ abs(fft_surrogate));

        % Generate random phase shifts
        random_phase_shifts = exp(1i * angle(fft_surrogate));

        % Apply the phase shifts to the amplitude-matched FFT
        fft_phase_shuffled = amplitude_matched_fft .* random_phase_shifts;

        % Apply inverse FFT to obtain the phase-shuffled surrogate time series
        surrogate_time_series = real(ifft(fft_phase_shuffled));
    end

    surrogate_time_seriesii(ii,:) = surrogate_time_series;


    Out_MSEtest(ii,:) = MSE_mu(original_time_series,2,0.6,1,5);
    Out_MSEsurrogate(ii,:) = MSE_mu(surrogate_time_series,2,0.6,1,5);

end

filename1='Z:\User\pcp20wx\fmri\CODE\Mask\AllNetworksReslice.nii';
v = spm_vol(filename1);
mask1 =logical(spm_read_vols(v));

for ss = 1:5
    senmap{ss}=zeros(size(mask));
    szsenmap{ss}=zeros(size(mask));

    senmap_surrogate{ss}=zeros(size(mask));
    szsenmap_surrogate{ss}=zeros(size(mask));
end

for ss = 1:5
    senmap{ss}(mask) = Out_MSEtest(:,ss);
    senmap_surrogate{ss}(mask) = Out_MSEsurrogate(:,ss);
end

for ss = 1:5
    all_mean(ss) = mean(nonzeros(Out_MSEtest(:,ss)));
    all_sd(ss) = std(nonzeros(Out_MSEtest(:,ss)));
    szsen{ss}(:) = minus(nonzeros(Out_MSEtest(:,ss)),all_mean(ss))./all_sd(ss);
    szsenmap{ss}(mask) = szsen{ss};
    % Apply the mask to the vector
    masked_szsenmap(:,ss) = szsenmap{ss}(mask1);
    senmap{ss}(mask) = Out_MSEtest(:,ss);
    masked_senmap(:,ss) = senmap{ss}(mask1);

    all_mean_surrogate(ss) = nanmean(nonzeros(Out_MSEsurrogate(:,ss)));
    all_sd_surrogate(ss) = nanstd(nonzeros(Out_MSEsurrogate(:,ss)));
    szsen_surrogate{ss}(:) = minus(nonzeros(Out_MSEsurrogate(:,ss)),all_mean_surrogate(ss))./all_sd_surrogate(ss);
    szsenmap_surrogate{ss}(mask) = szsen_surrogate{ss};
    % Apply the mask to the vector
    masked_szsenmap_surrogate(:,ss) = szsenmap_surrogate{ss}(mask1);

    senmap_surrogate{ss}(mask) = Out_MSEsurrogate(:,ss);
    masked_senmap_surrogate(:,ss) = senmap_surrogate{ss}(mask1);
end

figure,
plot(mean(masked_szsenmap))
hold on
plot(nanmean(masked_szsenmap_surrogate))
% Adding a legend
legend('Original Data', 'Surrogate Data');

figure,
plot(mean(masked_senmap))
hold on
plot(nanmean(masked_senmap_surrogate))
% Adding a legend
legend('Original Data', 'Surrogate Data');


figure,
plot(mean(Out_MSEtest))
hold on
plot(nanmean(Out_MSEsurrogate))
% Adding a legend
legend('Original Data', 'Surrogate Data');


figure;

% Plot power spectrum of surrogate time series with solid line
amp = abs(fft(surrogate_time_series) / length(surrogate_time_series));
amp(2:end) = 2 * amp(2:end);
hz = linspace(0, 0.5 / 2, floor(length(surrogate_time_series) / 2) + 1);
plot(hz, amp(1:length(hz)), 'k', 'LineWidth', 1);  % Solid line
hold on;

% Plot power spectrum of eeg_data with dashed line
amp = abs(fft(original_time_series) / length(original_time_series));
amp(2:end) = 2 * amp(2:end);
hz = linspace(0, 0.5 / 2, floor(length(original_time_series) / 2) + 1);
plot(hz, amp(1:length(hz)), 'k--', 'LineWidth', 1);  % Dashed line

title('Frequency Domain');
xlabel('Frequency (Hz)');
ylabel('Amplitude');
legend('Surrogate Time Series', 'Original Data');


figure,
plot(original_time_series)
hold on
plot(surrogate_time_series)

%% final visualization
figure('Color', 'w');

subplot(2,1,1)
plot(original_time_series, 'b','LineWidth',1.2)
hold on
plot(surrogate_time_series, 'r--','LineWidth',1.2)
set(gca,'fontsize',20)
box off
axis off

subplot(2,3,4)
% Plot power spectrum of surrogate time series with solid line
amp = abs(fft(surrogate_time_series) / length(surrogate_time_series));
amp(2:end) = 2 * amp(2:end);
hz = linspace(0, 0.5 / 2, floor(length(surrogate_time_series) / 2) + 1);
y = amp(1:length(hz));
y(1:6) = 0;
plot(hz, y, 'b', 'LineWidth', 1);  % Solid line
hold on;

% Plot power spectrum of eeg_data with dashed line
amp = abs(fft(original_time_series) / length(original_time_series));
amp(2:end) = 2 * amp(2:end);
hz = linspace(0, 0.5 / 2, floor(length(original_time_series) / 2) + 1);
y = amp(1:length(hz));
y(1:6) = 0;
plot(hz(1:end), y, 'r--', 'LineWidth', 1);  % Dashed line

title('Frequency Domain');
xlabel('Frequency (Hz)');
ylabel('Amplitude');
set(gca,'fontsize',20);  % Adjust font size for the axis labels

subplot(2,3,5)
plot(squeeze(mean(masked_senmap)),'b','LineWidth',1.2)
hold on
plot(squeeze(nanmean(masked_senmap_surrogate)),'r--','LineWidth',1.2)
set(gca,'fontsize',20);  % Adjust font size for the axis labels
title('Raw Multiscale Sample Entropy');
xlabel('Time Scale');
ylabel('Raw Sample Entropy');
legend('fMRI Data','Surrogate Time Series', 'FontSize', 20);  % Adjust font size for the legend

subplot(2,3,6)
plot(squeeze(mean(masked_szsenmap)),'b','LineWidth',1.2)
hold on
plot(squeeze(nanmean(masked_szsenmap_surrogate)),'r--','LineWidth',1.2)
set(gca,'fontsize',20);  % Adjust font size for the axis labels
title('Standardized Multiscale Sample Entropy');
xlabel('Time Scale');
ylabel('Standardized Sample Entropy');

saveDir = 'Z:\User\pcp20wx\FIGURES\';
export_fig(join([saveDir 'PhaseShufflefmri.jpg'],''), '-r300');
%%
EEG = pop_loadset('E:\KatsDataFromAdam\1_ASC_resting_state_epoched\1ASD.set');
for channels = 1:size(EEG.data,1)
    for epoches = 1:size(EEG.data,3)
        eeg_data = squeeze(EEG.data(channels,:,epoches));

        original_time_series = eeg_data';

        %         % Perform FFT on the original time series
        %         fft_original = fft(original_time_series);
        %
        %         % Generate random phase shifts
        %         random_phase_shifts = exp(1i * 2 * pi * rand(size(fft_original)));
        %
        %         % Apply the phase shifts to the FFT to create phase-shuffled surrogate
        %         fft_phase_shuffled = abs(fft_original) .* random_phase_shifts;
        %
        %         % Apply inverse FFT to obtain the phase-shuffled surrogate time series
        %         surrogate_time_series = real(ifft(fft_phase_shuffled));

        % Number of iterations
        num_iterations = 100;

        % Perform FFT on the original time series
        fft_original = fft(original_time_series);

        % Initialize the surrogate time series
        surrogate_time_series = original_time_series;

        for iteration = 1:num_iterations
            % Perform FFT on the surrogate time series
            fft_surrogate = fft(surrogate_time_series);

            % Match amplitude of the original FFT and surrogate FFT
            amplitude_matched_fft = abs(fft_original) .* (fft_surrogate ./ abs(fft_surrogate));

            % Generate random phase shifts
            random_phase_shifts = exp(1i * angle(fft_surrogate));

            % Apply the phase shifts to the amplitude-matched FFT
            fft_phase_shuffled = amplitude_matched_fft .* random_phase_shifts;

            % Apply inverse FFT to obtain the phase-shuffled surrogate time series
            surrogate_time_series = real(ifft(fft_phase_shuffled));
        end

        % The surrogate_time_series now contains the phase-shuffled surrogate
        % with a power spectrum similar to the original time series
        surrogate_time_serieslist(channels,epoches,:) = surrogate_time_series;
        Out_MSEtest(channels,epoches,:) = MSE_mu(eeg_data,2,0.15,1,20);
        Out_MSEsurrogate(channels,epoches,:) = MSE_mu(surrogate_time_series,2,0.15,1,20);
    end
end
%%
cc = randi(30);
ee = randi(47);
eeg_data =  squeeze(EEG.data(cc,:,ee));
surrogate_time_series = squeeze(surrogate_time_serieslist(cc,ee,:))';

figure;

% Plot power spectrum of surrogate time series with solid line
amp = abs(fft(surrogate_time_series) / length(surrogate_time_series));
amp(2:end) = 2 * amp(2:end);
hz = linspace(0, 0.5 / 2, floor(length(surrogate_time_series) / 2) + 1);
plot(hz, amp(1:length(hz)), 'k', 'LineWidth', 1);  % Solid line
hold on;

% Plot power spectrum of eeg_data with dashed line
amp = abs(fft(eeg_data) / length(eeg_data));
amp(2:end) = 2 * amp(2:end);
hz = linspace(0, 0.5 / 2, floor(length(eeg_data) / 2) + 1);
plot(hz, amp(1:length(hz)), 'k--', 'LineWidth', 1);  % Dashed line

title('Frequency Domain');
xlabel('Frequency (Hz)');
ylabel('Amplitude');
legend('Surrogate Time Series', 'EEG Data');

figure,
plot(eeg_data)
hold on
plot(surrogate_time_series)

% Replace inf values with NaN
Out_MSEtest(Out_MSEtest == Inf | Out_MSEtest == -Inf) = NaN;

figure,
plot(squeeze(nanmean(nanmean(Out_MSEtest),2)))
hold on
plot(squeeze(nanmean(nanmean(Out_MSEsurrogate),2)))
% Adding a legend
legend('Original Data', 'Surrogate Data');




%%
% Calculate the amplitude spectrum of the surrogate time series
amp = abs(fft(surrogate_time_series) / length(surrogate_time_series));
amp(2:end) = 2 * amp(2:end);

% Convert amplitude values to log power spectral density (log PSD)
log_psd = 10 * log10(amp.^2);

% Define the frequency values for the x-axis
hz = linspace(0, 0.5 / 2, floor(length(surrogate_time_series) / 2) + 1);

% Plot the log power spectral density
plot(hz, log_psd(1:length(hz)), 'b'); % 'b' for blue solid line
xlabel('Frequency (Hz)');
ylabel('Log Power Spectral Density (dB/Hz)');
grid on;
hold on

% Calculate the amplitude spectrum of the surrogate time series
amp = abs(fft(eeg_data) / length(eeg_data));
amp(2:end) = 2 * amp(2:end);

% Convert amplitude values to log power spectral density (log PSD)
log_psd = 10 * log10(amp.^2);

% Define the frequency values for the x-axis
hz = linspace(0, 0.5 / 2, floor(length(eeg_data) / 2) + 1);

% Plot the log power spectral density
plot(hz, log_psd(1:length(hz)), 'r--');
xlabel('Frequency (Hz)');
ylabel('Log Power Spectral Density (dB/Hz)');
grid on;



%% final visualization
figure('Color', 'w');

subplot(211)
plot(eeg_data, 'b','LineWidth',1.2)
hold on
plot(surrogate_time_series, 'r--','LineWidth',1.2)
set(gca,'fontsize',20)
box off
axis off

subplot(223)
% Plot power spectrum of surrogate time series with solid line
amp = abs(fft(surrogate_time_series) / length(surrogate_time_series));
amp(2:end) = 2 * amp(2:end);
hz = linspace(0, 0.5 / 2, floor(length(surrogate_time_series) / 2) + 1);
plot(hz, amp(1:length(hz)), 'b', 'LineWidth', 1);  % Solid line
hold on;

% Plot power spectrum of eeg_data with dashed line
amp = abs(fft(eeg_data) / length(eeg_data));
amp(2:end) = 2 * amp(2:end);
hz = linspace(0, 0.5 / 2, floor(length(eeg_data) / 2) + 1);
plot(hz, amp(1:length(hz)), 'r--', 'LineWidth', 1);  % Dashed line

title('Frequency Domain');
xlabel('Frequency (Hz)');
ylabel('Amplitude');
set(gca,'fontsize',20);  % Adjust font size for the axis labels

subplot(224)
plot(squeeze(nanmean(nanmean(Out_MSEtest),2)),'b','LineWidth',1.2)
hold on
plot(squeeze(nanmean(nanmean(Out_MSEsurrogate),2)),'r--','LineWidth',1.2)
set(gca,'fontsize',20);  % Adjust font size for the axis labels
title('Multiscale Sample Entropy');
xlabel('Time Scale');
ylabel('Sample Entropy');
legend('EEG Data','Surrogate Time Series', 'FontSize', 20);  % Adjust font size for the legend

saveDir = 'Z:\User\pcp20wx\FIGURES\';
export_fig(join([saveDir 'PhaseShuffleEEG.jpg'],''), '-r300');