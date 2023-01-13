function PlotSwingLocalNR_S0_kappa(n_right, n_time, l_min, l_max, S0_list, K, mu, ...
                            sigma, kappa_list, risk_premium, r, T, N, ax)

% USAGE:
%   PlotSwingLocalNR_S0_kappa(2, 5, -1, 1, 25:10:175, 100, 100, 0.7, (1:3:10), 0.1, 0.1, 1, 1000)

nokappa = length(kappa_list);
noS0 = length(S0_list);
price = nan(noS0, 1);


if nargin < 14
    ax = axes();
end

for i = 1:nokappa
    for j = 1:noS0
        S0 = S0_list(j);
        kappa = kappa_list(i);
        price(j, 1) = SwingLocalNR(n_right, n_time, l_min, l_max, S0, K, mu, ...
                                       sigma, kappa, risk_premium, r, T, N);
    end
    plot(ax, S0_list, price, 'LineWidth', 2, 'DisplayName', ['kappa = ', num2str(kappa_list(i))]);
    hold(ax, 'on');
end


hold(ax, 'off');
xlabel(ax,'Price of the underlying asset at t=0 (S0)')
ylabel(ax, 'Option price (P)')
title(ax, {'Price of the Swing Option with only Local Constraints'
 'for various value of S0'})
set(ax, 'FontSize', 16)
legend(ax, 'show');
grid(ax, 'on');
% grid on
end