function alpha = getAlpha(tp, te, ta, epsilon)
w = pi / tp;
w2 = w*w;
SIN = sin(w*te);
COS = cos(w*te);
X = (SIN*exp(epsilon*te)*(-exp(-epsilon)/epsilon - exp(-epsilon))) / (epsilon*ta);
Y = (SIN*exp(epsilon*te)*(-exp(-epsilon*te)/epsilon - te*exp(-epsilon))) / (epsilon*ta);


a(1) = 0.0;
a(2) = 0.0;

numSteps = 0;
numSteps= numSteps + 1;
a(2)= a(2)+ 1.0;
h(2) = w/(w2+a(2)*a(2)) + exp(a(2)*te)*((a(2)*SIN - w*COS)/(w2+a(2)*a(2)) + X - Y);
while ((numSteps < 20) && (h(2) >= 0.0))
    
    numSteps = numSteps + 1;
    a(2)= a(2)+ 1.0;
    h(2) = w/(w2+a(2)*a(2)) + exp(a(2)*te)*((a(2)*SIN - w*COS)/(w2+a(2)*a(2)) + X - Y);
end

% h(a[0]) should now be > 0 and h(a[1]) should now be < 0.

if (h(2) >= 0)
    alpha = 0.0;
    return;
end

% Use the approximation algorithm "Regula falsi"

numSteps = 0;
h(1) = w/(w2+a(1)*a(1)) + exp(a(1)*te)*((a(1)*SIN - w*COS)/(w2+a(1)*a(1)) + X - Y);
h(2) = w/(w2+a(2)*a(2)) + exp(a(2)*te)*((a(2)*SIN - w*COS)/(w2+a(2)*a(2)) + X - Y);
newAlpha = a(1) -  (h(1)*(a(2)-a(1))) / (h(2)-h(1));
newH = w/(w2+newAlpha*newAlpha) + exp(newAlpha*te)*((newAlpha*SIN - w*COS)/(w2+newAlpha*newAlpha) + X - Y);

if (newH < 0.0)
    a(2) = newAlpha;
else
    a(1) = newAlpha;
end
numSteps =numSteps + 1;
while ((numSteps < 20) && (abs(newH) > 0.00001));
    h(1) = w/(w2+a(1)*a(1)) + exp(a(1)*te)*((a(1)*SIN - w*COS)/(w2+a(1)*a(1)) + X - Y);
    h(2) = w/(w2+a(2)*a(2)) + exp(a(2)*te)*((a(2)*SIN - w*COS)/(w2+a(2)*a(2)) + X - Y);
    newAlpha = a(1) -  (h(1)*(a(2)-a(1))) / (h(2)-h(1));
    newH = w/(w2+newAlpha*newAlpha) + exp(newAlpha*te)*((newAlpha*SIN - w*COS)/(w2+newAlpha*newAlpha) + X - Y);
    
    if (newH < 0.0)
        a(2) = newAlpha;
    else
        a(1) = newAlpha;
    end
    numSteps =numSteps + 1;
end

alpha = newAlpha;
end