function lf_params = get_LF_params(voice_quality)
% Generate the parameters of the LF model corresponding to a given
% voice quality
    
% define the timing parameter corresponding to the voice quality type
% chosen according to Fu 2006 Table IV
% Robust Glottal Source Estimation Based on JointSource-Filter Model Optimization
switch voice_quality
    case 'modal'
        tp = 0.4566;
        te = 0.575;
        ta = 0.0091;
        tc = 0.6763;
    case 'breathy'
        tp = 0.5289;
        te = 0.7575;
        ta = 0.0819;
        tc = 0.9508;
    case 'pressed'
        tp = 0.2439;
        te = 0.3204;
        ta = 0.0109;
        tc = 0.5072;
end

% compute epsilon of Eq (3) in Fu et al 2006
% Robust Glottal Source Estimation Based on JointSource-Filter Model Optimization
ep = ((ta*lambertw(0, -(exp(-(tc - te)/ta)*(tc - te))/ta))/(tc - te) + 1)/ta;

% compute alpha using an equation provided in section A1.4 in Doval et al 2006
% The spectrum of glottal flow models
syms x;
al = vpasolve((1/(x^2 + (pi/tp)^2))*(exp(-x*te)*(pi/tp)/sin(pi*te/tp) ...
+ x - pi*cot(pi*te/tp)/tp) - (tc - te)/(exp(ep*(tc-te)) -1) + 1/ep);

wg = pi/tp;
E0_Ee = -1/(exp(double(al)*te)*sin(wg*te));
lf_params = [te, E0_Ee, 1-tp/te];
end