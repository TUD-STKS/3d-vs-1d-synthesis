clc; close all; clearvars;
addpath('../include')

load('filters.mat');

%% Load some transfer functions
[f_1d, f_Hz] = read_tf('../transfer-functions/1d/f_a_1d.txt');
m_1d = read_tf('../transfer-functions/1d/m_a_1d.txt');
f_mm = read_tf('../transfer-functions/multimodal/f_a_MM.txt');
m_mm = read_tf('../transfer-functions/multimodal/m_a_MM.txt');

%% Window the transfer functions
w = get_window(f_Hz, 10e3, 11e3);
f_1d_win = f_1d .* w + 3.5e-09;
m_1d_win = m_1d .* w + 3.5e-09;
f_mm_win = f_mm .* w + 3.5e-09;
m_mm_win = m_mm .* w + 3.5e-09;

%% Filter the transfer functions
f_1d_lp = f_1d .* freqz(H_lp, length(f_1d), 'whole');
m_1d_lp = m_1d .* freqz(H_lp, length(m_1d), 'whole');
f_mm_lp = f_mm .* freqz(H_lp, length(f_mm), 'whole');
m_mm_lp = m_mm .* freqz(H_lp, length(m_mm), 'whole');

%% Transform to time domain
f_1d_win_ir = tf2ir(f_1d_win);
m_1d_win_ir = tf2ir(m_1d_win);
f_mm_win_ir = tf2ir(f_mm_win);
m_mm_win_ir = tf2ir(f_mm_win);

f_1d_lp_ir = tf2ir(f_1d_lp);
m_1d_lp_ir = tf2ir(m_1d_lp);
f_mm_lp_ir = tf2ir(f_mm_lp);
m_mm_lp_ir = tf2ir(m_mm_lp);

figure(1);sgtitle('IR of windowed TF');
subplot(2,2,1); plot(f_1d_win_ir); title('f, 1d');
subplot(2,2,2); plot(m_1d_win_ir); title('m, 1d');
subplot(2,2,3); plot(f_mm_win_ir); title('f, mm');
subplot(2,2,4); plot(m_mm_win_ir); title('m, mm');

figure(2); sgtitle('IR of filtered TF');
subplot(2,2,1); plot(f_1d_lp_ir); title('f, 1d');
subplot(2,2,2); plot(m_1d_lp_ir); title('m, 1d');
subplot(2,2,3); plot(f_mm_lp_ir); title('f, mm');
subplot(2,2,4); plot(m_mm_lp_ir); title('m, mm');

%% Compare transfer functions before and after filtering
figure(3); sgtitle('Original vs. filtered TF');
subplot(2,2,1); plot(f_Hz, abs(f_1d), '--'); hold on; plot(f_Hz, abs(f_1d_lp)); hold off;
subplot(2,2,2); plot(f_Hz, abs(m_1d), '--'); hold on; plot(f_Hz, abs(m_1d_lp)); hold off;
subplot(2,2,3); plot(f_Hz, abs(f_mm), '--'); hold on; plot(f_Hz, abs(f_mm_lp)); hold off;
subplot(2,2,4); plot(f_Hz, abs(m_mm), '--'); hold on; plot(f_Hz, abs(m_mm_lp)); hold off;
%% Get a cosine-tapered window with a constant passband of 1
function win = get_window(f_Hz, f_low, f_hi)
    lengthPass = sum(f_Hz < f_low);
    lengthTransition = sum((f_Hz > f_low) & (f_Hz < f_hi));
    win = hann(2*lengthTransition);
    win = [ones(lengthPass, 1); win(end-lengthTransition:end)];
    win = padarray(win, length(f_Hz) - length(win), 0, 'post');
end