function tf = vttf(vtparameters, N, opts)
%VTTF Calculates the Vocal Tract Transfer Function for a given set of vocal
%tract parameters VTPARAMETERS
%
% N: Number of transfer function samples.


libName = 'VocalTractLabApi';

mag = zeros(1, N);
phase = zeros(1, N);
[failed, ~, mag, phase] = ...
  calllib(libName, 'vtlGetTransferFunction', vtparameters, ...
    N, opts, mag, phase);

if (failed)
    error('Could not retrieve vocal tract transfer functioN!')
end

tf = mag .* exp(1i*phase);

% Returned transfer function should be column vector
tf = tf';
end

