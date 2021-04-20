function it = tf2ir(tf)
%TF2IR Calculates the impulse response of a system given its transfer function
%   tf: Complex transfer function. If it is not conjugate symmetric,
%   symmetry will be enforced.
%   ir: Impulse response corresponding to the transfer function tr.

% Enforce conjugate symmetry of transfer function
if any(tf(2:end) ~= conj(tf(end:-1:2)))
    tf = [tf; conj(tf(end:-1:2))];
end

it = ifft(tf, 'symmetric');

end

