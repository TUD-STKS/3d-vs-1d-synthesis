function [w_low, w_high] = get_blending_weights(f_Hz, f_start, f_stop)
    % Get the weights for transfer function blending
    
    % Get the weights for the low-frequency part
    lengthPass = sum(f_Hz < f_start);
    lengthTransition = sum((f_Hz > f_start) & (f_Hz < f_stop));
    w_low = hann(2*lengthTransition + 1);
    w_low = [ones(lengthPass, 1); w_low(end-lengthTransition+1:end)];
    % Get the weights for the high-frequency part
    w_high = flip(w_low);
    
    % Pad weights to full length
    w_low = padarray(w_low, length(f_Hz) - length(w_low), 0, 'post');
    w_high = padarray(w_high, lengthPass-1, 0, 'pre');
    w_high = padarray(w_high, length(f_Hz) - length(w_high), 1, 'post');    
end
