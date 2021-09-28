%% Calculates and saves the transfer functions corresponding to the listed shapes from the given speaker file
% Transfer functions are saved in the usual VTL file format
clear all; close all;
addpath('../include/VocalTractLabApi');

%% List of shapes (as they appear in the speaker file)
shapes = [
    "a_no-pf",
    "e_adjusted_tongue2",
    "i_no-pf",
    "o_no-pf",
    "u_no-pf"
    ];

outdir = "1d";
% sex = "m"; 
sex = "f";
%%
N = 4096;  % Number of spectral samples (of the whole symmetric spectrum)
if sex == "m"
    vtl = VTL('../speaker-files/male.speaker');
elseif sex == "f"
    vtl = VTL('../speaker-files/female.speaker');
end
    
opts = vtl.default_transfer_function_options();
opts.spectrumType = 'SPECTRUM_PU';
opts.radiationType = 'PISTONINWALL_RADIATION';
opts.paranasalSinuses = false;
opts.piriformFossa = false;
opts.staticPressureDrops = false;
opts.lumpedElements = false;
opts.innerLengthCorrections = false;
opts.boundaryLayer = true;
opts.heatConduction = true;
opts.softWalls = true;
opts.hagenResistance = false;

for shape = shapes'
    try
        [tf, f] = vtl.get_transfer_function(vtl.get_tract_params_from_shape(shape), N, opts);
        parts = split(shape, '_');
        fileName = fullfile(outdir, filesep, join([sex, parts{1}, outdir], '_') + ".txt"); 
        vtl.save_transfer_function(fileName, tf, f);
    catch E
        disp(E.message)
    end
end