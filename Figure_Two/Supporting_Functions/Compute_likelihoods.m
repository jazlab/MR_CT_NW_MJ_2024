function [sub_like_j, sub_like_p, sub_like_h, sub_like_c, sub_like_s, sub_like_m] = Compute_likelihoods(h1_hum_all,h2_hum_all,h3_hum_all,h4_hum_all,h5_hum_all,h6_hum_all,d1_hum_all,d2_hum_all,truth1_hum_all,truth2_hum_all,truth3_hum_all,truth4_hum_all, scalar)

sub_like_j = [];
sub_like_p = [];
sub_like_h = [];
sub_like_c = [];
sub_like_s = [];
sub_like_m = [];

for iters = 1:10

idx1 = cvpartition(length(h1_hum_all), "HoldOut", 0.5).test;

% split train/test
h1_hum_train = h1_hum_all(idx1);
h2_hum_train= h2_hum_all(idx1);
h3_hum_train = h3_hum_all(idx1);
h4_hum_train= h4_hum_all(idx1);
h5_hum_train = h5_hum_all(idx1);
h6_hum_train = h6_hum_all(idx1);
d1_hum_train = d1_hum_all(idx1);
d2_hum_train = d2_hum_all(idx1);
truth1_hum_train = truth1_hum_all(idx1);
truth2_hum_train = truth2_hum_all(idx1);
truth3_hum_train = truth3_hum_all(idx1);
truth4_hum_train = truth4_hum_all(idx1);



h1_hum_test = h1_hum_all(~idx1);
h2_hum_test= h2_hum_all(~idx1);
h3_hum_test = h3_hum_all(~idx1);
h4_hum_test= h4_hum_all(~idx1);
h5_hum_test = h5_hum_all(~idx1);
h6_hum_test = h6_hum_all(~idx1);
d1_hum_test = d1_hum_all(~idx1);
d2_hum_test = d2_hum_all(~idx1);
truth1_hum_test = truth1_hum_all(~idx1);
truth2_hum_test = truth2_hum_all(~idx1);
truth3_hum_test = truth3_hum_all(~idx1);
truth4_hum_test = truth4_hum_all(~idx1);

%% fit and compute negative log likelihoods

ntrials = 10000;  % Number of iterations/samples
num_trials = length(h1_hum_test); % Number of trials per iteration
min_t = eps;


% Initialize arrays to store counts for each alternative across all iterations (ntrials)

counts_hierarchical = zeros(num_trials, 4);
counts_joint = zeros(num_trials, 4);
counts_postdictive = zeros(num_trials, 4);
counts_sequential = zeros(num_trials, 4);


% Open parallel pool if it's not already open
if isempty(gcp('nocreate'))
    parpool;
end

parfor i = 1:ntrials

    % Generate the structure for each iteration (i.e., for each set of trials)
    [h1, h2, h3, h4, h5, h6, d1, d2, One, Two, truet1, truet2, truth_1, truth_2, truth_3, truth_4, One_noise, Two_noise, Total_noise] = ...
        generate_structure_off_noise_likelihood(min_t, scalar, 1, h1_hum_test, h2_hum_test, h3_hum_test, h4_hum_test, h5_hum_test, h6_hum_test, d1_hum_test, d2_hum_test);
    
    % Repeat for Hierarchical, Joint, Postdictive, Sequential models
    % Hierarchical model
    [alt1_h, alt2_h, alt3_h, alt4_h, correct_h] = Hierarchical_Model(h1, h2, h3, h4, h5, h6, One, Two, num_trials, scalar, truth_1, truth_2, truth_3, truth_4);
    counts_hierarchical = counts_hierarchical + [alt1_h', alt2_h', alt3_h', alt4_h'];
    
    % Joint model
    [alt1_j, alt2_j, alt3_j, alt4_j, correct_j] = Joint_Model(h1, h2, h3, h4, h5, h6, One, Two, num_trials, scalar, truth_1, truth_2, truth_3, truth_4);
    counts_joint = counts_joint + [alt1_j', alt2_j', alt3_j', alt4_j'];
    
    % Postdictive model
    [alt1_p, alt2_p, alt3_p, alt4_p, correct_p] = Postdictive_Model(h1, h2, h3, h4, h5, h6, One, Two, num_trials, scalar, truth_1, truth_2, truth_3, truth_4);
    counts_postdictive = counts_postdictive + [alt1_p', alt2_p', alt3_p', alt4_p'];
    
    % Sequential model
    [alt1_s, alt2_s, alt3_s, alt4_s, correct_s] = Sequential_Model(h1, h2, h3, h4, h5, h6, One, Two, num_trials, scalar, truth_1, truth_2, truth_3, truth_4);
    counts_sequential = counts_sequential + [alt1_s', alt2_s', alt3_s', alt4_s'];
end

% Compute the probabilities for each alternative by dividing by the number of iterations (ntrials)

prob_hierarchical = counts_hierarchical / ntrials;
prob_joint = counts_joint / ntrials;
prob_postdictive = counts_postdictive / ntrials;
prob_sequential = counts_sequential / ntrials;


% Assuming you already have probabilities computed for each model
% and truth variables (truth1_hum_test, truth2_hum_test, etc.)

% Initialize arrays to store the NLL for each model

nll_hierarchical = 0;
nll_joint = 0;
nll_postdictive = 0;
nll_sequential = 0;

% Loop through each trial
for trial = 1:num_trials
    % Get the subject's response (which of truth1...truth4 is 1 for this trial)
    truth = [truth1_hum_test(trial), truth2_hum_test(trial), truth3_hum_test(trial), truth4_hum_test(trial)];

    % For the Hierarchical model
    prob_h = prob_hierarchical(trial, :);  
    chosen_prob_h = prob_h(logical(truth));  
    nll_hierarchical = nll_hierarchical - log(chosen_prob_h + eps);

    % For the Joint model
    prob_j = prob_joint(trial, :);  
    chosen_prob_j = prob_j(logical(truth));  
    nll_joint = nll_joint - log(chosen_prob_j + eps);

    % For the Postdictive model
    prob_p = prob_postdictive(trial, :);  
    chosen_prob_p = prob_p(logical(truth));  
    nll_postdictive = nll_postdictive - log(chosen_prob_p + eps);

    % For the Sequential model
    prob_s = prob_sequential(trial, :);  
    chosen_prob_s = prob_s(logical(truth));  
    nll_sequential = nll_sequential - log(chosen_prob_s + eps);
end

% disp('Negative Log Likelihood for Hierarchical Model:');
% disp(nll_hierarchical);
% 
% disp('Negative Log Likelihood for Joint Model:');
% disp(nll_joint);
% 
% disp('Negative Log Likelihood for Postdictive Model:');
% disp(nll_postdictive);
% 
% disp('Negative Log Likelihood for Sequential Model:');
% disp(nll_sequential);


% Define the initial guesses for the parameters [off, thresh1]
options = optimoptions('fmincon','Display','off');
StartPointInitializedValues = [1, 0];
ub = [inf  inf];
lb = [1 0];

% Run fminsearch to minimize the NLL
best_params = fmincon(@(params) compute_nll_counterfactual(params, h1_hum_train, h2_hum_train, h3_hum_train, h4_hum_train, h5_hum_train, h6_hum_train, d1_hum_train, d2_hum_train, truth1_hum_train, truth2_hum_train, truth3_hum_train, truth4_hum_train, scalar, ntrials), StartPointInitializedValues,[],[],[],[],lb,ub,[],options);

% % Display the optimal values of the parameters
% disp('Optimized off and thresh1 values:');
% disp(best_params);

nll_counterfactual = compute_nll_counterfactual(best_params, h1_hum_test, h2_hum_test, h3_hum_test, h4_hum_test, h5_hum_test, h6_hum_test, d1_hum_test, d2_hum_test, truth1_hum_test, truth2_hum_test, truth3_hum_test, truth4_hum_test, scalar, ntrials);

% % Display the Negative Log Likelihoods
% disp('Negative Log Likelihood for Counter Factual Model:');
% disp(nll_counterfactual);


% Define the initial guess for the threshold parameter
initial_threshold = 0;  % Initial guess for threshold
options = optimoptions('fmincon', 'Display', 'off');

% Set bounds for the threshold
lb = 0;  % Lower bound for threshold (it must be non-negative)
ub = inf;  % No upper bound for threshold

% Run fmincon to minimize the NLL for the mixed strategy model
best_threshold = fmincon(@(threshold) compute_nll_mixed_strategy(threshold, h1_hum_train, h2_hum_train, h3_hum_train, h4_hum_train, h5_hum_train, h6_hum_train, d1_hum_train, d2_hum_train, truth1_hum_train, truth2_hum_train, truth3_hum_train, truth4_hum_train, scalar, ntrials), ...
                         initial_threshold, [], [], [], [], lb, ub, [], options);

% Compute NLL on test data using the optimized threshold value
nll_mixed_strategy = compute_nll_mixed_strategy(best_threshold, h1_hum_test, h2_hum_test, h3_hum_test, h4_hum_test, h5_hum_test, h6_hum_test, d1_hum_test, d2_hum_test, truth1_hum_test, truth2_hum_test, truth3_hum_test, truth4_hum_test, scalar, ntrials);


sub_like_j = vertcat(sub_like_j,nll_joint);
sub_like_p = vertcat(sub_like_p,nll_postdictive);
sub_like_h = vertcat(sub_like_h,nll_hierarchical);
sub_like_s = vertcat(sub_like_s,nll_sequential);
sub_like_c = vertcat(sub_like_c,nll_counterfactual);
sub_like_m = vertcat(sub_like_m,nll_mixed_strategy);


end


end


function nll = compute_nll_counterfactual(params, h1_hum_train, h2_hum_train, h3_hum_train, h4_hum_train, h5_hum_train, h6_hum_train, d1_hum_train, d2_hum_train, truth1_hum_train, truth2_hum_train, truth3_hum_train, truth4_hum_train, scalar, ntrials)

    % Extract the parameters
    off = params(1);
    thresh1 = params(2);
    
    num_trials = length(h1_hum_train);  % Number of trials per iteration

    % Initialize counts for the Counterfactual model (each trial, each alternative)
    counts_counter_factual = zeros(num_trials, 4);

    % Use parfor to parallelize the iteration over ntrials
    parfor i = 1:ntrials
        % Generate structure for each iteration (trials)
        [h1, h2, h3, h4, h5, h6, d1, d2, One, Two, truet1, truet2, truth_1, truth_2, truth_3, truth_4, One_noise, Two_noise, Total_noise] = ...
            generate_structure_off_noise_likelihood(eps, scalar, off, h1_hum_train, h2_hum_train, h3_hum_train, h4_hum_train, h5_hum_train, h6_hum_train, d1_hum_train, d2_hum_train);

        % Run the Counterfactual model for all trials in this iteration
        [alt1_c, alt2_c, alt3_c, alt4_c, correct_c] = Counter_Factual_Model(h1, h2, h3, h4, h5, h6, One, Two, num_trials, thresh1, scalar, truth_1, truth_2, truth_3, truth_4, off, One_noise, Two_noise, 1);

        % Accumulate the results (parallel-friendly)
        counts_counter_factual = counts_counter_factual + [alt1_c', alt2_c', alt3_c', alt4_c'];
    end

    % Compute the probabilities by dividing by the number of iterations (ntrials)
    prob_counter_factual = counts_counter_factual / ntrials;

    % Initialize the NLL for the Counterfactual model
    nll = 0;

    % Loop through each trial to compute the NLL
    for trial = 1:num_trials
        % Get the subject's response (which of truth1...truth4 is 1 for this trial)
        truth = [truth1_hum_train(trial), truth2_hum_train(trial), truth3_hum_train(trial), truth4_hum_train(trial)];

        % Get the probabilities for this trial
        prob_c = prob_counter_factual(trial, :);  

        % Get the probability of the chosen option
        chosen_prob_c = prob_c(logical(truth));   

        % Add the log-likelihood to the NLL
        nll = nll - log(chosen_prob_c + eps);  
    end
end


function nll = compute_nll_mixed_strategy(params, h1_hum_train, h2_hum_train, h3_hum_train, h4_hum_train, h5_hum_train, h6_hum_train, d1_hum_train, d2_hum_train, truth1_hum_train, truth2_hum_train, truth3_hum_train, truth4_hum_train, scalar, ntrials)

    % Extract the threshold parameter
    threshold = params(1);
    
    num_trials = length(h1_hum_train);  % Number of trials per iteration

    % Initialize counts for the Mixed Strategy model (each trial, each alternative)
    counts_mixed_strategy = zeros(num_trials, 4);

    % Use parfor to parallelize the iteration over ntrials
    parfor i = 1:ntrials
        % Generate structure for each iteration (trials)
        [h1, h2, h3, h4, h5, h6, d1, d2, One, Two, truet1, truet2, truth_1, truth_2, truth_3, truth_4, One_noise, Two_noise, Total_noise] = ...
            generate_structure_off_noise_likelihood(eps, scalar, 1, h1_hum_train, h2_hum_train, h3_hum_train, h4_hum_train, h5_hum_train, h6_hum_train, d1_hum_train, d2_hum_train);

        % Run the Mixed Strategy model for all trials in this iteration
        [alt1_m, alt2_m, alt3_m, alt4_m, correct_m] = Mixed_Strategy_Model(h1, h2, h3, h4, h5, h6, One, Two, num_trials, scalar, truth_1, truth_2, truth_3, truth_4, threshold);

        % Accumulate the results (parallel-friendly)
        counts_mixed_strategy = counts_mixed_strategy + [alt1_m', alt2_m', alt3_m', alt4_m'];
    end

    % Compute the probabilities by dividing by the number of iterations (ntrials)
    prob_mixed_strategy = counts_mixed_strategy / ntrials;

    % Initialize the NLL for the Mixed Strategy model
    nll = 0;

    % Loop through each trial to compute the NLL
    for trial = 1:num_trials
        % Get the subject's response (which of truth1...truth4 is 1 for this trial)
        truth = [truth1_hum_train(trial), truth2_hum_train(trial), truth3_hum_train(trial), truth4_hum_train(trial)];

        % Get the probabilities for this trial
        prob_m = prob_mixed_strategy(trial, :);  

        % Get the probability of the chosen option
        chosen_prob_m = prob_m(logical(truth));   

        % Add the log-likelihood to the NLL
        nll = nll - log(chosen_prob_m + eps);  
    end
end
