%% Plot spectrograms of the stimuli from different conditions side-by-side
clearvars; close all; clc;
addpath('../include')
%% 
stimuli_files = dir('dev/*.wav');

phonation_type = "modal";

for file = stimuli_files'
    fprintf("Processing %s...", file.name);
    [y, Fs] = audioread(fullfile(file.folder, file.name));
    
    tokens = split(file.name, '_');
    if(tokens{end}(1:end-4) ~= phonation_type)
        continue
    end
    %% Find the right subplot based on gender, sound, and condition
    gender = ["f", "m"];
    fullgender = ["female", "male"];
    sound = ["a", "e", "i", "o", "u"];
    condition = ["MM", "1d", "bwe"];
    figure(find(gender == tokens{1}));
    row = find(sound == tokens{2});
    col = find(condition == tokens{end-1});
    subplot(5, 3, sub2ind([3, 5], col, row));
    plotSpectrogram(y, Fs);
    colorbar off;
    if row ~= 5 
        xlabel(""); 
    else
        xlabel("Time [ms]");
    end
    if col ~= 1
        ylabel("");
    else
        ylabel("Frequency [kHz]");
    end
    title("/" + tokens{2} + "/, MM low, " + tokens{end-1} + " high");
    fprintf("done.\n");
end
figure(1)
sgtitle(fullgender(1));
figure(2)
sgtitle(fullgender(2));

fprintf("All done.\n");