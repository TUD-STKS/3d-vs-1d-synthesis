%% Generation of the stimuli for the listening experiments

clc; close all; clearvars;
addpath('../include')
addpath('../include/bandwidth_extension')
%% Parameters
% Initial and final silence
global sil_s;
sil_s = 0.250;
% Sound duration
global dur_s;
dur_s = 0.5;

% Sampling rates
Fs_vtl = 44100;
Fs_nb = 8000;
Fs_wb = 16000;
Fs_swb = 32000;
global Fs_out;
Fs_out = Fs_vtl;  % Sampling rate of the output stimulus files

%% Baseline VTL stimuli
baseline_files = [
    "dev\a_modal_1s_VTL.wav",
    "dev\e_modal_1s_VTL.wav",
    "dev\i_modal_1s_VTL.wav",
    "dev\o_modal_1s_VTL.wav",
    "dev\a_breathy_1s_VTL.wav",
    "dev\e_breathy_1s_VTL.wav",
    "dev\i_breathy_1s_VTL.wav",
    "dev\o_breathy_1s_VTL.wav",
    "dev\a_pressed_1s_VTL.wav",
    "dev\e_pressed_1s_VTL.wav",
    "dev\i_pressed_1s_VTL.wav",
    "dev\o_pressed_1s_VTL.wav"    
    ];

n = 1;
playlist = [];
for file = baseline_files'
    figure(n);
    n = n + 1;
    %% Baseline VTL synthesis
    [x_vtl_base, Fs] = audioread(file);
    if Fs ~= Fs_vtl
        error('Unexpected sampling rate!');
    end
    [p, filename, ext] = fileparts(file);
    filename = filename + '_base' + ext;
   
    % Crop, fade, pad with silence, normalize and write to file
    saveStimulusFile(p + filesep + filename, x_vtl_base, Fs_vtl);
    
    % Stimulus is added to playlist last (see below)
    %% Narrowband VTL
    subplot(4,1,1);
    plotSpectrogram(x_vtl_base, Fs_vtl)
    % Band-limit to 4 kHz by downsampling (including an AA filter)
    x_vtl_nb = resample(x_vtl_base, Fs_nb, Fs_vtl);
    subplot(4,1,2);
    plotSpectrogram(resample(x_vtl_nb, Fs_vtl, Fs_nb), Fs_vtl);    
        
    % Pad with silence, normalize and write to file
    [p, filename, ext] = fileparts(file);
    filename = filename + '_nb' + ext;
    saveStimulusFile(p + filesep + filename, x_vtl_nb, Fs_nb);
    playlist = [playlist; filename];
    %% Wideband VTL
    % Narrow-band to wide-band
    x_vtl_wb = extend_to_8kHz(x_vtl_nb);
    subplot(4,1,3);
    plotSpectrogram(resample(x_vtl_wb, Fs_vtl, Fs_wb), Fs_vtl);
    
    % Pad with silence, normalize and write to file
    [p, filename, ext] = fileparts(file);
    filename = filename + '_wb' + ext;
    saveStimulusFile(p + filesep + filename, x_vtl_wb, Fs_wb);
    playlist = [playlist; filename];
    %% Super-wideband VTL from wideband
    % Wide-band to super-wideband
    x_vtl_swb = extend_to_16kHz(x_vtl_wb);
    subplot(4,1,4);
    plotSpectrogram(resample(x_vtl_swb, Fs_vtl, Fs_swb), Fs_vtl);
    
    % Pad with silence, normalize and write to file
    [p, filename, ext] = fileparts(file);
    filename = filename + '_swb' + ext;
    saveStimulusFile(p + filesep + filename, x_vtl_swb, Fs_swb);
    playlist = [playlist; filename];
    
    % Add baseline file to playlist last
    [p, filename, ext] = fileparts(file);
    filename = filename + '_base' + ext;
    playlist = [playlist; filename];
end

%% Write a playlist file
writetable(table(playlist), './dev/stimuli.m3u', ...
    'FileType', 'text', 'WriteVariableNames', false);
%%
function x = cropToCenter(x, Fs)
% Crop
global dur_s;
mid = floor(length(x) / 2);
halfDur = floor(dur_s * Fs / 2);
start = mid - halfDur;
stop = mid + halfDur;
x = x(start:stop);
% Fade in and out
x = x .* tukeywin(length(x), 0.4);
end

function plotSpectrogram(x, Fs)
%x = filtfilt([1, -0.95], 1, x);
frameLength = floor(0.005 * Fs);
window = gausswin(frameLength);
noverlap = floor(0.75 * frameLength);
spectrogram(x, window, noverlap, [], Fs, 'yaxis');
colormap('gray')
end

function saveStimulusFile(filename, x, Fs)
global Fs_out;
global sil_s;
% Crop center segment and fade in and out
x = cropToCenter(x, Fs);
x = resample(x, Fs_out, Fs);
x = padarray(x, sil_s * Fs_out);
x = x / max(abs(x)) * 0.95;
audiowrite(filename, x, Fs_out);
end