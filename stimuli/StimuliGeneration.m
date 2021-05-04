%% Generation of the stimuli for the listening experiments

clc; close all; clearvars;
addpath('../include')
addpath('../include/bandwidth_extension')
addpath('../include/sap-voicebox/voicebox')
addpath('../include/VocalTractLabApi')

load('lp-fc_10kHz-fs_44p1kHz.mat');

%% Transfer functions
tf_mm_files = dir('../transfer-functions/multimodal/*.txt');
tf_vtl_files = dir('../transfer-functions/1d/*.txt');

%% Stimulus file path
outpath = './dev/';
if ~exist(outpath, 'dir')
    mkdir(outpath)
end
%% Parameters
% Initial and final silence
global sil_s;
sil_s = 0.250;
% Fade-in and out (in decimal percent)
global fade;
fade = 0.05;
% Sound duration
global dur_s;
dur_s = 0.5;

f0.male = 100;
f0.female = 200;

% Sampling rates
oversampling = 4;
Fs_base = 44100;
Fs_nb = 8000;
Fs_wb = 16000;
Fs_swb = 32000;
Fs_mm = 44100;
% Sampling rate of the output stimulus files
global Fs_out;
Fs_out = max([Fs_base, Fs_nb, Fs_wb, Fs_swb, Fs_mm]);

%% Excitation
contour.male = [[0, 0.55*dur_s, dur_s]', [1, 1.2, 0.9]'*f0.male];
contour.female = [[0, 0.55*dur_s, dur_s]', [1, 1.2, 0.9]'*f0.female];

% Glottal flow signals using the LF model
[Ug.male, tmale] = get_excitation(contour.male, 0.3, Fs_out, sil_s, fade, oversampling);
[Ug.female, tfemale] = get_excitation(contour.female, 0.3, Fs_out, sil_s, fade, oversampling);
figure(1);
subplot(2,1,1);
plot(tmale, Ug.male)
subplot(2,1,2);
plot(tfemale, Ug.female)
%% VTL baseline
% Synthesize by convolving excitation signals with vocal tract impulse
% response
playlist = [];

for file = tf_vtl_files'
    [tf, f_Hz] = read_tf(file);
    % The transfer functions are filtered to reduce ringing in the impulse
    % response
    tf = tf .* freqz(H_lp, length(tf), 'whole');
    tokens = split(file.name, '_');
    if tokens{1} == 'm'
        y = synthesize_from_tf(Ug.male, tf);
    elseif tokens{1} == 'f'
        y = synthesize_from_tf(Ug.female, tf);
    end
    [~, item_name, ~] = fileparts(file.name);
    name = [item_name, '_base', '.wav'];
    filename = fullfile(outpath, name);
    writewav(filename, y, Fs_out);
    playlist = [playlist; string(name)];
end

%% Multimodal method baseline
for file = tf_mm_files'
    [tf, f_Hz] = read_tf(file);
    tf = tf .* freqz(H_lp, length(tf));
    tokens = split(file.name, '_');
    if tokens{1} == 'm'
        y = synthesize_from_tf(Ug.male, tf);
    elseif tokens{1} == 'f'
        y = synthesize_from_tf(Ug.female, tf);
    end
    [~, item_name, ~] = fileparts(file.name);
    name = [item_name, '_base', '.wav'];
    filename = fullfile(outpath, name);
    writewav(filename, y, Fs_out);
    playlist = [playlist; name];
end

%% Write the playlist file
writetable(table(playlist), './dev/stimuli.m3u', ...
    'FileType', 'text', 'WriteVariableNames', false);

function writewav(filename, x, Fs)
x = x / max(abs(x)) * 0.95;
audiowrite(filename, x, Fs);
end