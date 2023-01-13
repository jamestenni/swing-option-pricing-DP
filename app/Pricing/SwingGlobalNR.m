function [P0, PVec] = SwingGlobalNR(n_right, n_time, m, l_min, l_max, ...
                      g_min, g_max, S0, K, mu, sigma, kappa, risk_premium, ... 
                      r, T, N)

% This function computes the price of the swing options, which have
% local constraints on each swing and also global constraints on
% total swung amount, based on the Censured Mean Reversion 
% Binomial Model by Nelson and Ramaswamy (1990).
% 
% INPUT:
%   n_right = number of swing rights over the life of the contract
%   n_time = number of times of asset to be delivered over the life of the contract 
%   m = multiplier amount
%   l_min = maximum decreased number of units of asset when the buyer
%           exercise his/her swing down rights (<= 0 and divisible by m)
%   l_max = maximum increased nuber of units of asset when the buyer
%           exercise his/her swing up rights (>= 0 and divisible by m)
%   g_min = maximum decreased total number of units of asset that the buyer
%           swing down throughout the contract lifetime (<= l_min and divisible by m)
%   g_max = maximum increased total number of units of asset that the buyer
%           swing upthroughout the contract lifetime (>= l_max and divisible by m)
%   S0 = initial asset price
%   K = strike price
%   mu = long-run mean of the asset price
%   sigma = volatility of the process
%   kappa = mean reversion speed 
%   risk_premium = risk premium of the process
%   r = annualized continuously compounded interest rate
%   T = time to maturity date of the option (year)
%   N = number of timesteps in the Nelson and Ramaswamy model
% 
% OUTPUT:
%   P0 = swing option price at time 0 with full n_right
%   PVec = swing option price at time 0 vector having 1, 2, ..., n_right
%           
% USAGE:
%   [P0, PVec] = SwingGlobalNR(3, 5, 1, -1, 1, -3, 4, 100, 100, 100, 0.7, 1, 0.2, 0.1, 0.33, 100)

% -- validating input --
if floor(n_right) ~= n_right || n_right < 0 || n_right > n_time
    error("'n_right must be positive integer and not exceed n_time'")
end
if floor(n_time) ~= n_time || n_time < 0
    error("'n_time' must be positive integer")
end
if m <= 0
    error("'m' (multiplier) must be potisive real number")
end
if l_min > 0 || mod(l_min, m) ~= 0
    error("'l_min' must be zero or negative real number and must be divisible by m")
end
if l_max < 0 || mod(l_max, m) ~= 0
    error("'l_max' must be zero or positive real number and must be divisible by m")
end
if g_min > l_min || mod(g_min, m) ~= 0
    error("'g_min' must be less than or equal to l_min and must be divisible by m")
end
if g_max < l_max || mod(g_max, m) ~= 0
    error("'g_max' must be greater than or equal to l_max and must be divisible by m")
end
if mod(N, n_time) ~= 0
    error("'N' must be divisible by 'n_time'")
end

% dt = delta time in each step
dt = T/N;

% -- obtain the Stree and Ptree --
% generated from the Nelson and Ramaswamy
[Stree, Ptree, ~] = MeanRevertNRPriceTree(S0, mu, sigma, kappa, risk_premium, T, N);

% -- initializes the option price matrix -- 
% OMat has 3 parameters: i, right_left, l_cumu
% i = the position of the node counted from the top of the matrix in each
%     timestep
% right_left = the current total of swing rights left
% l_cumu = the net total swing amount 

l_cumu_max = min(n_right * l_max, g_max);
l_cumu_min = max(n_right * l_min, g_min);
num_l_cumu = (l_cumu_max - l_cumu_min)/m + 1;

OMat = nan(N+1, n_right, num_l_cumu);

% -- compute payoff at the end --
ST = Stree(:, N+1);
% possible maximum / mininum number of units to swing for each l_cumu
l_max_b = min(l_cumu_max - (l_cumu_min:m:l_cumu_max), l_max);
l_min_b = max(l_cumu_min - (l_cumu_min:m:l_cumu_max), l_min);

payoff_swing_high = repmat(l_max_b, length(ST), 1) .* repmat(ST - K, 1, length(l_max_b));
payoff_swing_low = repmat(l_min_b, length(ST), 1) .* repmat(ST - K, 1, length(l_min_b));
payoff = max(0, max(payoff_swing_low, payoff_swing_high));
OMat(:,:,:) = repmat(reshape(payoff, [length(ST), 1, num_l_cumu]), 1, n_right, 1);

% -- backward calculation --
% by looping back from time N-1 to 0
for i = N:-1:1
    old_OMat = OMat(:,:,:);
    can_exercise = mod(i-1, N/n_time) == 0 & i ~= 1;

    l_cumu_max_i = min(min(n_right, floor((i-1)/(N/n_time))) * l_max, g_max);
    l_cumu_min_i = max(min(n_right, floor((i-1)/(N/n_time))) * l_min, g_min);

    % for each timestep, loop through all possible l_cumu (which is finite set, since
    % we make sure that g_min,l_min,g_max,l_max are all divisible by m)
    for l_cumu = l_cumu_min_i: m: l_cumu_max_i
        % in each l_cumu, determine the set of swing amount possible
        k = (l_cumu - l_cumu_min)/m + 1;
        l_max_k = l_max_b(k);
        l_min_k = l_min_b(k);
        num_l = (l_max_k - l_min_k)/m + 1;

        for j = n_right: -1: 1
            value_not_exercise = exp(-r*dt)*(Ptree(1:i, i) .* old_OMat(1:i, j, k) + ...
                                (1-Ptree(1:i, i)) .* old_OMat(2:i+1, j, k));
            if can_exercise
                if j > 1
                    % for each possible swing amount, determine the
                    % discounted option value after the buyer decide to swing
                    % together with its payoff, then compared it with the
                    % value if the buyer choose not to exercise.
                    payoff = repmat(l_min_k: m: l_max_k, i, 1) .* repmat(Stree(1:i, i) - K, 1, num_l);
                    payoff = reshape(payoff, [i, 1, num_l]);

                    k_j = (l_cumu + (l_min_k: m: l_max_k) - l_cumu_min)/m + 1;
                    value_exercise = exp(-r*dt)*(Ptree(1:i, i) .* old_OMat(1:i, j-1, k_j) + ...
                                    (1-repmat(Ptree(1:i, i), 1, 1, num_l)) .* old_OMat(2:i+1, j-1, k_j));

                    OMat(1:i, j, k) = max(value_not_exercise, max(payoff + value_exercise, [], 3));    
                else
                    % if we have only 1 right left at this timestep, and decide
                    % to exercise the right, the value of the option will be
                    % 0, since there is no right left to be exercised anymore.
                    payoff = max(l_max_k*(Stree(1:i, i) - K), l_min_k*(Stree(1:i, i) - K));
                    OMat(1:i, j, k) = max(value_not_exercise, payoff);
                end
            else
                OMat(1:i, j, k) = value_not_exercise;
            end
        end
    end
end

% -- obtain the price of the option --
% actual swing option price is the price at time 0 with full n_right and l_cumu = 0
P0 = OMat(1, n_right, -l_cumu_min/m + 1);
PVec = OMat(1, :, -l_cumu_min/m + 1);

end