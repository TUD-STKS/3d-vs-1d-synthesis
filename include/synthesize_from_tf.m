function y = synthesize_from_tf(x, tf)
%SYNTHESIZE_FROM_TF Synthesizes a sound from a vocal tract transfer
%function using convolution in the time domain.
%
% x: The excitation signal. Output will have the same length as
% this.
% tf: The complex-valued transfer function to use,
%
% y: Synthesized speech signal (same length as excitation).
%

% Calculate impulse response from transfer function
h = tf2ir(tf);
y = conv(x, h, 'same');

end

