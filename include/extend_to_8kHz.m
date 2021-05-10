function x_wb = extend_to_8kHz(x_nb)
%EXTEND_TO_8KHZ Extends an input narrowband speech signal X_NB with a
%cutoff frequency of 4 kHz to a wideband speech signal with a cutoff
%frequency of 8 kHz. 
%
% X_NB Narrowband speech signal with at a sampling rate of 8 kHz
% X_WB Bandwidth-extended wideband speech signal with a sampling rate of 16
% kHz.

addpath('../include/bandwidth_extension/ABE_explicit_memory_ICASSP18/3_Extension/')
addpath('../include/bandwidth_extension/Filters')
addpath('../include/bandwidth_extension/utilities')
global path_to_GMM;
path_to_GMM = '../include/bandwidth_extension/ABE_explicit_memory_ICASSP18/2_GMM_training/existing_models/';

past_frames = 2; future_frames=2; inp_feature= 'LogMFE_zs_pca'; dimX=10; dimY=10; 
x_wb = logmfe_lpc_abe(x_nb, inp_feature, past_frames, future_frames, dimX, dimY);

if size(x_wb,1)==1
    x_wb = x_wb'; % make the signal a column vector
end  
end


