%% Plot and compare the vocal tract transfer functions and extract formant frequencies

clc; close all; clearvars;
addpath('../include')

%% Parameters
fc_hi = 5e3;  % Upper cutoff frequency for transfer function display

% Input
tf_mm_files = dir('multimodal/*.txt');
tf_vtl_files = dir('1d/*.txt');

% Output
save_formants = false;
mm_formantFilepath_male = 'multimodal/m__formants_MM.csv';
mm_formantFilepath_female = 'multimodal/f__formants_MM.csv';
vtl_formantFilepath_male = '1d/m__formants_1d.csv';
vtl_formantFilepath_female = '1d/f__formants_1d.csv';

%%
sounds = ["a", "e", "i", "o", "u"];
gender = ["m", "f"];

%% Baseline VTL
vtl_formants_male = table('Size', [0, 5], ...
'VariableTypes', {'string', 'double', 'double', 'double', 'double'}, ...
'VariableNames', {'sound', 'F1', 'F2', 'F3', 'F4'});
vtl_formants_female = vtl_formants_male;

for file = tf_vtl_files' 
    tf = readtable(fullfile(file.folder, file.name));
    tf.Properties.VariableNames = {'f_Hz', 'mag', 'phi'};    
    
    tokens = split(file.name, '_');
    %% Plot transfer function and identify formants
    % Plot male speaker in even figures and female in odd
    figureIdx = (2*find(sounds == tokens{2}))-1 + find(gender == tokens{1}) - 1;
    figure(figureIdx);     
    [pks, F] = plotTransferFunctionAndFindFormants(tf, fc_hi);
    h = get(gca, 'Children');
    set(h(end), 'LineStyle', '--');
    title([tokens{1}, ', /', tokens{2}, '/'], 'interpreter', 'none');
    
    % Add first four formant values to table (one table for male, one file
    % for female    
    if tokens{1} == 'm'
        vtl_formants_male = [vtl_formants_male; {tokens{2}, F(1), F(2), F(3), F(4)}];
    elseif tokens{1} == 'f'
        vtl_formants_female = [vtl_formants_female; {tokens{2}, F(1), F(2), F(3), F(4)}];
    end      
end



%% Multi-modal method
mm_formants_male = table('Size', [0, 5], ...
'VariableTypes', {'string', 'double', 'double', 'double', 'double'}, ...
'VariableNames', {'sound', 'F1', 'F2', 'F3', 'F4'});
mm_formants_female = mm_formants_male;

for file = tf_mm_files'
    tf = readtable(fullfile(file.folder, file.name), 'FileType', 'text', 'HeaderLines', 1);
    % The first row contains garbage with inconsistent formatting
    tf.Properties.VariableNames = {'f_Hz', 'mag', 'phi'};    
    
    %% Plot transfer function and identify formants
    % Plot male speaker in even figures and female in odd
    tokens = split(file.name, '_');
    figureIdx = (2*find(sounds == tokens{2}))-1 + find(gender == tokens{1}) - 1;
    figure(figureIdx);     
    hold on;
    [pks, F] = plotTransferFunctionAndFindFormants(tf, fc_hi);
    hold off;    
    title([tokens{1}, ', /', tokens{2}, '/'], 'interpreter', 'none');
    % Add first four formant values to table (one table for male, one file
    % for female    
    if tokens{1} == 'm'
        mm_formants_male = [mm_formants_male; {tokens{2}, F(1), F(2), F(3), F(4)}];
    elseif tokens{1} == 'f'
        mm_formants_female = [mm_formants_female; {tokens{2}, F(1), F(2), F(3), F(4)}];
    end 
    
    %% Add legend
    h = get(gca, 'Children');
    legend(findobj(h, 'Tag', 'Signal'), {'multimodal', '1d'}, 'Location', 'southeast');
    
end



%% Write formants to file
if save_formants
    disp('Writing formants to file...')
    writetable(mm_formants_male, mm_formantFilepath_male, 'Delimiter',' ');
    writetable(mm_formants_female, mm_formantFilepath_female, 'Delimiter',' ');
    disp('...done.')
end

%%
function [pks, F] = plotTransferFunctionAndFindFormants(tf, fc_hi)
   [pks, F] = findpeaks(db(tf.mag(tf.f_Hz < fc_hi)), tf.f_Hz(tf.f_Hz < fc_hi));
    findpeaks(db(tf.mag(tf.f_Hz < fc_hi)), tf.f_Hz(tf.f_Hz < fc_hi));
    text(F, pks + 3, num2str(F))
    xlabel('Frequency [Hz]');
    ylabel('Magnitude [dB]');
end
