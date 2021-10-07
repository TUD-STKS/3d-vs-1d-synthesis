%% Extract the timing information for the synthetic vowels from a natural utterance
clc, clearvars, close all
%%
addpath('../../include')

%% Load file and crop to sound
[y, Fs] = audioread('a_long_sentence.wav');
start_s = 1.503686; % Manually determined
end_s = 2.012398;   % Manually determined
total_duration = end_s - start_s;
t_s = 0:1/Fs:total_duration;
y = y(start_s*Fs:end_s*Fs);
soundsc(y, Fs)

%% Plot waveform
plot(t_s, y, 'DisplayName', 'Recording')
xlabel('Time [s]')
ylabel('Amplitude')

%% Find f0 contour
[f0, loc] = pitch(y, Fs, 'Range', [50, 200]);
yyaxis right;
plot(loc/Fs, f0, 'o', 'DisplayName', 'Measured $f_0$')
ylim([80 110])
ylabel('$f_0$ [Hz]')
yyaxis left

%% Match f0 contour
f0_start = f0(1);
t_start = 0.0;
[f0_mid, mid_loc] = max(f0);
t_mid = loc(mid_loc+3)/Fs;
f0_end = f0(end-1);
t_end = loc(end-4)/Fs;
f0_params = [t_start, f0_start; t_mid, f0_mid; t_end, f0_end; t_s(end), f0_end];
[t, f] = f0_contour(f0_params, Fs);
yyaxis right;
hold on;
plot(t, f, 'x', 'DisplayName', 'Fitted $f_0$');
hold off;
yyaxis left;


%% Calculate amplitude envelope
N_mean = 1/mean(f0) * Fs;
% Do very rough peak envelope estimation
[upper_env, ~] = envelope(y, floor(2.5*N_mean), 'peak');
hold on;
plot(t_s, upper_env, 'DisplayName', 'Peak envelope')
hold off;

%% Design shaping window to match envelope
% Find the position of the maximum
[amp_in, loc] = max(upper_env);
tFadeIn_s = loc/Fs;
% Create fade-in part of window
fadein = hann(2*loc);
fadein = fadein(1:loc).^(0.5);

% Manually determine the start of the fade out in the plot
tFadeOut_s = 0.394;
% Get amplitude drop 
amp_out = upper_env(floor(tFadeOut_s*Fs));
amp_drop = amp_out / amp_in;
% Create fade-out part of window
fadeout = hann(floor(2*(t_s(end) - tFadeOut_s)*Fs));
fadeout = fadeout(length(fadeout) / 2 : end ).^2;

% Create linear drop in between
amp_slope = (amp_drop - 1) / (tFadeOut_s - tFadeIn_s);
drop = 1 + amp_slope * (0:1/Fs:(tFadeOut_s - tFadeIn_s));

% Concatenate segments
pressure_contour = [fadein; drop'; amp_drop*fadeout];

hold on;
plot(t_s, pressure_contour*amp_in, '--', 'DisplayName', 'Fitted pressure contour')
hold off;

legend(gca, 'Interpreter','latex');

%%
%save('pressure_and_pitch.mat', 'pressure_contour', 'f0_params') 
 
