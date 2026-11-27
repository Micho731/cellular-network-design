%% Capacity: cluster size and sector layout, Erlang B per sector
% Each sector has its own antenna and its own channels, so a cell's
% C = 100/N channels are split between its sectors and Erlang B is run on
% each sector's pool. Compares omni, 120 deg and 60 deg cells for
% N = 3, 4, 7 and picks the highest-capacity layout that meets 18 dB SIR.
% Runs in MATLAB or GNU Octave, no toolboxes.

clear; clc; close all;

C_total  = 100;      % channels
n        = 3.5;      % path-loss exponent
SIR_min  = 18;       % dB
Pb       = 0.02;     % blocking target
A_user   = 0.025;    % Erlangs per user
Area     = 25;       % km^2
R        = 1;        % km

N_vals   = [3 4 7];
layouts  = {'Omni', '120 deg', '60 deg'};
sectors  = [1 3 6];
i0       = [6 2 1];  % first-tier co-channel interferers seen by one sector

fprintf('%-8s %-3s %-9s %-18s %-11s %-10s %s\n', 'Layout', 'N', 'SIR (dB)', ...
        'Channels/sector', 'Erl/cell', 'Users/cell', 'SIR check');
fprintf('%s\n', repmat('-', 1, 78));

results = [];
for L = 1:numel(layouts)
    for N = N_vals
        Q   = sqrt(3*N);                       % D/R
        SIR = 10*log10(Q^n / i0(L));
        C   = floor(C_total / N);              % channels per cell
        S   = sectors(L);
        split = floor(C/S) * ones(1, S);       % share channels as evenly as possible
        extra = C - sum(split);
        split(1:extra) = split(1:extra) + 1;
        A_cell = 0;
        for k = 1:S
            A_cell = A_cell + erlang_capacity(split(k), Pb);
        end
        users = floor(A_cell / A_user);
        ok = SIR >= SIR_min;
        tag = 'fail'; if ok, tag = 'PASS'; end
        fprintf('%-8s %-3d %-9.2f %-18s %-11.2f %-10d %s\n', layouts{L}, N, SIR, ...
                mat2str(split), A_cell, users, tag);
        results(end+1, :) = [L N SIR A_cell users ok]; %#ok<AGROW>
    end
end

cells = ceil(Area / (1.5*sqrt(3)*R^2));        % hexagon area = 1.5*sqrt(3)*R^2
fprintf('\nCells needed to cover %d km^2 with R = %g km: %d\n', Area, R, cells);

pass = results(results(:,6) == 1, :);
[~, best] = max(pass(:,5));
fprintf('Highest capacity among designs that meet %d dB: %s, N = %d (%.2f dB, %d users/cell, %d users over %d cells)\n', ...
        SIR_min, layouts{pass(best,1)}, pass(best,2), pass(best,3), pass(best,5), pass(best,5)*cells, cells);

% ---- plot: users/cell vs SIR for every design ----
figure('Position', [100 100 760 460]);
marks = {'o', 's', '^'}; cols = [0 0.45 0.74; 0.85 0.33 0.10; 0.47 0.67 0.19];
hold on;
for L = 1:numel(layouts)
    r = results(results(:,1) == L, :);
    plot(r(:,3), r(:,5), ['-' marks{L}], 'Color', cols(L,:), 'LineWidth', 1.8, ...
         'MarkerFaceColor', cols(L,:), 'MarkerSize', 7);
    for k = 1:size(r,1)
        text(r(k,3) + 0.25, r(k,5) + 22, sprintf('N=%d', r(k,2)), 'FontSize', 9);
    end
end
yl = [0 1100];
plot([SIR_min SIR_min], yl, 'k--', 'LineWidth', 1.2);
text(SIR_min + 0.3, 1040, 'SIR_{min} = 18 dB', 'FontSize', 9);
ylim(yl); xlim([7 25]); grid on; box on;
xlabel('SIR (dB)'); ylabel('Users per cell at 2% blocking');
title('Capacity vs interference for every cluster size and sector layout');
legend(layouts, 'Location', 'northeast');
saveas(gcf, '../media/design_review.png');

function A = erlang_capacity(C, Pb)
% Largest offered traffic A with Erlang-B blocking <= Pb (bisection).
    lo = 0; hi = 2*C + 10;
    for it = 1:60
        mid = (lo + hi)/2;
        if erlang_b(mid, C) <= Pb, lo = mid; else, hi = mid; end
    end
    A = lo;
end

function pb = erlang_b(A, C)
    pb = 1;
    for k = 1:C
        pb = A*pb / (k + A*pb);
    end
end
