function [Ug, t] = get_excitation(f0, dc, Fs, silence_s, fade, oversampling, params)
%GET_EXCITATION This function returns a glottal flow signal with a
%specified f0 contour, voice quality, padded silence, and fade-in and out.
%   Fs: Sampling rate
%   f0: Fundamental frequency contour specified as a matrix. First column
%   dc: Amplitude of the DC component of the flow, relative to the maximum
%   amplitude.
%   is time instants, second column is the corresponding f0 values.
%   The specified values are interpolated using clamped spline
%   interpolation

if nargin < 7
    params = 'modal';
end

% Get an f0 contour
[t, f] = f0_contour(f0, Fs);

% Generate glottal flow 
Ug = [];
idx = 1;

if ischar(params)
    lf_params = get_LF_params(params);
else
    lf_params = params;
end

while idx <= length(f)
    % Get one period of glottal flow
    U0 = glottal_flow_lf(f(idx), Fs, oversampling, lf_params);
    Ug = [Ug; U0];
    idx = length(Ug)+1;
end

% Add DC component
flow_dc = dc * max(Ug);
Ug = flow_dc + Ug;

% Fade-in and out
Ug = Ug .* tukeywin(length(Ug), fade*2);

% Zero-padding
Ug = padarray(Ug, silence_s * Fs);
t = 0:length(Ug)-1 / Fs;
end

