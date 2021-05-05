%% Explore the blending method to combine low and high frequency components of different transfer functions

clc; close all; clearvars;
addpath('../include')

%% Load some transfer functions
[f_1d, f_Hz] = read_tf('../transfer-functions/1d/f_a_1d.txt');
[m_1d, f2_Hz] = read_tf('../transfer-functions/1d/m_a_1d.txt');
[f_mm, f3_Hz] = read_tf('../transfer-functions/multimodal/f_a_MM.txt');
[m_mm, f4_Hz] = read_tf('../transfer-functions/multimodal/m_a_MM.txt');

%% Blending
figure(1);
blend_tf(f_Hz, f_mm, f_1d, 9500, 10500)
title('female /a/');

figure(2);
blend_tf(f_Hz, m_mm, m_1d, 9500, 10500)
title('male /a/');
