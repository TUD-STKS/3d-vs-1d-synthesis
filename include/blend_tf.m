function [varargout] = blend_tf(tf_low, tf_high, f_inf, fs)
%BLEND_TF Blends two transfer functions
% The blended transfer function uses the low frequency components of one
% transfer function and the high frequency components of another transfer
% function.
%
% tf_low: Transfer function to use for lower frequencies
% tf_high: Transfer function to use for higher frequencies
% f_inf: Inflection frequency where the switch from low to high happens (in Hz).
% fs: Sampling rate in Hz.
%
% Returns the blended transfer function if output argument is given.
% Otherwise plots the consituent and blended transfer functions and the
% filter functions.

% Design a crossover filter with maximum slope to do the blending
blendFilter = crossoverFilter(1, f_inf, 48, fs);

% Filter operates in the time domain
ir_low = tf2ir(tf_low);
ir_high = tf2ir(tf_high);

[ir_low, ~] = blendFilter(ir_low);
[~, ir_high] = blendFilter(ir_high);

blended_tf = fft(ir_low, length(tf_low)) + fft(ir_high, length(tf_low));

f_Hz = linspace(0, fs, length(tf_low));

if nargout > 0
    varargout{1} = blended_tf;
else
    hold on;
    plot(f_Hz(1:length(blended_tf)/2), abs(blended_tf(1:length(blended_tf)/2)), 'b-');
    tf_low = padarray(abs(tf_low), length(tf_low) - length(f_Hz), 0, 'post');
    tf_high = padarray(abs(tf_high), length(tf_low) - length(f_Hz), 0, 'post');
    plot(f_Hz(1:length(blended_tf)/2), tf_low(1:length(blended_tf)/2), '--');
    plot(f_Hz(1:length(blended_tf)/2), tf_high(1:length(blended_tf)/2), ':');    
    yyaxis right;
    % Get the SOS filter coefficients for the crossover filters
    [b_lp, a_lp, b_hp, a_hp] = getFilterCoefficients(blendFilter, 1);
    H_lp = abs(freqz([b_lp, a_lp], length(blended_tf), 'whole'));
    H_hp = abs(freqz([b_hp, a_hp], length(blended_tf), 'whole'));
    plot(f_Hz(1:length(blended_tf)/2), H_lp(1:length(blended_tf)/2), ':');
    plot(f_Hz(1:length(blended_tf)/2), H_hp(1:length(blended_tf)/2)), ':';
    plot(f_Hz(1:length(blended_tf)/2), H_hp(1:length(blended_tf)/2) + H_lp(1:length(blended_tf)/2), ':');
    hold off;
    xlabel('Frequency $f$ [Hz]')
    yyaxis left;
    ylabel('Magnitude')
    yyaxis right;
    ylim([0, 1.1]);
    ylabel('Filter responses and their sum')
    
end

end

