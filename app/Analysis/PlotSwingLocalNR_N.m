function PlotSwingLocalNR_N(n_right, n_time, l_min, l_max, S0, K, mu, ...
                            sigma, kappa, risk_premium, r, T, N_list, ax)

% USAGE: 
%   PlotSwingLocalNR_N(2, 5, -1, 1, 100, 100, 100, 0.7, 1, 0.1, 0.1, 1, 100:10:2500)

noN = length(N_list);
price = nan(noN, 1);

for i = 1:noN
    N = N_list(i);
    price(i, 1) = SwingLocalNR(n_right, n_time, l_min, l_max, S0, K, mu, ...
                                   sigma, kappa, risk_premium, r, T, N);
end


if nargin < 14
    ax = axes();
end

plot(ax, N_list, price, 'LineWidth', 2, 'Color', 'red');
xlabel(ax,'Number of Time Steps (N)')
ylabel(ax, 'Option price (P)')
title(ax, {'Price of the Swing Option with only Local Constraints'
 'for various value of the number of time steps (N)'})
set(ax, 'FontSize', 16)
legend(ax, 'off')
grid(ax, 'on');
% grid on
end