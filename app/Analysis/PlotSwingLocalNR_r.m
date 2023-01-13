function PlotSwingLocalNR_r(n_right, n_time, l_min, l_max, S0, K, mu, ...
                            sigma, kappa, expected_return_list, r_list, T, N, ax)

% USAGE:
%   PlotSwingLocalNR_r(2, 5, -1, 1, 100, 100, 100, 0.7, 1, [0:0.05:0.15], [0.05:0.05:0.95], 1, 1000)

noe = length(expected_return_list);
nor = length(r_list);
if nargin < 14
    ax = axes();
end

for i = 1:noe
    expected_return = expected_return_list(i);
    price = nan(nor, 1);
    for j = 1:nor
        r = r_list(j);
        risk_premium = expected_return - r;
        price(j, 1) = SwingLocalNR(n_right, n_time, l_min, l_max, S0, K, mu, ...
                                   sigma, kappa, risk_premium, r, T, N);
    end
    plot(ax, r_list, price, 'LineWidth', 2, 'DisplayName', ['expected\_return = ', num2str(expected_return)]);
    hold(ax, "on");
end

hold(ax, "off");

xlabel(ax, 'Risk-free Rate (r)');
ylabel(ax, 'Option price (P)');
title(ax, {['Price of the Swing Option with only Local Constraints'] ...
            ['for various value of risk-free rate (r)'] ...
            ['when l\_min = ' num2str(l_min) ' and l\_max = ' num2str(l_max)] })
set(ax, 'FontSize', 16);
lgd = legend(ax);
lgd.Location = "northwest";
grid(ax, "on");
end