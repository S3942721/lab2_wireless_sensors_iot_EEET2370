function [message] = LoRa_Demodulate(signal,SF,Bandwidth)
%   This code has been written by Bassel Al Homssi based on the LoRa
%   demodulation specification for the PHY layer.
%   This code is to demodulate the LoRa signal to FSK signal
%   Code last updated by Da Huang on 23.03.2025
n_symbol = 2^SF ;
n_signal = floor(length(signal)/n_symbol) ;
upChirps_demod = loramod(zeros(1,n_signal),SF,Bandwidth,Bandwidth) ;
sniff_signal = signal(1:length(upChirps_demod)).*upChirps_demod ;
fft_sync = zeros(1,n_signal) ;
for Ctr = 1 : n_signal
    fft_sync(Ctr) = max(fft(sniff_signal((Ctr-1).*n_symbol+1:Ctr*n_symbol))) ;
end
[~,sync_ind] = sort(abs(fft_sync)) ;
sync = sort(sync_ind(end-1:end)) ;
sync = sync(end) + 1 ;
n_preamble = sync - 5 ;
dnChirps_demod = loramod(zeros(1,n_preamble),SF,Bandwidth,Bandwidth,-1) ;
pream_signal = signal(1:length(dnChirps_demod)).*dnChirps_demod ;
symbols_pream = zeros(1,n_preamble) ;
for Ctr = 1 : n_preamble
    [~,ind] = max(fft(pream_signal((Ctr-1).*n_symbol+1:Ctr*n_symbol))) ;
    symbols_pream(Ctr) = ind ;
end
symbol_offset = mode(symbols_pream) ;
message_start_ind = (n_preamble + 4.25)*n_symbol ;
n_message = floor((length(signal) - message_start_ind + 1)/n_symbol) ;
dnChirps_demod = loramod(zeros(1,n_message),SF,Bandwidth,Bandwidth,-1) ;
message = signal(message_start_ind:message_start_ind+length(dnChirps_demod)-1).*dnChirps_demod ;
message = message.*exp(2.*pi.*j.*symbol_offset.*(1:length(message))/(2^SF))' ;
end
function [y] = loramod(x,SF,BW,fs,varargin)
%   This code has been written by Bassel Al Homssi based on the LoRa
%   demodulation specification for the PHY layer.
%   This code is to demodulate the LoRa signal to FSK signal
%   Code last updated 17.07.2019
if (nargin < 4)
    error(message('comm:pskmod:numarg1'));
end
if (nargin > 5)
    error(message('comm:pskmod:numarg2'));
end
if (~isreal(x) || any(any(ceil(x) ~= x)) || ~isnumeric(x))
    error(message('comm:pskmod:xreal1'));
end
M = 2^SF ;
if (~isreal(M) || ~isscalar(M) || M<=0 || (ceil(M)~=M) || ~isnumeric(M))
    error(message('comm:pskmod:Mreal'));
end
if ((min(min(x)) < 0) || (max(max(x)) > (M-1)))
    error(message('comm:pskmod:xreal2'));
end
if nargin == 4
    Inv = 1 ;
elseif nargin == 5
    Inv = varargin{1} ;
end
Ts = 2^SF/BW ;
beta = BW/(2*Ts) ;
gamma = (x + M/2)*BW/M ;
n_symbol = fs.*2^SF/BW ;
t_symbol = (0:n_symbol-1).*1/fs ;
y = exp(j*2*pi*t_symbol'*gamma-j*2*pi*beta*t_symbol'.^2*Inv) ;
y = reshape(y,1,numel(y))' ;
end