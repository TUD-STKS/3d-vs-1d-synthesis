%% Generate a KLGLOTT88 pulse
% General equation taken from:
%      Klatt, Dennis H., and Laura C. Klatt. "Analysis, synthesis, and perception of voice quality variations among female and male talkers." the Journal of the Acoustical Society of America 87.2 (1990): 820-857.
% Equations for a and b taken from: 
%  Iseli, Markus, and Abeer Alwan. "An improved correction formula for the estimation of harmonic magnitudes and its application to open quotient estimation." 2004 IEEE international conference on acoustics, speech, and signal processing. Vol. 1. IEEE, 2004.
% (Equations were not included in the original Klatt paper)
% 
%

%%
% Length of the signal in seconds
T_s = 1;
% Fundamental frequency
f0_Hz = 100;
% Fundamental period
T0_s = 1/f0_Hz;
% Sampling rate (intentionally very high!)
Fs_Hz = 240e3;
% Amplitude of voicing
AV = 1;
% Open quotient
OQ = 0.5;

[t, gf] = klglott(AV, OQ, T0_s, Fs_Hz);

figure(1)
subplot(3,1,1); 
plot(t*1000, g)
xlabel('Time [ms]')

%% Show spectral shaping of noise
mu_noise = 0;
var_noise = 1;
long_noise_signal = random('Normal', mu_noise, var_noise, length(t)*200, 1);
% Calculate and show power spectrum
f_hi = 5e3;  % Upper cutoff for spectral display
figure(2)
subplot(2,1,1)
pspectrum(long_noise_signal, Fs_Hz, 'FrequencyLimits', [0, f_hi])
ylim([-30, 0])

% Shape the noise by high-pass filtering
% Filter to obtain roughly the spectrum from Fig. 7 in Hanson (1997):
% Glottal characteristics of female speakers
slope = 5;
Fc = 2000 / (Fs_Hz / 2);
[b, a] = designVarSlopeFilter(slope, Fc, "hi","Orientation","row");
% The cascaded structure can be reduced to the first stage
a = a(1,:);
b = b(1,:);

% Filter the noise signal
long_noise_shaped = filter(b, a, long_noise_signal);
% Show spectrum
figure(2)
subplot(2,1,2); 
pspectrum(long_noise_shaped, Fs_Hz, 'FrequencyLimits', [0, f_hi])

%% Create noise pulse
noise_pulse = random('Normal', mu_noise, var_noise, length(t), 1);

% Filter the noise signal
noise_shaped = filter(b,a, noise_pulse);

%% Merge noise and periodic parts
noise_amp = 0.0005;
gf = g + g / max(g) .* noise_shaped * noise_amp;
figure(1)
subplot(3,1,2)
plot(k*1000/Fs_Hz, gf)
xlabel('Time [ms]')

%% Concatenate pulses
num_pulses = ceil(T_s / T0_s);

excitation = repmat(gf, num_pulses, 1);
% Fade-in and out
excitation = excitation .* tukeywin(length(excitation), 0.1);
% Silence before and after
silence_s = 0.1;
excitation = padarray(excitation, silence_s*Fs_Hz);

t = linspace(0, T_s + 2*silence_s, (T_s + 2*silence_s)*Fs_Hz);
figure(1)
subplot(3,1,3)
plot(t, excitation)
xlabel('Time [s]')

% Downsample for playback
soundsc(downsample(excitation, 5), Fs_Hz/5)

