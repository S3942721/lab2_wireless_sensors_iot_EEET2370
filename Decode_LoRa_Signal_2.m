
load("LoRaCapture_Further400ms.mat", "CapturedSignal")

startSignal = 50
endSignal = 110

signalSegment = CapturedSignal(startSignal:endSignal);

fftshift(fft(signalSegment))

pwelch(signalSegment,256,0,[],par.fs,'centered')


%% Time crop
startTime = 0.055; % 55ms
endTime = 0.110;   % 110ms

% Calculate indices based on your sample rate (par.fs)
startIndex = round(startTime * par.fs) + 1;
endIndex   = round(endTime * par.fs);

% Crop the signal
CroppedSignal = CapturedSignal(startIndex:endIndex);

figure(2);
STFT_Window_Cropped = round(length(CroppedSignal)/100);
spectrogram(CroppedSignal, STFT_Window_Cropped, [], [], par.fs, 'yaxis', 'centered');
title('Cropped Signal (55ms to 110ms)');
grid on

%% 
BW = 125e3;           % 125 kHz
Fs = par.fs;          % SDR sample rate
Threshold = -30;      % Noise floor

CroppedLoRa = Pluto_Crop(CapturedSignal, BW, Fs, Threshold);

%% PSD
pwelch(CroppedSignal,256,0,[],par.fs,'centered')

%pwelch(CapturedSignal,256,0,[],par.fs,'centered')