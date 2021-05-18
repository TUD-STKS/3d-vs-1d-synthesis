%% Try out different parameters for the LF model
clc; clearvars;

%% Transfer function for testing
tf_male = read_tf('../transfer-functions/multimodal/m_a_MM.txt');
tf_female = read_tf('../transfer-functions/multimodal/f_a_MM.txt');

%%
% Output sampling rate
Fs_out = 44100;
% Oversampling for flow calculation
oversampling = 4;
%% Intonation
% Total duration
dur_s = 0.5;
% Fade-in and out (in decimal percent)
fade = 0.05;
% Initial and final silence
sil_s = 0.250;
% Fundamental frequency
f0.male = 100;
f0.female = 200;
contour.male = [[0, 0.55*dur_s, dur_s]', [1, 1.2, 0.9]'*f0.male];
contour.female = [[0, 0.55*dur_s, dur_s]', [1, 1.2, 0.9]'*f0.female];

%% LF parameters
lf_params.AMP = 300;
lf_params.OQ = 0.7;
lf_params.SQ = 3.0;
lf_params.TL = 0.1;
lf_params.SNR = 40.0;

%% Generate excitation signal
[ug_male, t_male] = get_excitation(contour.male, 0.0, Fs_out, sil_s, fade, oversampling, lf_params);
[ug_female, t_female] = get_excitation(contour.female, 0.0, Fs_out, sil_s, fade, oversampling, lf_params);

%% Synthesize audio
y_male = synthesize_from_tf(ug_male, tf_male);
y_female = synthesize_from_tf(ug_female, tf_female);

%% Play
y_male = normalizeLoudness(y_male, Fs_out);
y_female = normalizeLoudness(y_female, Fs_out);
playblocking(audioplayer(y_male, Fs_out))
playblocking(audioplayer(y_female, Fs_out))

%%
function x = normalizeLoudness(x, Fs)
[loudness, ~] = integratedLoudness(x,Fs);
target = -23;
gaindB = target - loudness;
gain = 10^(gaindB/20);
x = x.*gain;
end