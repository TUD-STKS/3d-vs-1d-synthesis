function y = cleanupBweSignal(y, sil)
%CLEANUPBWESIGNAL Cleans up a bandwidth-extended signal
%   After bandwidth extension, there are noise and artifacts in the silent
%   parts around the speech signal. This function gets rid of those by
%   fading the actual speech signal in and out.
%
%   y: Bandwith-extended speech signal consisting of [silence, speech,
%   silence]
%   sil: Duration of the symmetric (!) silence before and after the
%   speech

% Number of non-silent samples (with a little bit of slack)
nSpeech = length(y) - floor(1.8*sil);

% Fading part of the window
win = tukeywin(nSpeech, 0.05);

% Extend by zeros
win = padarray(win, floor((length(y) - length(win)) / 2), 'pre');
win = padarray(win, length(y) - length(win), 'post');

y = y .* win;
end

