%% Generate a glottal flow signal
function glottalFlow = generateGlottalFlow(length, params)
MIN_TA = 0.01;  
N = length;
x = zeros(length,1);

AMP = params.AMP;
OQ = params.OQ;
SQ = params.SQ;
TL = params.TL;

T0 = 1.0;        
te = OQ;
tp = (te*SQ) / (1.0 + SQ);
ta = TL;
if (ta < MIN_TA) ta = MIN_TA; end
if (ta > T0 - te) ta = T0 - te; end

epsilon = getEpsilon(ta, te);
alpha   = getAlpha(tp, te, ta, epsilon);
B       = getB(AMP, tp, alpha);

w = 3.1415926 / tp;

u1_te = (B*(exp(alpha*te)*(alpha*sin(w*te) - w*cos(w*te)) + w)) / (w*w + alpha*alpha);
preFactor = (B*exp(alpha*te)*sin(w*te)*exp(epsilon*te)) / (epsilon*ta);
F2_te = preFactor*(-exp(-epsilon*te)/epsilon - te*exp(-epsilon*T0));

for i=1:N
    t = (i-1) / N;
    if (t <= te)
        x(i) = (B*(exp(alpha*t)*(alpha*sin(w*t) - w*cos(w*t)) + w)) / (w*w + alpha*alpha);
    else
        x(i) = u1_te + preFactor*(-exp(-epsilon*t)/epsilon - t*exp(-epsilon*T0)) - F2_te;
    end
end

glottalFlow = x;

end