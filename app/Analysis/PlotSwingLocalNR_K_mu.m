function PlotSwingLocalNR_K_mu(n_right, n_time, ...
    l_min, l_max, S0, K_list, mu, sigma, kappa, risk_premium, r, T, N, ax)

% USAGE: PlotSwingLocalNR_K_mu(2, 5, -1, 1, 100, (0: 10: 300)', [50;100;150], 0.7, 1, 0.1, 0.1, 1, 1000)

if nargin < 14
    ax = axes();
end

SwingPrice = nan(length(K_list), 1);

for mu_i=1:length(mu)
    for n=1:length(K_list)
        if mod(n, 10) == 0
            display("Strike Price = " + num2str(n));
        end
        
        K = K_list(n, 1);
        [SwingPrice(n, 1), ~] = SwingLocalNR(n_right, n_time, l_min, l_max, S0, K, mu(mu_i, 1), ...
                                       sigma, kappa, risk_premium, r, T, N);
    end
    plot(ax, K_list, SwingPrice, '-o', "LineWidth", 2, "DisplayName", ['long-run mean = ', num2str(mu(mu_i, 1))]); 
    hold(ax, 'on');
end

hold(ax, 'off');

xlabel(ax, 'Strike Price (K)');
ylabel(ax, 'Option Price (P)');
title(ax, 'Relationship between Strike Price and Option Price');
legend(ax, "Location","northwest");
set(ax, "FontSize", 18);
end