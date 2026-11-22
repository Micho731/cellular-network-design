%% Link Budget Analysis
% Script for Deliverable 2 - File 1
clear; clc; close all;

% --- Parameters ---
Pt = 43;        % Tx Power (dBm)
Gt = 15;        % Tx Antenna Gain (dBi)
Gr = 0;         % Rx Antenna Gain (dBi)
Lf = 2;         % Feeder Loss (dB)
Lc = 1;         % Connector Loss (dB)
Lb = 3;         % Body Loss (dB)
Lp = 10;        % Penetration Loss (dB)
Li = 2;         % Implementation Loss (dB)
Ms = 6;         % Shadowing Margin (dB)
Mf = 3;         % Fast Fading Margin (dB)
Pmin = -100;    % Rx Sensitivity (dBm)
n = 3.5;        % Path Loss Exponent
d0 = 100;       % Reference distance (m)
PL_d0 = 80;     % Reference Path Loss at d0 (dB)
Bc = 200e3;     % Channel Bandwidth (Hz)
NF = 7;         % Noise Figure (dB)

% --- 4.1 EIRP Calculation ---
EIRP = Pt + Gt - Lf - Lc;

% --- 4.2 Total Losses (excluding Path Loss) ---
L_total = Lf + Lc + Lb + Lp + Li + Ms + Mf;

% --- 4.3 Path Loss & Received Power calculation ---
d = 100:1:1000; % Distance from 100m to 1km
PL = PL_d0 + 10*n*log10(d/d0);
Pr = Pt + Gt + Gr - L_total - PL;

% --- 5.1 Noise Floor ---
N_floor = -174 + 10*log10(Bc) + NF;
SNR = Pr(end) - N_floor;

% --- Console Output ---
fprintf('========================================\n');
fprintf('       LINK BUDGET ANALYSIS RESULTS      \n');
fprintf('========================================\n');
fprintf('EIRP:                %.2f dBm\n', EIRP);
fprintf('Total System Loss:   %.2f dB\n', L_total);
fprintf('Path Loss at 1km:    %.2f dB\n', PL(end));
fprintf('Received Power (1km):%.2f dBm\n', Pr(end));
fprintf('Noise Floor:         %.2f dBm\n', N_floor);
fprintf('SNR at Cell Edge:    %.2f dB\n', SNR);
fprintf('Link Margin:         %.2f dB\n', Pr(end) - Pmin);
fprintf('========================================\n');

% --- Plot Figure 2: Received Power vs Distance ---
figure(2);
plot(d, Pr, 'r', 'LineWidth', 2);
xlabel('Distance (m)');
ylabel('Received Power (dBm)');
title('Figure 2: Received Power (dBm) vs Distance (100–1000 m)');
grid on;
saveas(gcf, 'Figure2_Pr_vs_Distance.png');

% --- Plot Figure 3: Coverage Analysis ---
figure(3);
plot(d, Pr, 'b', 'LineWidth', 2); hold on;
yline(N_floor, 'k--', 'Noise Floor (-114 dBm)', 'LabelHorizontalAlignment', 'right');
yline(Pmin, 'r:', 'Rx Sensitivity (-100 dBm)', 'LabelHorizontalAlignment', 'right');
xlabel('Distance (m)');
ylabel('Power Level (dBm)');
title('Figure 3: Noise Floor vs Signal Level vs Distance');
legend('Received Signal (Pr)', 'Noise Floor', 'Receiver Sensitivity');
grid on;
saveas(gcf, 'Figure3_Coverage_Limit.png');
