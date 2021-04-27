function [tf, f_Hz] = read_tf(file)
%READ_TF Reads a VTK transfer function file
%   tf: Complex-valued transfer function, sampled at the frequencies in
%   f_Hz: Frequency value in Hertz

if isstring(file) || ischar(file)
    filename = file;
else
    filename = fullfile(file.folder, file.name);
end

tf_table = readtable(filename);
tf_table.Properties.VariableNames = {'f_Hz', 'mag', 'phi'};   
tf = tf_table.mag .* exp(1i*tf_table.phi);
f_Hz = tf_table.f_Hz;

end

