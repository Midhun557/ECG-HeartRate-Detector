clc;
clear all
close all

% Load ECG data from a .mat file
load('ecgdemodata2.mat');

if isrow(ecg)
    ecg = ecg'; % Convert to column vector if necessary
end
t = (0:length(ecg)-1) / samplingrate;

% 1. Preprocess the ECG Signal
% Bandpass filter to remove noise
lowCutoff = 0.5; % Low cutoff frequency in Hz
highCutoff = 50; % High cutoff frequency in Hz
[b, a] = butter(2, [lowCutoff highCutoff] / (samplingrate / 2), 'bandpass');
filteredECG = filtfilt(b, a, ecg);

% 2. Detect R-Peaks
[~, locs] = findpeaks(filteredECG, 'MinPeakHeight', 200, 'MinPeakDistance', round(0.6 * samplingrate));

% Display detected peak information
disp(['Number of R-peaks detected: ', num2str(length(locs))]);
disp('Locations of R-peaks (in samples):');
disp(locs);

% 3. Calculate the RR Intervals
if length(locs) > 1
    % Compute the RR intervals in seconds
    RR_intervals = diff(locs) / samplingrate;

% 4. Compute the Heart Rate
    if ~isempty(RR_intervals)
        heartRate = 60 ./ RR_intervals;
        avgHeartRate = mean(heartRate);
        disp(['Average Heart Rate: ', num2str(avgHeartRate), ' bpm']);
    else
        disp('No valid RR intervals found.');
    end
else
    disp('Not enough R-peaks detected to calculate heart rate.');
end

% 5. Plot ECG Signal
subplot(3,1,1);
plot(t,ecg);
xlabel('Time (s)');
ylabel('Amplitude');
title('Original ECG Signal');

subplot(3,1,2);
plot(t, filteredECG);
xlabel('Time (s)');
ylabel('Amplitude');
title('Filtered ECG Signal');

subplot(3,1,3);
plot(t, filteredECG);
hold on;
if ~isempty(locs)
    plot(locs / samplingrate, filteredECG(locs), 'ro');
end
xlabel('Time (s)');
ylabel('Amplitude');
title('ECG Signal with R-Peaks');
legend('Filtered ECG Signal', 'R-Peaks');
