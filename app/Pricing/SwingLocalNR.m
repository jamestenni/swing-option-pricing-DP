function [P0, PVec] = SwingLocalNR(n_right, n_time, l_min, l_max, S0, K, mu, ...
                                   sigma, kappa, risk_premium, r, T, N)

% This function computes the price of the swing options, which have only
% local constraints on each swing, based on the Censured Mean Reversion 
% Binomial Model by Nelson and Ramaswamy (1990).
% 
% INPUT:
%   n_right = number of swing rights over the life of the contract
%   n_time = number of times of asset to be delivered over the life of the contract 
%   l_min = maximum decreased number of units of asset when the buyer
%           exercise his/her swing down rights (<= 0)
%   l_max = maximum increased nuber of units of asset when the buyer
%           exercise his/her swing up rights (>= 0)
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
%   [P0, PVec] = SwingLocalNR(3, 5, -1, 1, 100, 100, 100, 0.7, 5, 0.2, 0.1, 0.33, 100)

% -- validating input --
if floor(n_right) ~= n_right || n_right < 0 || n_right > n_time
    error("'n_right must be positive integer and not exceed n_time'")
end
if floor(n_time) ~= n_time || n_time < 0
    error("'n_time' must be positive integer")
end
if l_min > 0
    error("'l_min' must be zero or negative real number")
end
if l_max < 0
    error("'l_max' must be zero or positive real number")
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
% OMat has 2 parameters: i, right_left
% i = the position of the node counted from the top of the matrix in each
%     timestep
% right_left = the current total of swing rights left
OMat = nan(N+1, n_right);

% -- compute payoff at the end --
% if right_left >= 1: payoff = maximum between (swing up, swing down)
% if right_left = 0: payoff = 0
ST = Stree(:, N+1);
OMat(:, :) = repmat(max(l_max*(ST - K), l_min*(ST - K)), 1, n_right);

% -- backward calculation --
% by looping back from time N-1 to 0
for i = N:-1:1
    % option buyers can exercise their rights only on the date of delivery
    % of the assert (We set all delivery dates to be equally apart throughout
    % the contract life) and they cannot exercise their rights on the
    % start date
    can_exercise = mod(i-1, N/n_time) == 0 & i ~= 1;

    for j = n_right:-1:1
        % in each timestep, loop from having rights_left = n_right (max)
        % until have only 1 right left (righyts_left = 1)

        % value_not_exercise = discounted value of the option if the buyer doesn't
        % exercise their rights at this timestep. (the amount of rights_left remain
        % the same)
        value_not_exercise = exp(-r*dt)*(Ptree(1:i, i).*OMat(1:i, j) + ...
                             (1-Ptree(1:i, i)).*OMat(2:i+1, j));

        if can_exercise
            % if the buyer can exericse on this timestep, we need to
            % compare the value between not exercising (rights_left remain
            % the same) and exercising with receiving payoff (rights_left
            % decreased by 1)
            
            payoff = max(l_max*(Stree(1:i, i) - K), l_min*(Stree(1:i, i) - K));
            if j > 1
                value_exercise = exp(-r*dt)*(Ptree(1:i, i).*OMat(1:i, j-1) + ...
                                (1-Ptree(1:i, i)).*OMat(2:i+1, j-1));
            else
                % if we have only 1 right left at this timestep, and decide
                % to exercise the right, the value of the option will be
                % 0, since there is no right left to be exercised anymore.
                value_exercise = 0;
            end        
            OMat(1:i, j) = max(value_not_exercise, value_exercise + payoff);
        else
            % if the buyer cannot exercise on this timestep, the value
            % of the option is just simply the value_not_exercise
            OMat(1:i, j) = value_not_exercise;
        end
    end
end

% -- obtain the price of the option --
P0 = OMat(1, n_right);
PVec = OMat(1, :);

end