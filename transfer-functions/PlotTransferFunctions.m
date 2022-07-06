%% Plot and compare the vocal tract transfer functions and extract formant frequencies

clc; close all; clearvars;
addpath('../include')

%% Parameters
fc_hi = 12e3;  % Upper cutoff frequency for transfer function display

% Input
tf_mm_files = dir('multimodal/*.txt');
tf_vtl_files = dir('1d/*.txt');

% Output
save_formants = true;  % Should the formant values be writte to a TXT file?
write_to_file = false;  % Should the transfer function plots be written to PDF files?
mm_formantFilepath_male = 'multimodal/m__formants_MM.csv';
mm_formantFilepath_female = 'multimodal/f__formants_MM.csv';
vtl_formantFilepath_male = '1d/m__formants_1d.csv';
vtl_formantFilepath_female = '1d/f__formants_1d.csv';
pdf_filepath = 'pdf/';

%%
sounds = ["a", "e", "i", "o", "u", "Y"];
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
    [pks, F, bw] = plotTransferFunctionAndFindFormants(tf, fc_hi);
    h = get(gca, 'Children');
    set(h(end), 'LineStyle', '--');
    title([tokens{1}, ', /', tokens{2}, '/'], 'interpreter', 'none');
    
    % Add first four formant values to table (one table for male, one file
    % for female
    if tokens{1} == 'm'
        vtl_formants_male = [vtl_formants_male;...
            {[tokens{2} ' freq'], F(1), F(2), F(3), F(4)};...
            {[tokens{2} ' amp'], pks(1), pks(2), pks(3), pks(4)};...
            {[tokens{2} ' bwth'], bw(1), bw(2), bw(3), bw(4)}];
    elseif tokens{1} == 'f'
        vtl_formants_female = [vtl_formants_female;...
            {[tokens{2} ' freq'], F(1), F(2), F(3), F(4)};...
            {[tokens{2} ' amp'], pks(1), pks(2), pks(3), pks(4)};...
            {[tokens{2} ' bwth'], bw(1), bw(2), bw(3), bw(4)}];
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
    [pks, F, bw] = plotTransferFunctionAndFindFormants(tf, fc_hi);
    hold off;
    title([tokens{1}, ', /', tokens{2}, '/'], 'interpreter', 'none');
    
    % Add first four formant values to table (one table for male, one file
    % for female
    if tokens{1} == 'm'
        mm_formants_male = [mm_formants_male;...
            {[tokens{2} ' freq'], F(1), F(2), F(3), F(4)};...
            {[tokens{2} ' amp'], pks(1), pks(2), pks(3), pks(4)};...
            {[tokens{2} ' bwth'], bw(1), bw(2), bw(3), bw(4)}];
    elseif tokens{1} == 'f'
        mm_formants_female = [mm_formants_female;...
            {[tokens{2} ' freq'], F(1), F(2), F(3), F(4)};...
            {[tokens{2} ' amp'], pks(1), pks(2), pks(3), pks(4)};...
            {[tokens{2} ' bwth'], bw(1), bw(2), bw(3), bw(4)}];
    end
    
    %% Add legend
    h = get(gca, 'Children');
    legend(findobj(h, 'Tag', 'Signal'), {'multimodal', '1d'}, 'Location', 'southeast');
    
    %% Write to file 
    if write_to_file
        filename =  [pdf_filepath, tokens{1}, '_', tokens{2}];
        savePdf(gca, filename);
    end
    
end


%% Write formants to file
if save_formants
    disp('Writing formants to file...')
    writetable(vtl_formants_male, vtl_formantFilepath_male, 'Delimiter',';');
    writetable(vtl_formants_female, vtl_formantFilepath_female, 'Delimiter',';');
    writetable(mm_formants_male, mm_formantFilepath_male, 'Delimiter',';');
    writetable(mm_formants_female, mm_formantFilepath_female, 'Delimiter',';');
    disp('...done.')
end

%%
function [pks, F, bw] = plotTransferFunctionAndFindFormants(tf, fc_hi)

% interpolate the transfer fucntion to have a frequency resolution of 1 Hz
freq = 1:fc_hi;
amp = db(interp1(tf.f_Hz(tf.f_Hz < fc_hi), tf.mag(tf.f_Hz < fc_hi), freq, 'spline'));

% find the peaks and their frequency
[pks, F] = findpeaks(amp, freq);

%% extract the bandwidth
bw = nan(size(pks));
for p = 1:length(pks)
    bw(p) = get3dBBandwidth(freq, amp, F(p), pks(p));
end

%% Plot the transfer function with the peaks indicated

findpeaks(amp, freq);
for p = 1:length(pks)
    text(F(p), pks(p) + 5, num2str(F(p)));
end
xlabel('Frequency [Hz]');
ylabel('Magnitude [dB]');
end
%%
function bw = get3dBBandwidth(freq, amp, idxPk, pk)
    nFreq = length(freq);

    % find left side -3 dB limit
    idxLow = max(idxPk-1, 1);
    while and(idxLow >= 1, ...
            and(amp(idxLow)>(pk-3), amp(idxLow)<amp(idxLow+1)))
        idxLow = idxLow-1;
        if idxLow == 1
            break
        end
    end
    
    % find right side -3 dB limit
    idxHigh = min(idxPk +1, nFreq);
    while and(idxHigh <= nFreq, ...
            and(amp(idxHigh)>(pk - 3), amp(idxHigh)<amp(idxHigh-1)))
        idxHigh = idxHigh + 1;
        if idxHigh == nFreq
            break
        end
    end
    
    % check if this corresponds to a peak: 
    % the lowest boundary must be on an increasing amplitude
    % and the highest boundary on a decreasing amplitude
    if and(...
        and(amp(idxLow+1) > (pk - 3), amp(idxLow) < amp(idxLow+1)),...
        and(amp(idxHigh-1) > (pk - 3), amp(idxHigh) < amp(idxHigh-1)))
    
        bw = freq(idxHigh) - freq(idxLow);
    else
        bw = nan;
    end
end
%%
function savePdf(ax, filename)
        try
            export_fig(ax, filename, '-pdf', '-transparent');
        catch ME
            switch ME.identifier
                case 'MATLAB:UndefinedFunction'
                    warning('export_fig (https://github.com/altmany/export_fig) is required to save the transfer functions to PDF files but was not found on the MATLAB path.')
                otherwise
                    rethrow(ME)
            end
        end
end