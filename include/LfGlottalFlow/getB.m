function B = getB(AMP,  tp, alpha)
  w = 3.1415926 / tp;
  help = (exp(alpha*tp)*(alpha*sin(w*tp) - w*cos(w*tp)) + w) / (w*w + alpha*alpha);
  B = AMP / help;
end