function PlotSwingLocalNR_n_right(n_time, l_min, l_max, S0, K, mu, ...
                            sigma, kappa, risk_premium, r, T, N, ax)

% USAGE:
%   PlotSwingLocalNR_n_right(50, -1, 1, 100, 100, 100, 0.7, 1, 0.1, 0.1, 1, 1000)
if nargin < 13
    ax = axes();
end

[~, PVec] = SwingLocalNR(n_time, n_time, l_min, l_max, S0, K, mu, ...
                          sigma, kappa, risk_premium, r, T, N);

plot(ax, (1:n_time)*100/n_time, PVec, 'LineWidth', 2, 'Color', 'red')
xlabel(ax, 'Percentage of n\_right/n\_time')
ylabel(ax, 'Option price (P)')
title(ax, {'Price of the Swing Option with only Local Constraints'
 'for various percentage value of n\_right/n\_time'})
set(ax, 'FontSize', 16)
grid(ax, 'on');
legend(ax, 'off')

end