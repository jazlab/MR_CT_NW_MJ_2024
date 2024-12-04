function [alt1_h, alt2_h, alt3_h, alt4_h, correct] = Hierarchical_Model(h1, h2, h3, h4, h5, h6,One, Two, ntrials, scalar, truth_1, truth_2, truth_3, truth_4)

% Initialize output variables
alt1_h = zeros(1, ntrials);
alt2_h = zeros(1, ntrials);
alt3_h = zeros(1, ntrials);
alt4_h = zeros(1, ntrials);
correct = zeros(1, ntrials);

for i = 1:ntrials
    % Compute likelihoods for h1 vs h4
    [i_h1, i_h2] = compute_likelihoods(h1(i), h4(i), One(i), scalar);
    
    % Likelihood comparison
    if i_h1 > i_h2
        % Case where i_h1 is higher, evaluate alt1 and alt2
        [alt1_h(i), alt2_h(i)] = evaluate_alts(h2(i), h3(i), Two(i), scalar);
        [alt3_h(i), alt4_h(i)] = deal(0, 0);
    else
        % Case where i_h2 is higher, evaluate alt3 and alt4
        [alt3_h(i), alt4_h(i)] = evaluate_alts(h5(i), h6(i), Two(i), scalar);
        [alt1_h(i), alt2_h(i)] = deal(0, 0);
    end

    % Resolve ties and assign the final outcome
    [alt1_h(i), alt2_h(i), alt3_h(i), alt4_h(i)] = resolve_ties([alt1_h(i), alt2_h(i), alt3_h(i), alt4_h(i)]);

    % Check correctness
    if isequal([alt1_h(i), alt2_h(i), alt3_h(i), alt4_h(i)], [truth_1(i), truth_2(i), truth_3(i), truth_4(i)])
        correct(i) = 1;
    end
end

end

% Helper function to compute likelihoods for two values
function [i_h1, i_h2] = compute_likelihoods(h1, h4, One,  scalar)
    i_h1 = D_likelihood(scalar, 0, One, h1 );
    i_h2 = D_likelihood(scalar, 0, One, h4 );
    
    if h1 == h4
        % Add random noise to break ties
        if rand() >= 0.5
            i_h1 = 1;
            i_h2 = 0;
        else
            i_h1 = 0;
            i_h2 = 1;
        end
    end
end

% Helper function to evaluate alternative likelihoods
function [alt1, alt2] = evaluate_alts(h2, h3, Two,  scalar)
    alt1 = D_likelihood(scalar, 0, Two, h2 );
    alt2 = D_likelihood(scalar, 0, Two, h3 );
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
