%% Explore the blending method to combine low and high frequency components of different transfer functions
clc; close all; clearvars;
addpath('../include')
load('filters.mat')

%%
f_inf = 4000;  % Inflection frequency where the dominating transfer function changes
Fs_Hz = 44100;

%% Load some transfer functions
vowel = 'a';
[f_1d, f_Hz] = read_tf(['../transfer-functions/1d/f_' vowel '_1d.txt']);
[m_1d, f2_Hz] = read_tf(['../transfer-functions/1d/m_' vowel '_1d.txt']);
[f_mm, f3_Hz] = read_tf(['../transfer-functions/multimodal/f_' vowel '_MM.txt']);
[m_mm, f4_Hz] = read_tf(['../transfer-functions/multimodal/m_' vowel '_MM.txt']);

%% Low-pass filter both transfer functions at 12 kHz to avoid aliasing
f_1d = f_1d .* freqz(H_AA, length(f_1d), 'whole');
m_1d = m_1d .* freqz(H_AA, length(m_1d), 'whole');
f_mm = f_mm .* freqz(H_AA, length(f_mm), 'whole');
m_mm = m_mm .* freqz(H_AA, length(m_mm), 'whole');


%% Blending
figure(1);
blend_tf(f_mm, f_1d, f_inf, Fs_Hz, 'dB')
title(['female /' vowel '/']);
xlim([0, 12000])
legend

figure(2);
blend_tf(m_mm, m_1d, f_inf, Fs_Hz)
title(['male /' vowel '/']);
legend('Final TF', 'MM TF', 'TLM TF', 'Blending lowpass', 'Blending highpass', 'Sum of blending filters')
xlim([0, 12000])