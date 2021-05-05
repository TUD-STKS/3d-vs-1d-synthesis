function [varargout] = blend_tf(f_Hz, tf_low, tf_high, f_start, f_stop)
%BLEND_TF Blends two transfer functions
% The blended transfer function uses the low frequency components of one
% transfer function and the high frequency components of another transfer
% function. Between the frequencies fp_start and fp_stop, the transfer
% function is calculated by a cosine-weighted summation of the two transfer
% functions.
%
% f_Hz: Frequency vector containing the sampled frequencies of the transfer
% functions (must be the same for both)
% tf_low: Transfer function to use up to fp_start
% tf_high: Transfer function to use after fp_stop
% f_start: Start blending the transfer functions from this frequency on
% f_stop: Stop blending the transfer functions here
%
% Returns the blended transfer function if output argument is given.
% Otherwise plots the consituent and blended transfer functions and the
% weighting functions.


[w_low, w_high] = get_blending_weights(f_Hz, f_start, f_stop);

blended_tf = tf_low .* w_low + tf_high .* w_high;

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
    plot(f_Hz(1:length(blended_tf)/2), w_low(1:length(blended_tf)/2), ':');
    plot(f_Hz(1:length(blended_tf)/2), w_high(1:length(blended_tf)/2)), ':';
    hold off;
    xlabel('Frequency $f$ [Hz]')
    yyaxis left;
    ylabel('Magnitude')
    yyaxis right;
    ylim([0, 2]);
    ylabel('Weight')
    
end

end

