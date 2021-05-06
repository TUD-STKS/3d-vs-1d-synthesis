%% Plot spectrograms of the stimuli from different conditions side-by-side
clearvars; close all; clc;
addpath('../include')
%% 
stimuli_files = dir('dev/*.wav');

for file = stimuli_files'
    [y, Fs] = audioread(fullfile(file.folder, file.name));
    
    tokens = split(file.name, '_');
    
    %% Find the right subplot based on gender, sound, and condition
    gender = ["f", "m"];
    fullgender = ["female", "male"];
    sound = ["a", "e", "i", "o", "u"];
    condition = ["MM", "1d"];
    figure(find(gender == tokens{1}));
    row = find(sound == tokens{2});
    col = find(condition == tokens{end}(1:end-4));
    subplot(5, 2, sub2ind([2, 5], col, row));
    plotSpectrogram(y, Fs);
    title("/" + tokens{2} + "/, MM low, " + tokens{end}(1:end-4) + " high");
end
figure(1)
sgtitle(fullgender(1));
figure(2)
sgtitle(fullgender(2));