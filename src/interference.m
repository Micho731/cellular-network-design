%% Interference Analysis
% Script for Deliverable 2 - File 2
clear; clc; close all;

% --- Parameters ---
N_vals = [3, 4, 7]; % Cluster sizes
R = 1;              % Cell radius (km)
n = 3.5;            % Path loss exponent
SIR_min = 18;       % Minimum SIR requirement (dB)

% --- Calculations ---
D = R * sqrt(3 * N_vals);           % Reuse distance
SIR_lin = (1/6) * (D/R).^n;         % SIR in linear (assuming 6 interferers)
SIR_db = 10 * log10(SIR_lin);       % SIR in dB

% --- Console Output ---
fprintf('========================================================\n');
fprintf('               INTERFERENCE ANALYSIS RESULTS             \n');
fprintf('========================================================\n');
fprintf('N\t D (km)\t D/R Ratio\t SIR (dB)\t Status\n');
fprintf('--------------------------------------------------------\n');
for i = 1:length(N_vals)
    status = 'FAIL';
    if SIR_db(i) >= SIR_min
        status = 'PASS';
    end
    fprintf('%d\t %.2f\t %.2f\t\t %.2f\t\t %s\n', N_vals(i), D(i), D(i)/R, SIR_db(i), status);
end
fprintf('========================================================\n');

% --- Plot SIR (dB) vs N as a Bar Chart ---
figure;
bar_handle = bar(categorical(N_vals), SIR_db);
hold on;
yline(SIR_min, 'r--', 'SIR min = 18 dB', 'LineWidth', 2, 'LabelHorizontalAlignment', 'center');
xlabel('Cluster Size (N)');
ylabel('SIR (dB)');
title('SIR (dB) vs Cluster Size N');
grid on;

% Label the bars
for i = 1:length(SIR_db)
    text(i, SIR_db(i) + 0.5, [num2str(SIR_db(i), '%.1f') ' dB'], 'HorizontalAlignment', 'center');
end

saveas(gcf, 'SIR_vs_N.png');
