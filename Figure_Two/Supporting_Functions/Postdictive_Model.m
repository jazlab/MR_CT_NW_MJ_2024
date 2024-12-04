function [alt1_c, alt2_c, alt3_c, alt4_c, correct] = Postdictive_Model(h1, h2, h3, h4, h5, h6, One, Two, ntrials, scalar, truth_1, truth_2, truth_3, truth_4)

% Initialize output variables
alt1_c = zeros(1, ntrials);
alt2_c = zeros(1, ntrials);
alt3_c = zeros(1, ntrials);
alt4_c = zeros(1, ntrials);
correct = zeros(1, ntrials);

for i = 1:ntrials
    % Compute likelihoods for h1 vs h4
    [i_h1, i_h2] = compute_likelihoods(h1(i), h4(i), One(i), scalar);
    
    % Compute alternatives for all possible exits
    [alt1_c(i), alt2_c(i), alt3_c(i), alt4_c(i)] = compute_alternatives(h2(i), h3(i), h5(i), h6(i), Two(i), scalar);

    % Compare the products of likelihoods for i_h1 and i_h2
    if i_h1 * (alt1_c(i) + alt2_c(i)) > i_h2 * (alt3_c(i) + alt4_c(i))
        % Set the third and fourth alternatives to zero
        [alt3_c(i), alt4_c(i)] = deal(0, 0);
    else
        % Set the first and second alternatives to zero
        [alt1_c(i), alt2_c(i)] = deal(0, 0);
    end

    % Resolve ties and assign the final outcome
    [alt1_c(i), alt2_c(i), alt3_c(i), alt4_c(i)] = resolve_ties([alt1_c(i), alt2_c(i), alt3_c(i), alt4_c(i)]);

    % Check correctness
    if isequal([alt1_c(i), alt2_c(i), alt3_c(i), alt4_c(i)], [truth_1(i), truth_2(i), truth_3(i), truth_4(i)])
        correct(i) = 1;
    end
end

end

% Helper function to compute likelihoods for h1 and h4
function [i_h1, i_h2] = compute_likelihoods(h1, h4, One, scalar)
    i_h1 = D_likelihood(scalar, 0, One, h1 );
    i_h2 = D_likelihood(scalar, 0, One, h4 );
    
    if h1 == h4
        % Add small noise to break ties
        if rand() >= 0.5
            i_h1 = i_h1 + eps;
        else
            i_h2 = i_h2 + eps;
        end
    end
end

% Helper function to compute alternatives for all exits
function [alt1, alt2, alt3, alt4] = compute_alternatives(h2, h3, h5, h6, Two, scalar)
    alt1 = D_likelihood(scalar, 0, Two, h2 );
    alt2 = D_likelihood(scalar, 0, Two, h3 );
    alt3 = D_likelihood(scalar, 0, Two, h5 );
    alt4 = D_likelihood(scalar, 0, Two, h6 );
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
