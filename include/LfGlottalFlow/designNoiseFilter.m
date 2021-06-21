function Hd = designNoiseFilter(Fs)

%% This function designs a low-pass filter to shape the glottal noise
% According to Hillman et al. "Characteristics of the glottal turbulent
% noise source" (1983), the glottal noise has a spectral tilt of approx.
% -9.4 dB/kHz

% Define the filter response with slope of -9.4 dB / kHz
fresp = @(x) db2mag(0 - 9.4*x/1000);

% Create vector of frequency taps
f_Hz = 0:10:Fs/2;
% Normalized frequencies
F = f_Hz/(Fs/2);

% Get the filter response at those frequencies
A = fresp(f_Hz);

% Filter order
N = 512;

% Design filter
d = fdesign.arbmag('N,F,A', N, F, A);
Hd = design(d,'freqsamp','SystemObject',true);

end
