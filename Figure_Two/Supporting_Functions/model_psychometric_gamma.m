function [Synthetic_p_left, est_parameters, interp_time_diff] = model_psychometric_gamma(Input)
%% psychometric function
function [p_left] = Pr_Left_ts(Input, parameters)
    % parameter(1) => pWm, parameter(2) => pBound
    pdf_x = @(x, mu, sigma) ((1 / sqrt(2 * pi * (sigma^2))) .* exp(-((x - mu).^2) / (2 * (sigma^2))));
    p_left_func = @(ts, pWm, pBound, x_max, x_resolution, mid) ...
        (sum(pdf_x([(mid + pBound):x_resolution:x_max], ts, pWm .* ts)) .* x_resolution);
    x_resolution = 0.01; 
    x_max = 5;

    % Initialize synthetic probabilities
    p_left = zeros(1, length(Input.Sample_Interval));

    % Compute probabilities for each trial
    for iTrial = 1:length(Input.Sample_Interval)
        if Input.h1(iTrial) ~= Input.h4(iTrial)
            intersect_mid = intersect_gaussian(Input.h1(iTrial), parameters(1) * Input.h1(iTrial), ...
                                               Input.h4(iTrial), parameters(1) * Input.h4(iTrial));
            p_left(iTrial) = 0.5 * parameters(3) + (1 - parameters(3)) * ...
                p_left_func(Input.Sample_Interval(iTrial), parameters(1), parameters(2), x_max, x_resolution, intersect_mid);
        else
            % If h1 and h4 are equal
            p_left(iTrial) = 0.5;
        end
    end
end

%% log-likelihood of Bernoulli distribution
function [logLikelihoodValue] = logLikelihood_Of_BernouliDist_p_left_ts(Input, parameters)
    [p_left] = Pr_Left_ts(Input, parameters);
    left_choice = Input.Response; % 0:Right, 1:Left
    logLikelihoodValue = -sum(left_choice .* log(p_left + eps) + (1 - left_choice) .* log(1 - p_left + eps));
end

%% optimization
options = optimoptions('fmincon', 'Display', 'off');
StartPointInitializedValues = [0.2, 0, 0];
ub = [0.5, 1, 0.6];  % Upper bounds
lb = [0.05, -1, 0];  % Lower bounds

% Fit the model
[est_parameters] = fmincon(@(parameters) logLikelihood_Of_BernouliDist_p_left_ts(Input, parameters), ...
                           StartPointInitializedValues, [], [], [], [], lb, ub, [], options);

%% Interpolation for smooth psychometric curve
% Remove duplicates in Sample_Interval
[unique_Sample_Interval, unique_idx] = unique(Input.Sample_Interval, 'stable');
unique_h1 = Input.h1(unique_idx);
unique_h4 = Input.h4(unique_idx);

% Generate a grid of interpolated values
x_interp = linspace(min(unique_Sample_Interval), max(unique_Sample_Interval), 100); % 100 evenly spaced points
h1_interp = interp1(unique_Sample_Interval, unique_h1, x_interp, 'linear', 'extrap');
h4_interp = interp1(unique_Sample_Interval, unique_h4, x_interp, 'linear', 'extrap');

% Determine correct minus incorrect time differences
interp_time_diff = zeros(size(x_interp));
for i = 1:length(x_interp)
    % Check which arm (h1 or h4) is closer to Sample_Interval
    if h1_interp(i) == h4_interp(i)
        % Assign 0 if h1 and h4 are equal
        interp_time_diff(i) = 0;
    elseif abs(x_interp(i) - h1_interp(i)) < abs(x_interp(i) - h4_interp(i))
        interp_time_diff(i) = x_interp(i) - h4_interp(i); % h1 is correct
    else
        interp_time_diff(i) = x_interp(i) - h1_interp(i); % h4 is correct
    end
end

% Generate predictions for interpolated values
Input_interp = struct();
Input_interp.Sample_Interval = x_interp;
Input_interp.h1 = h1_interp;
Input_interp.h4 = h4_interp;

[Synthetic_p_left] = Pr_Left_ts(Input_interp, est_parameters);

end
