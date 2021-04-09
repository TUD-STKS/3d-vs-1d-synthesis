function x_swb = extend_to_16kHz(x_wb)
%EXTEND_TO_16KHZ Extends an input wideband speech signal X_WB with a
%cutoff frequency of 8 kHz to a super-wideband speech signal with a cutoff
%frequency of 16 kHz. 
%
% X_WB Wideband speech signal with at a sampling rate of 16 kHz
% X_SWB Bandwidth-extended super-wideband speech signal with a sampling
% rate of 32 kHz.
addpath('../include/bandwidth_extension/SWBE_LPAS_ICASSP18/')
addpath('../include/bandwidth_extension/Filters')
Fs_swb = 32000;
ms = 0.001;
winlen_swb = 25*ms*Fs_swb; 
LP_order_wb = 16;
Nfft = 1024;
gain = 1; % GAIN value can be adjusted to check the effect of energy on speech quality
% Set to 1 for the proposed method and the basline used in the paper

%% Load filters
LPF = load('LPF_7700_8300.mat'); dLPF=(length(LPF.h_n)+1)/2;
HPF = load('HPF_7700_8300.mat'); dHPF=(length(HPF.h_n)+1)/2;
BPF = load('BPF_4000_8000.mat'); dBPF=(length(BPF.h_n)+1)/2;

filters = [];
filters.LPF = LPF;
filters.HPF = HPF;
filters.BPF = BPF;

if size(x_wb,2)==1
    x_wb = x_wb'; % make the file as a row vector
end   
x_swb = SWBE_LPAS(x_wb, LP_order_wb, Nfft, winlen_swb, gain, filters);

if size(x_swb,1)==1
    x_swb = x_swb'; % make the signal a column vector
end  
end