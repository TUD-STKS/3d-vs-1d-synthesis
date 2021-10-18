function [Ug, t] = get_excitation(f0, dc, Fs, oversampling, params, gender)
%GET_EXCITATION This function returns a glottal flow signal with a
%specified f0 contour, voice quality, padded silence, and fade-in and out.
%   Fs: Sampling rate
%   f0: Fundamental frequency contour specified as a matrix. First column
%   dc: Amplitude of the DC component of the flow, relative to the maximum
%   amplitude.
%   is time instants, second column is the corresponding f0 values.
%   The specified values are interpolated using clamped spline
%   interpolation

if nargin < 5
    params = 'modal';
    gender = 'male';
end

if nargin < 6
   gender = 'male';
end

% Get an f0 contour
[t, f] = f0_contour(f0, Fs);

% Generate glottal flow 
Ug = [];
idx = 1;

if ischar(params)
    lf_params = get_LF_params(params, gender);
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

% Extend time vector if necessary
if length(t) < length(Ug)
    t = linspace(0, length(Ug)/Fs, length(Ug));
end

end

