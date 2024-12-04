function [Synthetic_p_left, est_parameters] = model_half_psychometric_gamma(Input)
%% psychometric function
function [p_left] = Pr_Left_ts(Input, parameters);
% parameter(1) => pWm,  parameter(2) => pBound
pdf_x = @(x, mu, sigma) ((1/sqrt(2*pi*(sigma^2))) .* exp(-((x - mu).^2) / (2*(sigma^2))) );
p_left_func = @(ts, pWm, x_max, x_resolution,mid) ( sum(pdf_x([mid:x_resolution:x_max], ts, pWm)).*x_resolution );
x_resolution = 0.001; x_max = 10;

    for iTrial = 1: length(Input.Sample_Interval)
               p_left(iTrial) = 0.5*parameters(2) + (1-parameters(2))*p_left_func(abs(Input.h1(iTrial)-Input.h4(iTrial)), parameters(1), x_max,  x_resolution, 0);
%                p_left(iTrial) = 0.5*parameters(2) + (1-parameters(2))*p_left_func(abs(Input.h1(iTrial)-Input.h4(iTrial)), sqrt(parameters(1)^2 * (Input.h1(iTrial)^2 + Input.h4(iTrial)^2)), x_max,  x_resolution, 0);

     end
    
end

%% log-likelihood of Bernouli distribution
function [logLikelihoodValue] = logLikelihood_Of_BernouliDist_p_left_ts(Input, parameters);
% Model parameters
[p_left] = Pr_Left_ts(Input, parameters)';

left_choice = Input.Response; % 0:Right, 1: Left


% logLikelihoodValue = sqrt(sum((RT(find(TF==1)) - RT_Model(find(TF==1))).^2)/length(RT(find(TF==1)))) -sum(Anti.*log(p_Anti_td_C+0.0001) + (1-Anti).*log(1 - p_Anti_td_C+0.0001));
logLikelihoodValue = -sum(left_choice.*log(p_left+eps) + (1-left_choice).*log(1 - p_left+eps));
% logLikelihoodValue =  -sum(Anti.*log(p_Anti_td_C+0.0001) + (1-Anti).*log(1 - p_Anti_td_C+0.0001));
end

%% optimization

% Setting the initialized values of optimizer
% options = optimset('fminsearch');
% options.Display = 'iter';
% options.Iter = 1000000;
% options.TolFun = 1e-6;
% options.TolX = 1e-6;
options = optimoptions('fmincon','Display','off');
StartPointInitializedValues = [0.2, 0];
ub = [1, 0];
lb = [0.05, 0];
% fit the model
[est_parameters] = fmincon(@(parameters) logLikelihood_Of_BernouliDist_p_left_ts(Input, parameters), StartPointInitializedValues,[],[],[],[],lb,ub,[],options); %0.1, 0.01

% syntheric data:
% est_parameters = [0.05 0];
[Synthetic_p_left] = Pr_Left_ts(Input, est_parameters);



end

