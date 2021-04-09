%% Plot and compare the vocal tract transfer functions and extract formant frequencies

clc; close all; clearvars;
addpath('../include')

%% Parameters
fc_hi = 5e3;  % Upper cutoff frequency for transfer function display

% Input
tf_files = dir('multimodal/*.txt');

% Output
save_formants = true;
formantFilepath_male = 'multimodal/m__formants_MM.csv';
formantFilepath_female = 'multimodal/f__formants_MM.csv';



%% 
formants_male = table('Size', [0, 4], ...
'VariableTypes', {'double', 'double', 'double', 'double'}, ...
'VariableNames', {'F1', 'F2', 'F3', 'F4'});
formants_female = formants_male;


fileIdx = 1;
for file = tf_files'
    tf = readtable(fullfile(file.folder, file.name), 'FileType', 'text', 'HeaderLines', 1);
    % The first row contains garbage with inconsistent formatting
    tf.Properties.VariableNames = {'f_Hz', 'mag', 'phi'};    
    
    % Plot transfer function and identify formants
    figure(fileIdx);    
    [pks, F] = findpeaks(db(tf.mag(tf.f_Hz < fc_hi)), tf.f_Hz(tf.f_Hz < fc_hi));
    findpeaks(db(tf.mag(tf.f_Hz < fc_hi)), tf.f_Hz(tf.f_Hz < fc_hi));
    text(F, pks + 3, num2str(F))
    xlabel('Frequency [Hz]');
    ylabel('Magnitude [dB]');
    title(file.name, 'interpreter', 'none');
    fileIdx = fileIdx + 1;
    
    % Add first four formant values to table (one table for male, one file
    % for female
    if file.name(1) == 'm'
        formants_male = [formants_male; {F(1), F(2), F(3), F(4)}];
    elseif file.name(1) == 'f'
        formants_female = [formants_female; {F(1), F(2), F(3), F(4)}];
    end      
end

%% Write formants to file
if save_formants
    disp('Writing formants to file...')
    writetable(formants_male, formantFilepath_male)
    writetable(formants_female, formantFilepath_female)
    disp('...done.')
end


