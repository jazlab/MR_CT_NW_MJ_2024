function [alt1_h, alt2_h, alt3_h, alt4_h, correct, max_index] = Sequential_Model(h1, h2, h3, h4, h5, h6, One, Two, ntrials, scalar, truth_1, truth_2, truth_3, truth_4)

% Initialize output variables
alt1_h = zeros(1, ntrials);
alt2_h = zeros(1, ntrials);
alt3_h = zeros(1, ntrials);
alt4_h = zeros(1, ntrials);
correct = zeros(1, ntrials);
max_index = zeros(1, ntrials);

for i = 1:ntrials
    % Compute likelihoods for each exit point
    alt1_h(i) = D_likelihood(scalar, 0, Two(i), h2(i));
    alt2_h(i) = D_likelihood(scalar, 0, Two(i), h3(i));
    alt3_h(i) = D_likelihood(scalar, 0, Two(i), h5(i));
    alt4_h(i) = D_likelihood(scalar, 0, Two(i), h6(i));

    % Use randomMaxIndex to handle ties in maximum likelihoods
    max_index(i) = randomMaxIndex([alt1_h(i), alt2_h(i), alt3_h(i), alt4_h(i)]);

    % Set the correct alternative to 1 based on the max_index
    alt1_h(i) = (max_index(i) == 1);
    alt2_h(i) = (max_index(i) == 2);
    alt3_h(i) = (max_index(i) == 3);
    alt4_h(i) = (max_index(i) == 4);

    % Check correctness by comparing the selected alternatives with the truth values
    if isequal([alt1_h(i), alt2_h(i), alt3_h(i), alt4_h(i)], [truth_1(i), truth_2(i), truth_3(i), truth_4(i)])
        correct(i) = 1;
    end
end

end

% Helper function to find the index of the maximum value, with random selection for ties
function idx = randomMaxIndex(alts)
    max_val = max(alts);
    max_indices = find(alts == max_val);
    
    if length(max_indices) > 1
        % If there are ties, select one index randomly
        idx = max_indices(randi(length(max_indices)));
    else
        idx = max_indices; % Single max value, return the index
    end
end
