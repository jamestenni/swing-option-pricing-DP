function PlotSwingLocalNR_sigma(n_right, n_time, l_min, l_max, S0, K, mu, ...
                            sigma_list, kappa, risk_premium, r, T, N, ax)

% USAGE:
% PlotSwingLocalNR_sigma(2, 5, -1, 1, 100, 100, 100, (0.05:0.01:0.7), 1, 0.1, 0.1, 1, 1000)

nosigma = length(sigma_list);
price = nan(nosigma, 1);

for i = 1:nosigma
    sigma = sigma_list(i);
    price(i, 1) = SwingLocalNR(n_right, n_time, l_min, l_max, S0, K, mu, ...
                                   sigma, kappa, risk_premium, r, T, N);
end


if nargin < 14
    ax = axes();
end

plot(ax, sigma_list, price, 'LineWidth', 2, 'Color', 'red');
xlabel(ax,'Volatility (sigma)')
ylabel(ax, 'Option price (P)')
title(ax, {'Price of the Swing Option with only Local Constraints'
 'for various value of volatility (sigma)'})
set(ax, 'FontSize', 16)
grid(ax, 'on');
legend(ax, 'off')
% grid on
end