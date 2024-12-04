function [alt1, alt2, alt3, alt4, correct] = Joint_Model(h1, h2, h3, h4, h5, h6, One, Two, ntrials, scalar, truth_1, truth_2, truth_3, truth_4)

% Initialize output variables
alt1 = zeros(1, ntrials);
alt2 = zeros(1, ntrials);
alt3 = zeros(1, ntrials);
alt4 = zeros(1, ntrials);
correct = zeros(1, ntrials);

for i = 1:ntrials
    % Compute likelihoods for all alternatives
    alt1(i) = compute_likelihood(scalar, One(i), Two(i), h1(i), h2(i));
    alt2(i) = compute_likelihood(scalar, One(i), Two(i), h1(i), h3(i));
    alt3(i) = compute_likelihood(scalar, One(i), Two(i), h4(i), h5(i));
    alt4(i) = compute_likelihood(scalar, One(i), Two(i), h4(i), h6(i));

    % Resolve ties and assign the final outcome
    [alt1(i), alt2(i), alt3(i), alt4(i)] = resolve_ties([alt1(i), alt2(i), alt3(i), alt4(i)]);

    % Check correctness
    if isequal([alt1(i), alt2(i), alt3(i), alt4(i)], [truth_1(i), truth_2(i), truth_3(i), truth_4(i)])
        correct(i) = 1;
    end
end

end

% Helper function to compute the combined likelihood
function likelihood = compute_likelihood(scalar, One, Two, h_a, h_b)
    likelihood = D_likelihood(scalar, 0, One, h_a ) * D_likelihood(scalar, 0, Two, h_b );
end

% Helper function to resolve ties
function [alt1, alt2, alt3, alt4] = resolve_ties(alts)
    max_val = max(alts);
    num_ties = sum(alts == max_val);
    
    if num_ties > 1
        tie_idx = find(alts == max_val);
        choice = tie_idx(randi(length(tie_idx)));
        alts = zeros(size(alts));
        alts(choice) = 1;
    else
        alts = alts == max_val;
    end
    
    [alt1, alt2, alt3, alt4] = deal(alts(1), alts(2), alts(3), alts(4));
end
