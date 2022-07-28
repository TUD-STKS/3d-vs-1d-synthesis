function longspec=ltas(x,Fs,Nfft,win,allspectra,sigout,overlap,specfix,noiselev)
% Long-term average spectrum
% longspec = ltas(x,Fs,Nfft,win,noiselev)
% This function calculates the long-term average spectrum by taking the
% Nfft-point FFT of individual frames of length Nfft. Frames are
% overlapped by 50% to compensate for windowing.
%
% Inputs: x is a VECTOR containing the signal to be analyzed, Fs is
% the sampling frequency, Nfft is the number of points for the fft AND
% the length of the frame window (a length of factor 2^n is recommended,
% such as 2048), win is the type of window to use ('ham' = hamming, 'han'
% = hanning, 'rect' = rectangle), allspectra is a boolean value denoting
% whether all spectra for all frames should (1) or should not (0) be
% calculated, sigout is a boolean value denoting whether the analyzed
% signal should (1) or should not (0) be calculated, overlap is a boolean
% value denoting whether the frames should (1) or should not (0) have
%50
% overlap, and noiselev is the minimum SPL value
% in dB that will be the threshold for including the current sample in
% the LTAS (if you wish to analyze the whole signal just put a large
% negative value for noiselev, such as -100). If noiselev is not
% specified, the default value is 43 dB. Note: if overlap is 1 and sigout
% is 1, sigout will be a concatenation of overlapped frames, and thus
% will sound like the audio signal has been stretched in time.
%
% Output: The function returns a struct containing several useful results
% associated with the LTAS.
%
% longspec.(variablename)
%
% sig: original signal [(length(x)) x 1 double]
% sigout: signal of only frames included in analysis
% tpoints: starting points of each frame analyzed (if overlap==0)
% totdBfft: total dB SPL using fft method (adding freq bins of LTAS)
% totdBrms: total dB SPL using rms method (analyzing whole signal x)
% f: frequency vector [(Nfft/2+1) x 1 double]
% linspectrum: linear spectrum [(Nfft/2+1) x 1 double]
% dBspectrum: dB spectrum [(Nfft/2+1) x 1 double]
% spectra: matrix of linear spectrum of each frame analyzed
% [(Nfft/2+1) x frames double]
% dBspectra: matrix of dB spectrum of each frame analyzed
% [(Nfft/2+1) x frames double]
% HFElev: dB values of HFE analysis (total value of summed
% lower octave bands, 62.5 Hz to 4 kHz octaves, and
% summed HFE octaves, 8kHz and 16kHz octaves) [2x1 double]
% octlev: dB values of octave bands (all octave bands from the
% 62.5 Hz to the 16 kHz band [9x1 double]
% oct3lev: dB values of third-octave bands (all third-octave
% bands from the 50 Hz to the 20.2 kHz band [27x1 double]
% norm0spectrum: dBspectrum normalized to 0 dB [1025x1 double]
% norm0HFElev: octHFElev normalized to 0 dB [2x1 double]
% norm0octlev: octlev normalized to 0 dB [9x1 double]
% norm0oct3lev: oct3lev normalized to 0 dB [27x1 double]
% overlap: overlap input by user (0=no overlap, 1=50% overlap)
% noiselev: noiselev input by user
% win: window type used as input by user
% frames: total number of frames analyzed
%
% Example:
% sigltas = ltas(sig,44100,2048,'ham',-100);

rowcol = size(x);
if rowcol(1) > 1
    longspec.sig = x;
    x = x';
else
    longspec.sig = x';
end
% siz = wavread(fname,'size');
siz = length(x);
N = Nfft;
p = 20e-6;
if strcmp(win,'ham')
    w = hamming(N);
else if strcmp(win,'han')
        % w = hanning(N);
        w = hann(N);
    else if strcmp(win,'rect')
        w = 1;
        end
    end
end
if nargin < 9
    noiselev = 43; % dB, the minimum level to include in the ltas analysis
end
noise = 10^(noiselev/20)*p;
totpxx = zeros(Nfft/2 +1,1);
frames=0;
tpoints = 0;
spectra = zeros(Nfft/2 +1,1);
% sigout=sigout;
% overlap = overlap; % need to add this in (2/28/11) to include (1) or not include (0)
% 50% overlap of the window
if overlap
    stepsize = Nfft/2;
else
    stepsize = Nfft;
end
for i=1:stepsize:siz-2*Nfft % will always leave out last two frames (0.1 s)
% for i=1:Nfft/2:siz-2*Nfft
a = x(i:i+Nfft-1)';
if i == 1 || i == 1+Nfft/2 % 1st or 2nd (with 50% overlap) steps have nothing before for comparison
    b = 0;
else
    b = x(i-Nfft:i-1);
end
c = x(i+Nfft:i+2*Nfft-1);
% [a,Fs,nb] = wavread(fname,[i i+Nfft+1]);
% a = diff(a(:,1));
check = 0;
if max(abs(a)) > noise
    check = check + 1;
end
if max(abs(b)) > noise
    check = check + 1;
end
if max(abs(c)) > noise
    check = check +1;
end
% if 20*log10((sqrt(sum(a.*a)/length(a)))/p) > noiselev
% check = check + 1;
% end
% if 20*log10((sqrt(sum(b.*b)/length(b)))/p) > noiselev
% check = check + 1;
% end
% if 20*log10((sqrt(sum(c.*c)/length(c)))/p) > noiselev
% check = check +1;
% end
if check >= 2
    % To keep the scaling accurate for a meaningful power spectrum
    foo = fft(a(1:N).*w,N);
    Pxx = foo(1:N/2+1);
    % Pxx = abs(Pxx); % Take the magnitude of fft of x
    Pxx = Pxx/N; % Scale the fft so that it is not a function of the length of x
    Pxx(2:end-1) = Pxx(2:end-1)*2; % Since we dropped half the FFT we multiply Pxx by 2 to keep the same energy.
    Pxx = abs(Pxx); % Take the magnitude of fft of x
    Pxx = Pxx.*Pxx; % Now, take the square of the magnitude of fft of x which has been scaled properly.
    % The DC component and Nyquist component, if it exists, are unique and should not be multiplied by 2.
    % [Pxx,f] = psd(a,1024,Fs,hanning(1024));
    totpxx = (totpxx + Pxx);
    frames = frames+1;
    tpoints = [tpoints;i];
    if sigout(1)
        sigout = [sigout;a];
    end
        if allspectra
            spectra(:,frames) = Pxx;
        end
    end
end
if sigout(1)
    sigout = sigout(2:end);
end
tpoints = tpoints(2:end);
longspec.sigout = sigout;
longspec.tpoints = tpoints;
if nargin == 9
    totpxx = totpxx/frames .* 10.^(specfix/10);
else
    totpxx = totpxx/frames;
end
longspec.totdBfft = 10*log10(sum(totpxx)/(p^2));
longspec.totdBrms = 20*log10((sqrt(sum(x.*x)/length(x)))/p);
% longspec.totdBrms = 20*log10((sqrt(sum(sigout.*sigout)/length(sigout)))/p);
f = 0:Fs/N:(N-1)*(Fs/N);
longspec.f = f(1:N/2+1)';
longspec.linspectrum = totpxx;
longspec.dBspectrum = 10*log10(totpxx/(p^2));
% meterdiff = -20*log10(1/0.6);
% longspec.dBspectrum = 10*log10(totpxx/(p^2)) + meterdiff;
if allspectra,
    longspec.spectra = spectra;
    longspec.dBspectra = 10*log10(spectra/(p^2));
end
longspec.HFElev = bandlevels(longspec.dBspectrum,longspec.f,'iecoctHFE')';
longspec.octlev = bandlevels(longspec.dBspectrum,longspec.f,'iecoct')';
longspec.oct3lev = bandlevels(longspec.dBspectrum,longspec.f,'iec3oct')';
longspec.norm0spectrum = longspec.dBspectrum-longspec.totdBfft;
longspec.norm0HFElev = longspec.HFElev - longspec.totdBfft;
longspec.norm0octlev = longspec.octlev - longspec.totdBfft;
longspec.norm0oct3lev = longspec.oct3lev - longspec.totdBfft;
longspec.overlap = overlap;
longspec.noiselev = noiselev;
longspec.win = win;
longspec.Nfft = Nfft;
longspec.frames = frames;
% frames
% fres = Fs/N
% tres = N/Fs
% figure
% plot(f/1000,longspec.dB)
% xlabel('kHz')
