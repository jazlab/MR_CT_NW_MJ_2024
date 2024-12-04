function [alt1_mixed, alt2_mixed, alt3_mixed, alt4_mixed, correct] = Mixed_Strategy_Model(h1, h2, h3, h4, h5, h6, One, Two, ntrials, scalar, truth_1, truth_2, truth_3, truth_4, threshold)

    % Initialize output variables
    alt1_mixed = zeros(1, ntrials);
    alt2_mixed = zeros(1, ntrials);
    alt3_mixed = zeros(1, ntrials);
    alt4_mixed = zeros(1, ntrials);
    correct = zeros(1, ntrials);

    for i = 1:ntrials
        % Compute likelihoods for the initial decision between h1 and h4
        [i_h1, i_h2] = compute_likelihoods(h1(i), h4(i), One(i), scalar);
        
        % Compute the log-likelihood ratio (LLR) as the evidence measure
        llr = log(i_h1 / (i_h2 + eps));
        
        if abs(llr) > threshold
            % **Hierarchical Model** - Commit to the initial decision
            if llr > 0
                % LLR > 0 favors h1
                [alt1_mixed(i), alt2_mixed(i)] = evaluate_alts(h2(i), h3(i), Two(i), scalar);
                [alt3_mixed(i), alt4_mixed(i)] = deal(0, 0);
            else
                % LLR < 0 favors h4
                [alt3_mixed(i), alt4_mixed(i)] = evaluate_alts(h5(i), h6(i), Two(i), scalar);
                [alt1_mixed(i), alt2_mixed(i)] = deal(0, 0);
            end
        else
            % **Sequential Model** - Use only second interval for the decision
            [alt1_mixed(i), alt2_mixed(i), alt3_mixed(i), alt4_mixed(i)] = sequential_decision(h2(i), h3(i), h5(i), h6(i), Two(i), scalar);
        end

        % Resolve ties and assign the final outcome
        [alt1_mixed(i), alt2_mixed(i), alt3_mixed(i), alt4_mixed(i)] = resolve_ties([alt1_mixed(i), alt2_mixed(i), alt3_mixed(i), alt4_mixed(i)]);

        % Check correctness
        if isequal([alt1_mixed(i), alt2_mixed(i), alt3_mixed(i), alt4_mixed(i)], [truth_1(i), truth_2(i), truth_3(i), truth_4(i)])
            correct(i) = 1;
        end
    end
end

% Helper function to compute likelihoods for two values (h1 vs h4)
function [i_h1, i_h2] = compute_likelihoods(h1, h4, One, scalar)
    i_h1 = D_likelihood(scalar, 0, One, h1);
    i_h2 = D_likelihood(scalar, 0, One, h4);
    
    if h1 == h4
        % Add small noise to break ties
        if rand() >= 0.5
            i_h1 = i_h1 + eps;
        else
            i_h2 = i_h2 + eps;
        end
    end
end

% Helper function to evaluate alternative likelihoods for the hierarchical strategy
function [alt1, alt2] = evaluate_alts(h2, h3, Two, scalar)
    alt1 = D_likelihood(scalar, 0, Two, h2);
    alt2 = D_likelihood(scalar, 0, Two, h3);
end

% Helper function for sequential decision using only second interval evidence
function [alt1, alt2, alt3, alt4] = sequential_decision(h2, h3, h5, h6, Two, scalar)
    alt1 = D_likelihood(scalar, 0, Two, h2);
    alt2 = D_likelihood(scalar, 0, Two, h3);
    alt3 = D_likelihood(scalar, 0, Two, h5);
    alt4 = D_likelihood(scalar, 0, Two, h6);
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
