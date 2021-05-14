function epsilon  = getEpsilon(ta, te)

MAX_STEPS = 40;
MIN_TA = 0.0001;
MIN_C  = 0.001;
c = 1.0 - te;
if (c < MIN_C)
    c = MIN_C;
end
if (ta < MIN_TA)
    ta = MIN_TA;
end
if (ta > c-0.00001)
    ta = c-0.00001;
end

% Newton-Iteration

epsilon = 1.0 / ta;      % 1st Approximation
numSteps = 0;

h  = 1.0 - exp(-epsilon*c) - epsilon*ta;
h2 = c*exp(-epsilon*c) - ta;
epsilon = epsilon - h/h2;
while ((numSteps < MAX_STEPS) && (abs(h) > 0.00001))
    h  = 1.0 - exp(-epsilon*c) - epsilon*ta;
    h2 = c*exp(-epsilon*c) - ta;
    epsilon = epsilon - h/h2;
end

end