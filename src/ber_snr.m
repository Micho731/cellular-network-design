%% BER vs SNR Analysis (QPSK)
% Script for Deliverable 2 - File 5
clear; clc; close all;

% --- Parameters ---
SNR_dB = 0:2:30;
SNR_lin = 10.^(SNR_dB/10);

% --- Theoretical BER for QPSK ---
% AWGN Channel
ber_awgn = 0.5 * erfc(sqrt(SNR_lin)); 

% Rayleigh Fading Channel (Theoretical approximation for QPSK)
% Pe = 0.5 * (1 - sqrt(EbNo / (1 + EbNo))) for BPSK/QPSK
ber_rayleigh = 0.5 * (1 - sqrt(SNR_lin ./ (1 + SNR_lin)));

% --- Plotting ---
figure(8);
semilogy(SNR_dB, ber_awgn, 'b-o', 'LineWidth', 2, 'MarkerSize', 6); hold on;
semilogy(SNR_dB, ber_rayleigh, 'r-s', 'LineWidth', 2, 'MarkerSize', 6);
grid on;
xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
title('Figure 8: BER vs SNR for QPSK (AWGN vs Rayleigh)');
legend('QPSK in AWGN (Theoretical)', 'QPSK in Rayleigh (Theoretical)');
ylim([1e-6 1]);
saveas(gcf, 'Figure8_BER_SNR.png');

fprintf('Simulation Complete. Figure 8 generated.\n');
