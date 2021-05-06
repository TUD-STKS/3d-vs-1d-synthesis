function plotSpectrogram(x, Fs)
x = filtfilt([1, -0.95], 1, x');
frameLength = floor(0.005 * Fs);
window = gausswin(frameLength);
noverlap = floor(0.75 * frameLength);
spectrogram(x, window, noverlap, [], Fs, 'yaxis', 'MinThreshold', -150 );
colormap(hot)
end

