%% Capacity Analysis (Trunking Theory)
% Script for Deliverable 2 - File 4
clear; clc; close all;

% --- Parameters ---
N_vals = [3, 4, 7];
C_total = 100;
Pb_target = 0.02;     % 2% Blocking Probability
User_traffic = 0.025; % 0.025 Erlangs/user

% --- Calculations ---
fprintf('========================================================\n');
fprintf('               CAPACITY ANALYSIS RESULTS                \n');
fprintf('========================================================\n');
fprintf('N\t Channels/Cell\t Max Traffic (E)\t User Capacity\n');
fprintf('--------------------------------------------------------\n');

E_plot = 0:0.1:40;
figure(4); hold on;

for N = N_vals
    C = floor(C_total / N);
    
    % Find max E for Pb <= 2% using iteration
    E_max = 0;
    for e_test = 0:0.01:100
        if erlang_b_calc(e_test, C) > Pb_target
            E_max = e_test - 0.01;
            break;
        end
    end
    
    User_cap = floor(E_max / User_traffic);
    fprintf('%d\t %d\t\t %.2f\t\t\t %d\n', N, C, E_max, User_cap);
    
    % Data for plotting
    pb_vals = arrayfun(@(e) erlang_b_calc(e, C), E_plot);
    plot(E_plot, pb_vals, 'LineWidth', 1.5, 'DisplayName', ['N=' num2str(N) ' (C=' num2str(C) ')']);
end

yline(Pb_target, 'k--', 'Target Pb = 2%', 'LineWidth', 1.5);
xlabel('Offered Traffic (Erlangs)');
ylabel('Blocking Probability (Pb)');
title('Figure 4: Blocking Probability vs Offered Traffic');
legend('show', 'Location', 'NorthWest');
ylim([0 0.1]);
grid on;
saveas(gcf, 'Figure4_Capacity.png');
fprintf('========================================================\n');

% --- Erlang B Function (Iterative to avoid overflow) ---
function pb = erlang_b_calc(E, C)
    if E == 0, pb = 0; return; end
    pb = 1;
    for i = 1:C
        pb = (E * pb) / (i + E * pb);
    end
end
