function ir = tf2ir(tf)
%TF2IR Calculates the impulse response of a system given its transfer function
%   tf: Complex transfer function. If it is not conjugate symmetric,
%   symmetry will be enforced.
%   ir: Impulse response corresponding to the transfer function tf.

ir = ifft(tf, 'symmetric');

end
