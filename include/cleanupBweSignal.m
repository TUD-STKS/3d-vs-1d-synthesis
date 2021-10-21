function y = cleanupBweSignal(y, sil)
%CLEANUPBWESIGNAL Cleans up a bandwidth-extended signal
%   After bandwidth extension, there are noise and artifacts in the silent
%   parts around the speech signal. This function gets rid of those by
%   fading the actual speech signal in and out.
%
%   y: Bandwidth-extended speech signal consisting of [silence, speech,
%   silence]
%   sil: Duration of the symmetric (!) silence before and after the
%   speech

% Number of non-silent samples
nSpeech = length(y) - floor(2.2*sil);

% Fading part of the window
win = tukeywin(nSpeech, 0.1);

% Extend by zeros
win = padarray(win, floor((length(y) - length(win)) / 2), 'pre');
win = padarray(win, length(y) - length(win), 'post');

% Move window back a little bit to get rid of noise tail
win = circshift(win, floor(-0.1*sil));

y = y .* win;
end

