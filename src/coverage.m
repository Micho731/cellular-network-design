%% Shadowing margin vs cell-edge coverage
% With log-normal shadowing of standard deviation sigma, a fade margin M
% keeps the cell-edge signal above threshold with probability
%     P = 1 - Q(M/sigma),  Q(x) = 0.5*erfc(x/sqrt(2)).
% Finds the margin for 95 % edge coverage, checks it by Monte Carlo and
% shows the link budget closes with it.
% Runs in MATLAB or GNU Octave, no toolboxes.

clear; clc; close all;
rng(1);

sigma  = 6;          % dB
M_used = 6;          % dB, 1 sigma (for comparison)
target = 0.95;

Qf   = @(x) 0.5*erfc(x/sqrt(2));
Pcov = @(M) 1 - Qf(M/sigma);

% margin for the target, by bisection on Pcov
lo = 0; hi = 30;
for it = 1:60
    mid = (lo+hi)/2;
    if Pcov(mid) < target, lo = mid; else, hi = mid; end
end
M_95 = hi;

% Monte Carlo check: draw shadowing at the cell edge
X = sigma * randn(1, 1e6);
mc_used = mean(X <= M_used);
mc_95   = mean(X <= M_95);

% Link budget at 1 km with the 95 % margin (same numbers as link_budget.m)
Pt = 43; Gt = 15; Gr = 0; Lf = 2; Lc = 1; Lb = 3; Lp = 10; Li = 2; Mf = 3;
PL_edge = 80 + 10*3.5*log10(1000/100);
Pmin = -100;
Pr_used = Pt + Gt + Gr - (Lf+Lc+Lb+Lp+Li+M_used+Mf) - PL_edge;
Pr_95   = Pt + Gt + Gr - (Lf+Lc+Lb+Lp+Li+M_95+Mf)   - PL_edge;

fprintf('Edge coverage with a %g dB margin: %.1f %% (Monte Carlo %.1f %%)\n', M_used, 100*Pcov(M_used), 100*mc_used);
fprintf('Margin needed for %.0f %% edge coverage: %.2f dB (Monte Carlo %.1f %%)\n', 100*target, M_95, 100*mc_95);
fprintf('Link margin at 1 km: %.1f dB with %g dB shadowing margin, %.1f dB with %.2f dB\n', ...
        Pr_used - Pmin, M_used, Pr_95 - Pmin, M_95);

% ---- plot ----
M = 0:0.1:15;
figure('Position', [100 100 720 430]);
plot(M, 100*Pcov(M), 'LineWidth', 2); hold on; grid on; box on;
plot(M_used, 100*Pcov(M_used), 'o', 'MarkerSize', 8, 'MarkerFaceColor', [0.85 0.33 0.10], 'Color', [0.85 0.33 0.10]);
plot(M_95, 100*target, 's', 'MarkerSize', 8, 'MarkerFaceColor', [0.47 0.67 0.19], 'Color', [0.47 0.67 0.19]);
text(M_used + 0.3, 100*Pcov(M_used) - 3, sprintf('%g dB used: %.1f %%', M_used, 100*Pcov(M_used)));
text(M_95 + 0.3, 100*target - 3, sprintf('%.1f dB needed: 95 %%', M_95));
xlabel('Shadowing margin (dB)'); ylabel('Cell-edge coverage (%)');
title(sprintf('Cell-edge coverage vs shadowing margin (\\sigma = %g dB)', sigma));
ylim([50 100]); xlim([0 15]);
saveas(gcf, '../media/shadowing_coverage.png');
