function [tf, f_Hz] = read_tf(file, mm)
%READ_TF Reads a VTK transfer function file
%   tf: Complex-valued transfer function, sampled at the frequencies in
%   f_Hz: Frequency value in Hertz

if isstring(file) || ischar(file)
    filename = file;
else
    filename = fullfile(file.folder, file.name);
end
if mm == true
    tf_table = readtable(filename, 'FileType', 'text', 'HeaderLines', 1);
    tf_table.Properties.VariableNames = {'f_Hz', 'mag', 'phi'};   
else
    tf_table = readtable(filename);
    tf_table.Properties.VariableNames = {'f_Hz', 'mag', 'phi'};   
end
tf = tf_table.mag .* exp(1i*tf_table.phi);
f_Hz = tf_table.f_Hz;

% Since the DC component in MM transfer function is garbage, add it
% manually
if mm == true
    f_Hz = [0; f_Hz];
    tf = [0; tf];
end

end

