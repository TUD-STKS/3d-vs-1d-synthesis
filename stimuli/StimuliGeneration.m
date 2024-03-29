%% Generation of the stimuli for the listening experiments

clc; close all; clearvars;
% Make BWE results reproducible
rng(17); % Tiny artifact in male /u/
 

%%
addpath('../include')
addpath('../include/bandwidth_extension')
addpath('../include/LfGlottalFlow')
addpath('../include/VocalTractLabApi')

load('filters.mat');

plot_blended_tf = false;
save_blended_tf = false;

%% Transfer functions
tf_mm_path = '../transfer-functions/multimodal';
tf_mm_files = dir([tf_mm_path, '/*.txt']);
tf_1d_path = '../transfer-functions/1d';
tf_1d_files = dir([tf_1d_path, '/*.txt']);
tf_blended_path = '../transfer-functions/blended';

%% Stimulus file path
outpath = './dev/';
if ~exist(outpath, 'dir')
    mkdir(outpath)
end
%% Parameters
% Initial and final silence
sil_s = 0.250;

% Load natural pressure and f0 contours
natural_ref = load('./ref/pressure_and_pitch.mat');

% Fundamental frequencies (expressed as a multiplier on the reference f0)
f0.male = 1;
f0.female = 2;

% Sampling rates
oversampling = 4;
Fs_nb = 8000;
Fs_wb = 16000;
Fs_swb = 32000;
Fs_mm = 44100;
% Sampling rate of the output stimulus files
global Fs_out;
Fs_out = Fs_mm;

% Inflection frequency (where the dominant transfer function changes) in Hz
Finf = 4000;

%% Excitation
voice_qualities = {'modal', 'pressed'};
n_vq = length(voice_qualities);
dc = [0.0 0.0 0.0];

contour.male = [natural_ref.f0_params(:,1), natural_ref.f0_params(:,2) * f0.male];
contour.female = [natural_ref.f0_params(:,1), natural_ref.f0_params(:,2) * f0.female];

% Glottal flow signals using the LF model
Ug.male = [];
Ug.female = [];
for vq = 1 : n_vq
    [ug, tmale] = get_excitation(contour.male, dc(vq), Fs_out, oversampling, voice_qualities{vq}, 'male');
    Ug.male = [Ug.male, ug];
    [ug, tfemale] = get_excitation(contour.female, dc(vq), Fs_out, oversampling, voice_qualities{vq},'female');
    Ug.female = [Ug.female, ug];
end
%  figure(1);
%  subplot(2,1,1);
%  plot(tmale, Ug.male)
%  subplot(2,1,2);
%  plot(tfemale, Ug.female)
 
% Shape using the natural pressure contour
p_male = padarray(natural_ref.pressure_contour, length(Ug.male) - length(natural_ref.pressure_contour), 'post');
p_female = padarray(natural_ref.pressure_contour, length(Ug.female) - length(natural_ref.pressure_contour), 'post');
Ug.male = Ug.male .* p_male;
Ug.female = Ug.female .* p_female;

% Add final silence 
Ug.male = padarray(Ug.male, floor(sil_s * Fs_out) - length(Ug.male) + length(natural_ref.pressure_contour), 'post');
Ug.female = padarray(Ug.female, floor(sil_s * Fs_out) - length(Ug.female) + length(natural_ref.pressure_contour), 'post');

% Add initial
Ug.male = padarray(Ug.male, floor(sil_s * Fs_out), 'pre');
Ug.female = padarray(Ug.female, floor(sil_s * Fs_out), 'pre');

%% Synthesize
playlist = {};
for file = tf_mm_files'
    fprintf("Processing %s: ", file.name);
    [tf_mm, f_Hz] = read_tf(file);
    % Low pass at 12 kHz
	tf_mm = tf_mm .* freqz(H_AA, length(tf_mm), 'whole');
    tokens = split(file.name, '_');
    
    for vq = 1:n_vq
        fprintf("%s, ", voice_qualities{vq});
        %% Generate baseline (multimodal, full bandwidth)

        if tokens{1} == 'm'
            y = synthesize_from_tf(Ug.male(:,vq), tf_mm);
        elseif tokens{1} == 'f'
            y = synthesize_from_tf(Ug.female(:,vq), tf_mm);
        end
        
        % The multimodal transfer functions already only go up to 12 kHz,
        % so no additional low-pass filter necessary
        
        [~, item_name, ~] = fileparts(file.name);
        name = [item_name, '_MM_', voice_qualities{vq}, '.wav'];
        filename = fullfile(outpath, name);
        writewav(filename, normalizeLoudness(y, Fs_mm), Fs_out);
        playlist{end+1} = name;
    
        %% Replace high-frequency range by bandwidth extension
        [y, fs] = audioread(filename);
        % Limit the fullband sample to 4 kHz by resampling at 8 kHz
        % (including AA low pass and delay compensation)
        y = resample(y, Fs_nb, fs);
        % Extend to 8 kHz cutoff (also changes the sampling rate to 16 kHz
        y = extend_to_8kHz(y);
        % Extend to 16 kHz cutoff (also changes the sampling rate to 32 kHz
        y = extend_to_16kHz(y);
        % Upsample to 44.1 kHz;
        y = resample(y, Fs_out, Fs_swb);  
        % Get rid of artifacts in the silent parts by windowing
        y = cleanupBweSignal(y, sil_s * Fs_out); 
        
        % Filter at 12 kHz
        y = filtfilt(H_AA.sosMatrix, H_AA.ScaleValues, y);

        name = [item_name, '_bwe_', voice_qualities{vq}, '.wav'];
        filename = fullfile(outpath, name);
        writewav(filename, normalizeLoudness(y, Fs_out), Fs_out);
        playlist{end+1} = name;    

        %% Replace high-frequency range with 1d transfer function
        % Find corresponding 1d transfer function
        tf_1d = read_tf(fullfile(tf_1d_path, string(join(tokens(1:2), '_')) + "_1d.txt"));
        % Low pass at 12 kHz
        tf_1d = tf_1d .* freqz(H_AA, length(tf_1d), 'whole');
        tf_blend = blend_tf(tf_mm, tf_1d, Finf, Fs_mm); 
        
        % plot blended transfer function
        if plot_blended_tf
            figure, 
            subplot 211
            plot(20*log10(abs(tf_blend)), 'linewidth', 2)
            hold on
            plot(20*log10(abs(tf_1d)))
            plot(20*log10(abs(tf_mm)))
            xlim([0 1300])
            ylim([-100 20])
            title(string(join(tokens(1:2), '_')))
            legend('blend', '1d', 'mm', 'location', 'southeast')

            subplot 212
            hold on
            plot(angle(tf_blend), 'linewidth', 2)
            plot(angle(tf_1d))
            plot(angle(tf_mm))
            xlim([0 1300])
        end
        
        if save_blended_tf
            % Write the header
            tf_blend_filename = tf_blended_path + "/" + string(join(tokens(1:2), '_')) + '_blended.txt';
            fid = fopen(tf_blend_filename, 'w');
            fprintf(fid, "%s\n", "num_points: " + num2str(length(f_Hz)));
            fprintf(fid, "%s\n", "frequency_Hz  magnitude  phase_rad");           
            % Append the data
            tf_blend_data = [f_Hz, abs(tf_blend), angle(tf_blend)];
            for row = tf_blend_data'
                fprintf(fid, "%f  %f  %f\n", row);
            end
            fclose(fid)
        end
        
        if tokens{1} == 'm'
            y = synthesize_from_tf(Ug.male(:,vq), tf_blend);
        elseif tokens{1} == 'f'
            y = synthesize_from_tf(Ug.female(:,vq), tf_blend);
        end
        name = [item_name, '_1d_', voice_qualities{vq}, '.wav'];
        filename = fullfile(outpath, name);
        writewav(filename, normalizeLoudness(y, Fs_mm), Fs_out);
        playlist{end+1} = name;    
    end
    
    fprintf("done.\n");
end
fprintf("All done.\n");

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
audiowrite(filename, x, Fs);
end