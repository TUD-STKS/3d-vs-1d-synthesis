%% Generation of the stimuli for the listening experiments

clc; close all; clearvars;
addpath('../include')
addpath('../include/bandwidth_extension')
addpath('../include/sap-voicebox/voicebox')
addpath('../include/VocalTractLabApi')

load('filters.mat');

%% Transfer functions
tf_mm_path = '../transfer-functions/multimodal';
tf_mm_files = dir([tf_mm_path, '/*.txt']);
tf_1d_path = '../transfer-functions/1d';
tf_1d_files = dir([tf_1d_path, '/*.txt']);

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
Fs_wb = 16000;
Fs_swb = 32000;
Fs_mm = 44100;
% Sampling rate of the output stimulus files
global Fs_out;
Fs_out = Fs_mm;

%% Excitation
contour.male = [[0, 0.55*dur_s, dur_s]', [1, 1.2, 0.9]'*f0.male];
contour.female = [[0, 0.55*dur_s, dur_s]', [1, 1.2, 0.9]'*f0.female];

% Glottal flow signals using the LF model
[Ug.male, tmale] = get_excitation(contour.male, 0.0, Fs_out, sil_s, fade, oversampling);
[Ug.female, tfemale] = get_excitation(contour.female, 0.0, Fs_out, sil_s, fade, oversampling);
figure(1);
subplot(2,1,1);
plot(tmale, Ug.male)
subplot(2,1,2);
plot(tfemale, Ug.female)

%% Synthesize
playlist = {};
for file = tf_mm_files'
    [tf_mm, f_Hz] = read_tf(file);
    % Low pass at 20 kHz
	tf_mm = tf_mm .* freqz(H_AA, length(tf_mm), 'whole');
    tokens = split(file.name, '_');
    
    %% Generate baseline (multimodal, full bandwidth)
    if tokens{1} == 'm'
        y = synthesize_from_tf(Ug.male, tf_mm);
    elseif tokens{1} == 'f'
        y = synthesize_from_tf(Ug.female, tf_mm);
    end
    [~, item_name, ~] = fileparts(file.name);
    name = [item_name, '_MM', '.wav'];
    filename = fullfile(outpath, name);
    writewav(filename, normalizeLoudness(y, Fs_mm), Fs_out);
    playlist{end+1} = name;
    
    %% Replace high-frequencey range by bandwidth extension
    % Limit the fullband sample to 8 kHz by resampling at 16 kHz
    % (including AA low pass and delay compensation)
    [y, fs] = audioread(filename);
    y = resample(y, Fs_wb, fs);
    % Extend to 16 kHz cutoff (also changes the sampling rate to 32 kHz
    y = extend_to_16kHz(y);
    % Upsample to 44.1 kHz;
    y = resample(y, Fs_out, Fs_swb);
    name = [item_name, '_bwe', '.wav'];
    filename = fullfile(outpath, name);
    writewav(filename, normalizeLoudness(y, Fs_out), Fs_out);
    playlist{end+1} = name;    
    
    %% Replace high-frequency range with 1d transfer function
    % Find corresponding 1d transfer function
    tf_1d = read_tf(fullfile(tf_1d_path, string(join(tokens(1:2), '_')) + "_1d.txt"));
    % Low pass at 20 kHz
	tf_1d = tf_1d .* freqz(H_AA, length(tf_1d), 'whole');
    tf_blend = blend_tf(f_Hz, tf_mm, tf_1d, H_lp, H_hp); 
    if tokens{1} == 'm'
        y = synthesize_from_tf(Ug.male, tf_blend);
    elseif tokens{1} == 'f'
        y = synthesize_from_tf(Ug.female, tf_blend);
    end
    name = [item_name, '_1d', '.wav'];
    filename = fullfile(outpath, name);
    writewav(filename, normalizeLoudness(y, Fs_mm), Fs_out);
    playlist{end+1} = name;        
end

%% Write the playlist file
writetable(table(playlist'), './dev/stimuli.m3u', ...
    'FileType', 'text', 'WriteVariableNames', false);

function x = normalizeLoudness(x, Fs)
[loudness, ~] = integratedLoudness(x,Fs);
target = -23;
gaindB = target - loudness;
gain = 10^(gaindB/20);
x = x.*gain;
end

function writewav(filename, x, Fs)
x = x / max(abs(x)) * 0.95;
audiowrite(filename, x, Fs);
end