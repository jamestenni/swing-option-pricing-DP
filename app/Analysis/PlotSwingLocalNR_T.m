function PlotSwingLocalNR_T(n_right, n_time, l_min, l_max, S0, K, mu, ...
                            sigma, kappa, risk_premium, r, T_list, N_one_year, ax)

% USAGE:
%   PlotSwingLocalNR_T(2, 5, -1, 1, 100, 100, 100, 0.7, 1, 0.1, 0.1, (1:0.5:3), 1000)

noT = length(T_list);
price = nan(noT, 1);

for i = 1:noT
    T = T_list(i);
    N = T * N_one_year;
    price(i, 1) = SwingLocalNR(n_right, n_time, l_min, l_max, S0, K, mu, ...
                                   sigma, kappa, risk_premium, r, T, N);
end


if nargin < 14
    ax = axes();
end

plot(ax, T_list, price, 'LineWidth', 2, 'Color', 'red');
xlabel(ax,'Time to Maturity (T)')
ylabel(ax, 'Option price (P)')
title(ax, {'Price of the Swing Option with only Local Constraints'
 'for various value of Time to Maturity (T)'})
set(ax, 'FontSize', 16)
grid(ax, 'on');
legend(ax, 'off')
% grid on
end