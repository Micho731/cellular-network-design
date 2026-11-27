%% Large and Small Scale Fading Simulation
clear; clc; close all;

% --- Part A: Large-Scale Fading (Shadowing) ---
d = linspace(100, 1000, 200);   % 200 distance points
n = 3.5;                        % Path loss exponent
PL_mean = 80 + 10*n*log10(d/100); % Mean path loss (dB)
sigma = 6;                      % Shadowing std dev (dB)
X_sigma = sigma * randn(size(d)); % Log-normal shadowing

% System parameters for Pr
Pt = 43; Gt = 15; Gr = 0;
Ms = sqrt(2)*sigma*erfcinv(2*(1 - 0.95));        % 95 % edge-coverage margin, 9.87 dB
L_total = 2 + 1 + 3 + 10 + 2 + Ms + 3;           % same losses as link_budget.m
Pr_mean = Pt + Gt + Gr - L_total - PL_mean;
Pr_shadow = Pr_mean + X_sigma;

figure(5);
plot(d, Pr_shadow, 'b', 'DisplayName', 'Signal with Shadowing'); hold on;
plot(d, Pr_mean, 'r', 'LineWidth', 2, 'DisplayName', 'Mean Path Loss');
xlabel('Distance (m)');
ylabel('Received Power (dBm)');
title('Figure 5: Received Power with Log-Normal Shadowing (\sigma=6 dB)');
legend('show');
grid on;
saveas(gcf, 'Figure5_Shadowing.png');

% --- Part B: Small-Scale Fading (Rayleigh) ---
num_samples = 10000;
I = randn(1, num_samples);
Q = randn(1, num_samples);
r = sqrt(I.^2 + Q.^2); % Rayleigh envelope

figure(6);
histogram(r, 'Normalization', 'pdf', 'DisplayName', 'Simulated Rayleigh');
hold on;
x = 0:0.01:max(r);
% Theoretical Rayleigh PDF: (x/sigma^2)*exp(-x^2/(2*sigma^2)) 
% Here, since I and Q are N(0,1), sigma_chan = 1.
theoretical_pdf = x .* exp(-x.^2 / 2); 
plot(x, theoretical_pdf, 'r', 'LineWidth', 2, 'DisplayName', 'Theoretical Rayleigh PDF');
xlabel('Signal Envelope (r)');
ylabel('Probability Density');
title('Figure 6: Rayleigh Fading Distribution (Small-Scale)');
legend('show');
grid on;
saveas(gcf, 'Figure6_Rayleigh.png');
