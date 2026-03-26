% This is a demo of how to connect to ADALM SDR
% RMIT University
% Updated v3 on 20250322
clc
clear all
close all
%% Paramters
par.CaptureDuration = 0.5;  % [seconds] This is the capture duration for the signla (make sure this is wider than your signal duration)
par.fc   = 925e6;             % [Hz] set the center frequcny to your corresponding group
par.fs   = 2e6;               % [sample/sec] Sampling rate
par.Gain = 60;              % [dB] Amplifier gain
par.PowerCalib = 0;        % for calibrating the power
clims = [-120 -40];
%% To check if SDR Pluto is connected
% findPlutoRadio
%% Creat and configure receiver object
if ~exist('rx') % Only creats the recevier object if it was not created prviously (to save time)
    rx = comm.SDRRxPluto;
else
    release(rx);
end
rx.SamplesPerFrame    = par.CaptureDuration *par.fs;
rx.BasebandSampleRate = par.fs;
rx.CenterFrequency    = par.fc;
rx.EnableBurstMode    = true;
rx.NumFramesInBurst   = 1;
rx.GainSource         = 'Manual'; % Disables the AGC
rx.Gain               = 60; % Tuner gain in dB (-4 to 71 dB)
%% Acuiring data and displying the spectrogram
% This loop will run for 3 times
h_Fig=figure(1);
% tic
CapturedSignal = rx(); % Fetch a frame from the Pluto SDR
% toc
CapturedSignal = double(CapturedSignal)*10^((- par.Gain+par.PowerCalib)/20); % convert to double format and adjust the power level
STFT_Window =  round(length(CapturedSignal)/1000); % This is the window size of the Short Time Fourier Transform
spectrogram(CapturedSignal,STFT_Window,[],[],par.fs,'yaxis','centered');
grid on

%% Saving the captured signal and paramters
save('LoRaCapture2','par','CapturedSignal');
%% Save the figure
Filename='LoRa';
print(h_Fig, '-dpng','-r300',Filename);