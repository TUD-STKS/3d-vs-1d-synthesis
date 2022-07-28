clear all
close all

phonemes = {'a', 'e', 'i', 'o', 'u'};
model = {'MM', 'BWE', '1d'};
gender = {'f', 'm'};
vQuality = {'modal', 'pressed'};

dirStimuli = 'stimuli';

Nfft = 2^9;
win = 'han';

colorCurves = [220 50 32;...
              0 90 181;...
              0 0 0]/255;
          
[s, sr] = audioread('calibration_extracted.wav');
longspecCal = ltas(s,sr,Nfft,win,1,0,1, zeros(Nfft/2+1, 1), 0);
idx1000 = round(1000/(sr/Nfft))+1;
cal = 10^((94 - longspecCal.dBspectrum(idx1000)-50)/20);
          
[s, sr] = audioread('bg_noise_extracted.wav'); 
longspecNoise=ltas(cal * s,sr,Nfft,win,1,0,1, zeros(Nfft/2+1, 1), 0);

for p = 1:5
    figure
    cnt = 1;
    for g = 1:2
        for vq = 1:2
            subplot(2,2,cnt)
            hold on
            for m = 1:3
                
                
                name = [dirStimuli '/' gender{g} '_' phonemes{p} '_' ...
                    model{m} '_' vQuality{vq} '.wav'];
                [s, sr] = audioread(name);
                
                longspec=ltas(cal * s,sr,Nfft,win,1,0,1);
                
                plot(longspec.f/1000, longspec.dBspectrum, 'color', colorCurves(m,:))
            end
            title([phonemes{p} ' ' gender{g} ' ' vQuality{vq}])
            plot(longspecNoise.f/1000, longspecNoise.dBspectrum, 'color', [0.5 0.5 0.5], 'linewidth', 2)
            legend(model);
            xlim([0 12000]/1000)
            xlabel('f (kHz)')
            ylabel('LTAS (dB)')
            cnt = cnt + 1;
        end
    end
end
