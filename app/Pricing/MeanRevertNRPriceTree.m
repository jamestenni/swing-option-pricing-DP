function [Stree, Ptree, Xtree] = MeanRevertNRPriceTree(S0, mu, sigma, kappa, risk_premium, T, N)

% This function generates the price tree of the Censured Mean
% Reversion Binomial Model by Nelson and Ramaswamy (1990) which
% follows the Ornstein-Uhlenbeck Process.
% 
% dx_t = kappa*(x_bar - x_t)*dt + sigma*dW_t
% where x_bar = ln(mu) - sigma^2 / (2*kappa) and x_t = ln(S_t)
%
% x_t+1 = x_t + u ; with probability p
%         x_t + d ; with probability 1-p
% where u = sigma*sqrt(dt), d = -sigma*sqrt(dt)
% and p = max(0, min(1, 1/2 + (1/2)*(kappa*((x_bar - risk_premium/kappa) - x_t))*sqrt(dt)/sigma))
% 
% INPUT:
%   S0 = initial asset price
%   mu = long-run mean of the asset price
%   sigma = volatility of the process
%   kappa = mean reversion speed
%   risk_premium = risk premium of the process
%   T = time period
%   N = number of timesteps
% 
% OUTPUT:
%   Stree = the price tree from the model
%   Ptree = the risk-neutral up probability tree from the model
%   Xtree = the natural log of the price tree from the model
% 
% USAGE:
%   [Stree, Ptree, Xtree] = MeanRevertNRPriceTree(100, 100, 0.7, 1, 0.2, 1/12, 20)

% dt = time duration in each timestep in the model
dt = T/N;

% u = up-factor, d = down - factor
u = sigma*sqrt(dt);
d = -u;

% initializes and generate the Xtree
x0 = log(S0);
Xtree = nan(N+1, N+1);
Xtree(1, 1) = x0;
for i = 2:N+1
    Xtree(1:i, i) = x0 + (i-1: -2: -i+1)*u;
end

% initializes and generate the Ptree
x_bar = log(mu) - sigma^2 / (2 * kappa);
Ptree = nan(N+1, N+1);
for i = 1:N+1
    prob_not_censured = 1/2 + (1/2)*(kappa * (x_bar - risk_premium/kappa - ...
                        Xtree(1:i, i)))*sqrt(dt)/sigma;
    Ptree(1:i, i) = max(0, min(1, prob_not_censured));
end

% calculate the Stree
Stree = exp(Xtree);

end