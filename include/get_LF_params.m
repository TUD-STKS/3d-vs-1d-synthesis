function lf_params = get_LF_params(voice_quality)
% Generate the parameters of the LF model corresponding to a given
% voice quality
    
% define the timing parameter corresponding to the voice quality type
% chosen according to Fu 2006 Table IV
% Robust Glottal Source Estimation Based on JointSource-Filter Model Optimization
switch voice_quality
    case 'modal'
        lf_params.AMP = 300;
        lf_params.OQ = 0.5;
        lf_params.SQ = 3.0;
        lf_params.TL = 0.02;
    case 'breathy'
        lf_params.AMP = 300;
        lf_params.OQ = 0.5;
        lf_params.SQ = 3.0;
        lf_params.TL = 0.02;
    case 'pressed'
        lf_params.AMP = 300;
        lf_params.OQ = 0.5;
        lf_params.SQ = 3.0;
        lf_params.TL = 0.02;
end
end