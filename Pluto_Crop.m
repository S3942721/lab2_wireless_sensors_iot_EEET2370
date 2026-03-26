function [signal] = Pluto_Crop(x,Bandwidth,Fs,PowerThreshold)
%   This code has been written by Bassel Al Homssi based on energy detection.
%   This code is to detect the precense of LoRa signal within the Rx frame
%   Code last updated by Da Huang on 23.03.2025

Guard_length = 100 ;
x_tmp = lowpass(x,Bandwidth,Fs);
condition_one  = abs(x_tmp) > 10^(PowerThreshold/20)  ;

ind_str = 1 ;
ind_end = length(x_tmp) ;

if sum(condition_one(1:Guard_length)) > 0
    condition_zero = (abs(x_tmp(Guard_length:end)) < 10^(PowerThreshold/20)) ;
    ind_str = Guard_length + find(condition_zero == 1,1) ;
end
if sum(condition_one(end - Guard_length : end)) > 0
    condition_zero = flipud(abs(x_tmp(end - Guard_length:end)) < 10^(PowerThreshold/20)) ;
    ind_end = length(x_tmp) - Guard_length - find(condition_zero == 1,1) ;
end

signal = x(ind_str:ind_end) ;
signal = signal(abs(signal) > 10^(PowerThreshold/20)) ;

if isempty(signal)
    error('Please choose another power threshold, or repeat the capture process and make sure the signal is in the middle')
else
    figure
    pspectrum(signal,Bandwidth,'spectrogram')
    title('Detected LoRa signal')
    signal = resample(signal,Bandwidth,Fs);
end
end

