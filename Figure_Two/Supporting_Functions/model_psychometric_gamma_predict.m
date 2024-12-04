function Synthetic_p_left = model_psychometric_gamma_predict(parameters, Sample_Interval)
    % Inputs:
    % parameters: Fitted parameters [pWm, pBound, lapse]
    % Sample_Interval: Array of interpolated sample intervals (e.g., x_interp)

    % Unpack parameters
    pWm = parameters(1);       % Width of sensory noise
    pBound = parameters(2);    % Decision boundary
    lapse = parameters(3);     % Lapse rate

    % Define the PDF function
    pdf_x = @(x, mu, sigma) ((1 / sqrt(2 * pi * sigma^2)) .* exp(-((x - mu).^2) / (2 * sigma^2)));

    % Define the probability of choosing left
    p_left_func = @(ts, pWm, pBound, x_max, x_resolution, mid) ...
        sum(pdf_x([(mid + pBound):x_resolution:x_max], ts, pWm .* ts)) .* x_resolution;

    % Define parameters for the computation
    x_resolution = 0.01; 
    x_max = 5;

    % Midpoint for the psychometric curve
    mid = 0; % Assume a symmetric psychometric function

    % Initialize the synthetic probabilities
    Synthetic_p_left = zeros(size(Sample_Interval));

    % Compute probabilities for each interpolated Sample_Interval
    for i = 1:length(Sample_Interval)
        Synthetic_p_left(i) = 0.5 * lapse + (1 - lapse) * ...
            p_left_func(Sample_Interval(i), pWm, pBound, x_max, x_resolution, mid);
    end
end
