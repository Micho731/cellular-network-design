%% QPSK bit-error rate by Monte Carlo simulation: AWGN and Rayleigh fading
% Added in the 2026 review (not part of the original scripts).
%
% End-to-end chain, written out by hand so it needs no toolbox:
%   random bits -> Gray-coded QPSK -> flat Rayleigh fading -> AWGN
%   -> coherent detection (perfect channel knowledge) -> count bit errors
% The simulated BER is compared with the theory curves used in ber_snr.m.
% Note: those formulas take Eb/N0 (energy per bit), so the x-axis here is
% Eb/N0. For QPSK, Es/N0 = Eb/N0 + 3 dB.
%
% Runs in MATLAB or GNU Octave, no toolboxes.

clear; clc; close all;
rng(7);

EbN0_dB   = 0:2:30;
max_bits  = 2e7;          % cap per point
min_errs  = 200;          % stop a point once this many errors are seen
block     = 1e6;          % bits per batch (even)

ber_awgn = zeros(size(EbN0_dB));
ber_ray  = zeros(size(EbN0_dB));
n_err    = zeros(2, numel(EbN0_dB));

for k = 1:numel(EbN0_dB)
    EbN0 = 10^(EbN0_dB(k)/10);
    N0   = 1/(2*EbN0);                 % Es = 1, Eb = 1/2
    errs = [0 0]; bits = 0;
    while bits < max_bits && min(errs) < min_errs
        b  = rand(1, block) > 0.5;
        bI = b(1:2:end); bQ = b(2:2:end);
        s  = ((1 - 2*bI) + 1j*(1 - 2*bQ)) / sqrt(2);          % Gray QPSK, Es = 1
        w  = sqrt(N0/2) * (randn(size(s)) + 1j*randn(size(s)));
        h  = (randn(size(s)) + 1j*randn(size(s))) / sqrt(2);   % E|h|^2 = 1

        r_awgn = s + w;
        r_ray  = h.*s + w;
        z_ray  = r_ray .* conj(h);                            % coherent: undo the phase

        for c = 1:2
            if c == 1, z = r_awgn; else, z = z_ray; end
            dI = real(z) < 0; dQ = imag(z) < 0;
            errs(c) = errs(c) + sum(dI ~= bI) + sum(dQ ~= bQ);
        end
        bits = bits + block;
    end
    n_err(:, k) = errs(:);
    ber_awgn(k) = errs(1)/bits;
    ber_ray(k)  = errs(2)/bits;
    fprintf('Eb/N0 = %2d dB: AWGN %.3e   Rayleigh %.3e   (%g bits)\n', EbN0_dB(k), ber_awgn(k), ber_ray(k), bits);
end

g = 10.^(EbN0_dB/10);
th_awgn = 0.5*erfc(sqrt(g));
th_ray  = 0.5*(1 - sqrt(g./(1 + g)));

% ---- plot ----
figure('Position', [100 100 740 470]);
semilogy(EbN0_dB, th_awgn, 'b-', 'LineWidth', 1.6); hold on;
semilogy(EbN0_dB, th_ray,  'r-', 'LineWidth', 1.6);
ok = n_err(1,:) >= 20;   % plot only points with at least 20 errors counted
semilogy(EbN0_dB(ok), ber_awgn(ok), 'bo', 'MarkerSize', 7, 'LineWidth', 1.4);
semilogy(EbN0_dB(n_err(2,:) >= 20), ber_ray(n_err(2,:) >= 20), 'rs', 'MarkerSize', 7, 'LineWidth', 1.4);
grid on; box on; ylim([1e-7 1]);
xlabel('E_b/N_0 (dB)'); ylabel('Bit error rate');
title('QPSK: Monte Carlo simulation vs theory');
legend('AWGN, theory', 'Rayleigh, theory', 'AWGN, simulated', 'Rayleigh, simulated', 'Location', 'southwest');
saveas(gcf, '../media/qpsk_ber_montecarlo.png');
