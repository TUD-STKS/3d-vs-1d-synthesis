function lf_params = get_LF_params(voice_quality)
% Generate the parameters of the LF model corresponding to a given
% voice quality
    
switch voice_quality
    case 'modal'
        lf_params.AMP = 300;
        lf_params.OQ = 0.5;
        lf_params.SQ = 3.0;
        lf_params.TL = 0.02;
        lf_params.SNR = 30.0;
    case 'breathy'
        lf_params.AMP = 300;
        lf_params.OQ = 0.7;
        lf_params.SQ = 3.0;
        lf_params.TL = 0.1;
        lf_params.SNR = 20.0;
    case 'pressed'
        lf_params.AMP = 300;
        lf_params.OQ = 0.5;
        lf_params.SQ = 3.0;
        lf_params.TL = 0.02;
        lf_params.SNR = 60.0;
end
end