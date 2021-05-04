function [Ug, t] = get_excitation(f0, dc, Fs, silence_s, fade, oversampling)
%GET_EXCITATION This function returns a glottal flow signal with a
%specified f0 contour, voice quality, padded silence, and fade-in and out.
%   Fs: Sampling rate
%   f0: Fundamental frequency contour specified as a matrix. First column
%   dc: Amplitude of the DC component of the flow, relative to the maximum
%   amplitude.
%   is time instants, second column is the corresponding f0 values.
%   The specified values are interpolated using clamped spline
%   interpolation


% Get an f0 contour
[t, f] = f0_contour(f0, Fs);

% Generate glottal flow 
Ug = [];
idx = 1;

te = 0.60;
tp = 0.48;
ta = 0.0109;
tc = 0.5072;
params = [te, tp, ta, tc];

while idx <= length(f)
    % Get one period of glottal flow
    U0 = glottal_flow_lf(f(idx), Fs, oversampling, 1/f(idx), params);
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

