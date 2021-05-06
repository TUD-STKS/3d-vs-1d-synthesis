function Plot_VTLvsMM

% Plot transfer functions of simulated vowels

close all    

dirMM = 'multimodal/';
dir1d = '1d/';
fileNamesMM = {...
    'f_a_MM.txt',...
    'f_e_MM.txt',...
    'f_i_MM.txt',...
    'f_o_MM.txt',...
    'f_u_MM.txt',...
    'm_a_MM.txt',...
    'm_e_MM.txt',...
    'm_i_MM.txt',...
    'm_o_MM.txt',...
    'm_u_MM.txt',...
};

fileNamesVTL = {...
    'f_a_1d.txt',...
    'f_e_1d.txt',...
    'f_i_1d.txt',...
    'f_o_1d.txt',...
    'f_u_1d.txt',...
    'm_a_1d.txt',...
    'm_e_1d.txt',...
    'm_i_1d.txt',...
    'm_o_1d.txt',...
    'm_u_1d.txt',...
    };

simuNames = {...
    '/a/ female',...
    '/e/ female',...
    '/i/ female',...
    '/o/ female',...
    '/u/ female',...
    '/a/ male',...
    '/e/ male',...
    '/i/ male',...
    '/o/ male',...
    '/u/ male',...
    };        

nbFiles = length(fileNamesVTL);

% frequency vectors
freqMax = 10000;
f = 1:10000;

% parameters for plot
width = 560;
height = 240;

% amplitude correction factor for MM
area = 0.8;
areaEnd = 2.84;
corrFac = (10^5*area);%((10^5)/0.8);

% clear the csv file for the analysis results
csvName = 'resonances.csv';
[fid, message] = fopen(csvName, 'w');
fprintf(message);
nbRes = 6;
sep = ';';

% loop over files
for fi = 1:nbFiles
    
    h = figure('position', ...
        [ width*floor((fi-1) / 4),40+height* mod((fi-1),4), ...
        width, height]);
    hold on
    
    % plot VocalTractLab
    tf = readTfTable([dir1d fileNamesVTL{fi}]);
    H = abs(interp1(tf(:,1), tf(:,2), f, 'spline'));
    plot(f/1000, 20*log10(H)+3.4,'k');
    
    idxVTL = extractResonances(20*log10(abs(H)));
    
    % plot MM simulation
    tf = readTfTable([dirMM fileNamesMM{fi}]);
    H = abs(interp1(tf(:,1), tf(:,2), f, 'spline'));
    plot(f/1000, 20*log10(H),'r');
    
    idxMM = extractResonances(20*log10(abs(H)));
    
    % if exist plot version with reduced losses
    fileNameRedLoss = [dirMM fileNamesMM{fi}(1:end-4) '_50.txt'];
    if exist(fileNameRedLoss)
        tf = readTfTable(fileNameRedLoss);
        H = abs(interp1(tf(:,1), tf(:,2), f, 'spline'));
        plot(f/1000, 20*log10(H), 'b')
        
        idxMML = extractResonances(20*log10(H));
    end
    
    title(simuNames{fi})
    xlabel 'f (kHz)'
    ylabel '|H| (dB)'
    xlim([0 10])
%     ylim([60 130])
    grid on
    
    legend('VTL', 'MM')
    legend('boxoff')
    
%     imgName = [strrep(simuNames{fi}, ' ', '_') '.pdf'];
%     imgName = strrep(imgName, '/', '');
%     print(h, '-dpdf',imgName);  
%     close (h);
    
    %% Extract and plot resonances

    h = figure('position', ...
        [ width*floor((fi-1) / 4),40+height* mod((fi-1),4), ...
        width, height]);
    hold on
    plot(f(idxVTL(:,2)), f(idxVTL(:,3)) - f(idxVTL(:,1)), 'k.')
    plot(f(idxMM(:,2)), f(idxMM(:,3)) - f(idxMM(:,1)), 'r.')
    
    if exist(fileNameRedLoss)
        plot(f(idxMML(:,2)), f(idxMML(:,3)) - f(idxMML(:,1)), 'b.')
    end
    
    title(simuNames{fi})
    xlabel 'f (kHz)'
    ylabel '|H| (dB)'
    
    %% extract resonances in a csv file

    fprintf(fid, '\n%s', simuNames{fi});
    fprintf(fid, '\nVTL res freq (Hz)');
    for ii = 1:nbRes, fprintf(fid, '%s%d', sep, idxVTL(ii,2)); end
    fprintf(fid, '\nVTL -3dB bw (Hz)');
    for ii = 1:nbRes, fprintf(fid, '%s%d', sep, idxVTL(ii,3) - idxVTL(ii,1)); end
    fprintf(fid, '\nMM res freq (Hz)');
    for ii = 1:nbRes, fprintf(fid, '%s%d', sep, idxMM(ii,2)); end
    fprintf(fid, '\nMM -3dB bw (Hz)');
    for ii = 1:nbRes, fprintf(fid, '%s%d', sep, idxMM(ii,3) - idxMM(ii,1)); end
    fprintf(fid, '\nMM 50\% losses res freq (Hz)');
    for ii = 1:nbRes, fprintf(fid, '%s%d', sep, idxMML(ii,2)); end
    fprintf(fid, '\nMM 50\% losses -3dB bw (Hz)');
    for ii = 1:nbRes, fprintf(fid, '%s%d', sep, idxMML(ii,3) - idxMML(ii,1)); end
    
end
fclose(fid);
end
%%
function [bwth] = extractResonances(H)

nH = length(H);

[pks, idx] = findpeaks(H);
nPks = length(pks);

bwth = nan(nPks,3);
% loop over peaks to extract the bandwidth
for p = 1:nPks
    
    % find left side -3 dB limit
    idxLow = max(idx(p)-1, 1);
    while and(idxLow >= 1, ...
            and(H(idxLow)>(pks(p)-3), H(idxLow)<H(idxLow+1)))
        idxLow = idxLow-1;
        if idxLow == 1
            break
        end
    end
    
    % find right side -3 dB limit
    idxHigh = min(idx(p) +1, nH);
    while and(idxHigh <= nH, ...
            and(H(idxHigh)>(pks(p)-3), H(idxHigh)<H(idxHigh-1)))
        idxHigh = idxHigh + 1;
        if idxHigh == nH
            break
        end
    end
    
    if and(...
        and(H(idxLow+1)>(pks(p)-3), H(idxLow)<H(idxLow+1)),...
        and(H(idxHigh-1)>(pks(p)-3), H(idxHigh)<H(idxHigh-1)))
        
        bwth(p,1) = idxLow;
        bwth(p,2) = idx(p);
        bwth(p,3) = idxHigh;
    end
    
end
bwth = bwth(not(isnan(bwth(:,1))),:);
end

function [tf] = readTfTable(fileName)
fid = fopen(fileName);

cnt = 1;
tf = zeros(100,3);

extractedLine = fgetl(fid);

while extractedLine ~= -1
    if isstrprop(extractedLine(1),'digit')
        data = str2num(extractedLine);
        if size(data,2) == 3
            tf(cnt,:) = str2num(extractedLine);
            cnt = cnt + 1;
        end
    end
    extractedLine = fgetl(fid);
end
fclose(fid);
end
