%% Testing the MATLAB wrapper for the VTL API
%% Get transfer function
vtlinit('../../speaker-files/male.speaker');

opts = vtltfopts();
opts.type = 'SPECTRUM_PU';
opts.radiation = 'PISTONINWALL_RADIATION';
opts.paranasalSinuses = false;
opts.piriformFossa = false;
opts.staticPressureDrops = false;
opts.lumpedElements = false;
opts.innerLengthCorrections = false;
opts.boundaryLayer = true;
opts.heatConduction = true;
opts.softWalls = true;
opts.hagenResistance = false;

pu = vttf(vtshape('a_no-pf_mm-formants'), 4096, opts);
vtlclose();

%% Low-pass filter transfer function in the frequency domain 
% to get rid of ringing from boxcar window
h_LP =  freqz(LP_10000, 4096, 'whole');
pu_filtered = conj(pu) .* h_LP;
subplot(2,1,1)
f = linspace(0, 44100, 4096);
plot(f, abs(pu), '--'); hold on;
plot(f, abs(pu_filtered)); hold off;
xlabel('Frequency [Hz]')
subplot(2,1,2)
ir = tf2ir(pu_filtered);
plot(ir);
xlabel('Sample $k$')



