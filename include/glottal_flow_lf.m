function Ug = glottal_flow_lf(f0, Fs, oversampling, lf_params)
    
% f0: Fundamental frequency in Hertz
% Fs: Target output sampling rate
% oversampling: Flow is sampled at oversampling * Fs to avoid aliasing
% T: Length of the output signal in seconds
    
T = 1 / f0;

% Calculate oversampled flow signal
t = linspace(0, T, T*Fs*oversampling);

%Ug = v_glotlf(0, t*f0, lf_params);     
Ug = generateGlottalFlow(length(t), lf_params, Fs*oversampling);

% Downsample using a Chebychev I filter order 8
Ug = decimate(Ug, oversampling, 8);

end