function PlotSwingLocalGlobalNR_g_nright_3D(n_right_list, n_time, m,...
    l_min, l_max, S0, K, mu, sigma, kappa, risk_premium, r, T, N, g_list, ax)

% USAGE: PlotSwingLocalGlobalNR_g_nright_3D((1:1:5), 5, 1, -1, 1, 100, 100, 100, 0.7, 1, 0.2, 0.1, 1, 600, (1:1:8))
% add denpendency
len_n_right = length(n_right_list);
len_g = length(g_list);

n_right_grid = repmat(n_right_list, len_g, 1);
g_grid = repmat(g_list', 1, len_n_right);

SwingPrice = nan(len_g, len_n_right);
SwingPriceLocal = nan(len_g, len_n_right);

display(len_g);
for i=1:len_g
    if mod(i, 10)==0
        display(i);
    end
    for j=1:len_n_right
        
        n_right = n_right_grid(i, j);
        g = g_grid(i, j);
        [SwingPrice(i, j), ~] = SwingGlobalNR(n_right, n_time, m, l_min, l_max, ...
                      -g, g, S0, K, mu, sigma, kappa, risk_premium, ... 
                      r, T, N);
        [SwingPriceLocal(i, j), ~] = SwingLocalNR(n_right, n_time, l_min, l_max, S0, K, mu, ...
                                   sigma, kappa, risk_premium, r, T, N);
    end
    
end

if nargin < 16
    ax = axes();
end


% Global Constraint Swing Option
s = mesh(ax, n_right_grid, g_grid, SwingPrice);
hold(ax, 'on');
s.FaceColor = 'flat';
s.FaceAlpha = 0.5;
% Local Constraint Swing Option
s_local = mesh(ax, n_right_grid, g_grid, SwingPriceLocal);
s_local.FaceAlpha = 0;
s_local.LineStyle = '--';
s_local.EdgeColor = 'k';
hold(ax, 'off');


xlabel(ax, 'Number of Exercise Rights (n\_right)');
ylabel(ax, 'Global Constraint (g\_min, g\_max)');
zlabel(ax, 'Option Price');
title(ax, 'Relationship between Number of Exercise Rights, Global Constraint and Option Price');
set(ax, 'FontSize', 18);
legend(ax, {'Global+Local Constraint', 'Local Constraint'}, ...
    "Location","northwest");

end