function lf_params = get_LF_params(voice_quality, gender)
% Generate the parameters of the LF model corresponding to a given
% voice quality

% initialise with default parameters
lf_params.AMP = 300;
lf_params.OQ = 0.78;
lf_params.SQ = 1.99;
lf_params.TL = 0.02;
    
% OQ and SQ are from Alku & Vilkman 1996
% A comparison of glottal voice source quantification parameters in 
% breathy, normal and pressed phonation of female and male speakers
%
% TL have been arbitrarily changed to generate a strong spectral 
% slope for breathy and a weak one for pressed
if strcmp(gender,'female')
    switch voice_quality
    case 'modal'
        lf_params.AMP = 300;
        lf_params.OQ = 0.84;
        lf_params.SQ = 1.9;
        lf_params.TL = 0.04;
        lf_params.SNR = 60.0;
    case 'breathy'
        lf_params.AMP = 300;
        lf_params.OQ = 0.94;
        lf_params.SQ = 1.38;
        lf_params.TL = 0.08;
        lf_params.SNR = 20.0;
    case 'pressed'
        lf_params.AMP = 300;
        lf_params.OQ = 0.78;
        lf_params.SQ = 1.99;
        lf_params.TL = 0.01;
        lf_params.SNR = 40.0;
    end
elseif strcmp(gender, 'male')
    
    switch voice_quality
    case 'modal'
        lf_params.AMP = 300;
        lf_params.OQ = 0.84;
        lf_params.SQ = 2.15;
        lf_params.TL = 0.04;
        lf_params.SNR = 60.0;
    case 'breathy'
        lf_params.AMP = 300;
        lf_params.OQ = 0.96;
        lf_params.SQ = 1.15;
        lf_params.TL = 0.08;
        lf_params.SNR = 20.0;
    case 'pressed'
        lf_params.AMP = 300;
        lf_params.OQ = 0.70;
        lf_params.SQ = 2.18;
        lf_params.TL = 0.01;
        lf_params.SNR = 40.0;
    end
end