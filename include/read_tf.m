function [f_Hz, tf] = read_tf(file, mm)
%READ_TF Reads a VTK transfer function file
%   f_Hz: Frequency value in Hertz
%   tf: Complex-valued transfer function, sampled at the frequencies in
%   f_Hz

if mm == true
    tf_table = readtable(fullfile(file.folder, file.name), 'FileType', 'text', 'HeaderLines', 1);
    tf_table.Properties.VariableNames = {'f_Hz', 'mag', 'phi'};   
else
    tf_table = readtable(fullfile(file.folder, file.name));
    tf_table.Properties.VariableNames = {'f_Hz', 'mag', 'phi'};   
end
f_Hz = tf_table.f_Hz;
tf = tf_table.mag .* exp(1i*tf_table.phi);
end

