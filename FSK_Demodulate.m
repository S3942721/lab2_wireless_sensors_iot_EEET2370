function [symbols_message] = FSK_Demodulate(message,SF)
%   This code has been written by Bassel Al Homssi based on the FSK demodulation.
%   This code is to demodulate the LoRa signal to FSK signal
%   Code last updated 17.07.2019
n_symbol = 2^SF ;
n_message = length(message)/n_symbol ;
symbols_message = zeros(1,n_message) ;
for Ctr = 1 : n_message
    [~,ind] = max(fft(message((Ctr-1).*n_symbol+1:Ctr*n_symbol))) ;
    symbols_message(Ctr) = ind ;
end
end