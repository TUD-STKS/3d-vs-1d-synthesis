function [varargout] = blend_tf(f_Hz, tf_low, tf_high, H_lp, H_hp)
%BLEND_TF Blends two transfer functions
% The blended transfer function uses the low frequency components of one
% transfer function and the high frequency components of another transfer
% function.
%
% tf_low: Transfer function to use for lower frequencies
% tf_high: Transfer function to use for higher frequencies
%
% Returns the blended transfer function if output argument is given.
% Otherwise plots the consituent and blended transfer functions and the
% filter functions.


blended_tf = tf_low .* freqz(H_lp, length(tf_low), 'whole') + tf_high ...
    .* freqz(H_hp, length(tf_high), 'whole');

if nargout > 0
    varargout{1} = blended_tf;
else
    hold on;
    plot(f_Hz(1:length(blended_tf)/2), abs(blended_tf(1:length(blended_tf)/2)), 'b-');
    tf_low = padarray(abs(tf_low), length(tf_low) - length(f_Hz), 0, 'post');
    tf_high = padarray(abs(tf_high), length(tf_low) - length(f_Hz), 0, 'post');
    plot(f_Hz(1:length(blended_tf)/2), tf_low(1:length(blended_tf)/2), '--');
    plot(f_Hz(1:length(blended_tf)/2), tf_high(1:length(blended_tf)/2), '--');    
    yyaxis right;
    H_lp = abs(freqz(H_lp, length(blended_tf), 'whole'));
    H_hp = abs(freqz(H_hp, length(blended_tf), 'whole'));
    plot(f_Hz(1:length(blended_tf)/2), H_lp(1:length(blended_tf)/2), ':');
    plot(f_Hz(1:length(blended_tf)/2), H_hp(1:length(blended_tf)/2)), ':';
    plot(f_Hz(1:length(blended_tf)/2), H_hp(1:length(blended_tf)/2) + H_lp(1:length(blended_tf)/2), ':');
    hold off;
    xlabel('Frequency $f$ [Hz]')
    yyaxis left;
    ylabel('Magnitude')
    yyaxis right;
    ylim([0, 2]);
    ylabel('Filter responses and their sum')
    
end

end

