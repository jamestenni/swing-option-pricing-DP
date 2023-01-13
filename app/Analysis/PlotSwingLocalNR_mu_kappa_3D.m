function PlotSwingLocalNR_mu_kappa_3D(n_right, n_time, ...
    l_min, l_max, S0, K, mu_list, sigma, kappa_list, risk_premium, r, T, N, ax)

% USAGE: PlotSwingLocalNR_mu_kappa_3D(2, 5, -1, 1, 100, 100, (25:5:175), 0.7, (0.5:0.1:5), 0.1, 0.1, 1, 1000)

if nargin < 14
    ax = axes();
end


len_mu = length(mu_list);
len_kappa = length(kappa_list);

mu_grid = repmat(mu_list, len_kappa, 1);
kappa_grid = repmat(kappa_list', 1, len_mu);

SwingPrice = nan(len_kappa, len_mu);

display(len_mu);
for i=1:len_mu
    if mod(i, 10)==0
        display(i);
    end
    for j=1:len_kappa
        
        mu = mu_grid(j, i);
        kappa = kappa_grid(j, i);
        [SwingPrice(j, i), ~] = SwingLocalNR(n_right, n_time, l_min, l_max, S0, K, mu, ...
                                       sigma, kappa, risk_premium, r, T, N);
    end
    
end

s = mesh(ax, mu_grid, kappa_grid, SwingPrice);
s.FaceColor = 'flat';
s.FaceAlpha = 0.5;
xlabel(ax, 'long-run mean (mu)');
ylabel(ax, 'speed of reversion (kappa)');
zlabel(ax, 'Option Price');
title(ax,'Relationship between Long-run mean, Speed of Reversion and Option Price');
set(ax, 'FontSize', 18);
grid(ax, 'on');
legend(ax, 'off')
end