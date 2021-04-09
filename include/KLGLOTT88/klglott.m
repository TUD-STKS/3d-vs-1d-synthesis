function [t, gf] = klglott(av, oq, T0, fs)
%KLGLOTT Generates a glottal flow pulse according to the KLGLOTT88 model
% [T, GF] = KLGLOTT(AV, OQ, T0, FS) calculates a glottal flow pulse with a
% maximum amplitde of AV, an open quotient of OQ, a fundamental period T0
% (in seconds) at a sampling rate of FS
a = 27*av / (4*oq^2*T0);
b = 27*av / (4*oq^3*T0^2);

k = 0:T0*fs-1;
gf = zeros(length(k), 1);
for n = 0:T0*fs-1
    if 0 <= n && n <= T0*oq*fs
        gf(n+1) = a*(n/fs)^2 - b*(n/fs)^3;
    elseif T0*oq*fs < n && n <= T0*fs
        gf(n+1) = 0;
    end
end

t = k/fs;
end

