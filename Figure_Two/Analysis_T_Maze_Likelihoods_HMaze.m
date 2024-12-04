clear all; clc; close all;

% adjust to your local path
addpath(genpath('/Volumes/Portable/Human_RNN/Paper_Code/Figure_Two/'));


dr = rgb('deep red');
pin = rgb('salmon');

db = rgb('blue');
xc = rgb('cyan');

store_subject_id = [];
store_wm = [];
store_lapse = [];

% This script fits a psychometric model to data. To start, we need a to keep track of a
% couple variables:

% correct_minus_incorrect - a variable that keeps track of the time
% difference between the correct and incorrect answers ( time units)

% correct_short - a variable that indicates whether the shorter of the two
% arms was chosen correctly.

% occ_t - a variable that keps track of the sample interval of the correct
% choice

% arm_1 - the length of the left arm in time

% arm_2 - the length of the right arm in time

all_data_t_maze_v1 = readtable('t-h-maze.csv');
all_subject_ids = unique(all_data_t_maze_v1.subject_id);


%%%%%%%%% LOAD DATA FOR T_MAZE V1 %%%%%%%%%%%%%%%%%%%%%

pattern = '\[([-+]?\d+(\.\d+)?|\.\d+),([-+]?\d+(\.\d+)?|\.\d+)';

pixels_per_sec = 150;

% figure()
% 
% xlabel('Correct Minus Incorrect Time Difference');
% ylabel('Percentage of Left Choices');
% title('Psychometric Curve');

for sub = 1:length(all_subject_ids)
    
    current_sub_id = all_subject_ids(sub);
    current_t_maze_data = all_data_t_maze_v1( (all_data_t_maze_v1.subject_id ==  current_sub_id) & strcmp(all_data_t_maze_v1.task, 'TMaze')  ,:);
    
    correct = [];
    incorrect = [];
    arm_1 = [];
    arm_2 = [];
    correct_short = [];
    correct_answer = [];

    for i = 1:length(current_t_maze_data.Var1)

        match = regexp(current_t_maze_data.condition{i}, pattern, 'tokens', 'once');
        arm_1 = vertcat(arm_1, str2double(match{1})/pixels_per_sec);
        arm_2 = vertcat(arm_2, str2double(match{2})/pixels_per_sec);
        
        if strcmp(current_t_maze_data.target(i), 'L')
           
            correct_answer  = vertcat(correct_answer , strcmp(current_t_maze_data.response(i),'f'));

            if ~isempty(match)
                % Convert the matched string to a number and store it
                correct = vertcat(correct, str2double(match{1})/pixels_per_sec);
                incorrect = vertcat(incorrect, str2double(match{2})/pixels_per_sec);
                
            end


            if str2double(match{1})/pixels_per_sec  < str2double(match{2})/pixels_per_sec

                correct_short = horzcat(correct_short, strcmp(current_t_maze_data.response(i),'f'));

            else

                correct_short = horzcat(correct_short, 1- strcmp(current_t_maze_data.response(i),'f'));

            end
     
        elseif strcmp(current_t_maze_data.target(i), 'R')
            
            correct_answer  = vertcat(correct_answer , strcmp(current_t_maze_data.response(i),'j'));

            if ~isempty(match)
                % Convert the matched string to a number and store it
                correct = vertcat(correct, str2double(match{2})/pixels_per_sec);
                incorrect = vertcat(incorrect, str2double(match{1})/pixels_per_sec);

            end

            
            if str2double(match{2})/pixels_per_sec < str2double(match{1})/pixels_per_sec 

                correct_short = horzcat(correct_short, strcmp(current_t_maze_data.response(i),'j'));

            else

                correct_short = horzcat(correct_short, 1- strcmp(current_t_maze_data.response(i),'j'));

            end

        end
        



    end
    

correct_minus_incorrect = correct-incorrect;
un_dif = unique(correct_minus_incorrect);

%%%%%%%%%% Fit Psychometric Curve %%%%%%%%%%%%%%%%%

Input.Response = ~correct_short;
Input.Sample_Interval = correct;
Input.h1 = arm_1;
Input.h4 = arm_2;

% Fit the psychometric model and get interpolated predictions
[Synthetic_p_left, est_parameters, interp_time_diff] = model_psychometric_gamma(Input);


% Plot Psychometric Curves
% if est_parameters(1) < 0.4 & est_parameters(3) < 0.5
% 
%     % Generate a random color for the current condition
%     randomColor = rand(1, 3); % Generate a random RGB triplet
% 
%     for u = 1:length(un_dif)
%         scatter( un_dif(u), (1- mean(correct_short(correct_minus_incorrect == un_dif(u))))*100, 50,'filled', 'MarkerFaceColor', randomColor , 'MarkerFaceAlpha', 0.25);
%         ylim([0 100])
%         hold on
%     end
%     
%     hold on
%     % [g, id] = findgroups (correct_minus_incorrect );
%     % scatter(unique(correct_minus_incorrect) , 100*splitapply(@mean, Synthetic_p_left', g), 100, pin, 'filled', 'MarkerEdgeColor','k');
%     
%     % Plot smooth psychometric curve
%     plot(interp_time_diff, 100 * Synthetic_p_left, '-', 'LineWidth', 2, 'Color',[randomColor, 0.25]);
% 
% end

store_subject_id = vertcat(store_subject_id, current_sub_id);
store_wm = vertcat(store_wm, est_parameters(1));
store_lapse = vertcat(store_lapse, est_parameters(3));

end

% % Extract the relevant data
data = store_wm(store_wm < 0.4 & store_lapse < 0.5);

% Kernel density 

% Create a figure
figure;

% Perform kernel density estimation for a smooth distribution
[f, xi] = ksdensity(data);

% Scale down the density values
scaling_factor = 0.3; % Adjust this factor to control the amplitude
f_scaled = f * scaling_factor;

% Plot the scaled KDE as a smooth histogram
plot(f_scaled, xi, 'LineWidth', 2, 'Color', [0 0.447 0.741]); % KDE plot along y-axis
hold on;

% Plot the scatter points along the y-axis
scatter(rand(size(data)) * 0.2 - 0.1, data, 30, 'filled', 'MarkerFaceAlpha', 0.5);

% Customize the plot
xlabel('Scaled Density');
ylabel('WM Values');
title('Scatter Plot with Scaled Smooth Histogram Overlay');
ylim([min(data) - 0.05, max(data) + 0.05]); % Adjust y-limits for better visualization
xlim([-0.2, max(f_scaled) + 0.1]); % Adjust x-limits to fit scaled KDE and points
grid on;
hold off;


% Plot fitted Wms

% Box plot 
figure()
boxplot(data)
ylim([0 0.5])
hold on

% Overlay individual data points
for i = 1:size(data, 2) % Loop through each group (column in data)
    jitter = (rand(size(data(:, i))) - 0.5) * 0.02; % Add slight jitter for visibility
    scatter(repmat(i, size(data, 1), 1) + jitter, data(:, i), 'filled', 'MarkerFaceAlpha', 0.5);
end

%%

%%%%%%%%% Analyze H-Maze Likelihood %%%%%%%%%%%%%%%%%%%%%

Like_J_All = [];
Like_P_All = [];
Like_H_All = [];
Like_S_All = [];
Like_C_All = [];
Like_M_All = [];

WM_ALL = [];

sub_performance = [];
model_performance = [];
for sub = 1:length(store_subject_id )
    if store_wm(sub) < 0.4 & store_lapse < 0.5
        sub
        WM_ALL = vertcat(WM_ALL, store_wm(sub));
        current_sub_id = store_subject_id(sub);
        current_H_maze_data = all_data_t_maze_v1( (all_data_t_maze_v1.subject_id ==  current_sub_id) & strcmp(all_data_t_maze_v1.task, 'HMaze') ,:);

    
    num_array_H_maze_data = cellfun(@(x) str2num(x), current_H_maze_data.condition, 'UniformOutput', false);
    h1_hum_all= cellfun(@(x) x(1), num_array_H_maze_data)./pixels_per_sec;
    h2_hum_all= cellfun(@(x) x(3), num_array_H_maze_data)./pixels_per_sec;
    h3_hum_all = cellfun(@(x) x(4), num_array_H_maze_data)./pixels_per_sec;
    h4_hum_all = cellfun(@(x) x(2), num_array_H_maze_data)./pixels_per_sec;
    h5_hum_all = cellfun(@(x) x(5), num_array_H_maze_data)./pixels_per_sec;
    h6_hum_all = cellfun(@(x) x(6), num_array_H_maze_data)./pixels_per_sec;
    
    d1_hum_all = [];
    d2_hum_all = [];
    truth1_hum_all = [];
    truth2_hum_all = [];
    truth3_hum_all = [];
    truth4_hum_all = [];
  
    num_array_H_maze_direction = current_H_maze_data.target;
    num_array_H_maze_answer = current_H_maze_data.response;

    for i = 1:length(num_array_H_maze_direction)
        
        if strcmp(num_array_H_maze_direction{i}, 'LU')
            d1_hum_all = vertcat(d1_hum_all, -1);
            d2_hum_all = vertcat(d2_hum_all, 1);
        elseif strcmp(num_array_H_maze_direction{i}, 'LD')
            d1_hum_all = vertcat(d1_hum_all, -1);
            d2_hum_all = vertcat(d2_hum_all, -1);
        elseif strcmp(num_array_H_maze_direction{i}, 'RU')
            d1_hum_all = vertcat(d1_hum_all, 1);
            d2_hum_all = vertcat(d2_hum_all, 1);
        elseif strcmp(num_array_H_maze_direction{i}, 'RD')
            d1_hum_all = vertcat(d1_hum_all, 1);
            d2_hum_all = vertcat(d2_hum_all, -1);
        end
        
        if strcmp(num_array_H_maze_answer{i}, 'q')
            truth1_hum_all = vertcat(truth1_hum_all, 1);
            truth2_hum_all = vertcat(truth2_hum_all, 0);
            truth3_hum_all = vertcat(truth3_hum_all, 0);
            truth4_hum_all = vertcat(truth4_hum_all, 0);

        elseif strcmp(num_array_H_maze_answer{i}, 'z')
            truth1_hum_all = vertcat(truth1_hum_all, 0);
            truth2_hum_all = vertcat(truth2_hum_all, 1);
            truth3_hum_all = vertcat(truth3_hum_all, 0);
            truth4_hum_all = vertcat(truth4_hum_all, 0);

        elseif strcmp(num_array_H_maze_answer{i}, 'p')
            truth1_hum_all = vertcat(truth1_hum_all, 0);
            truth2_hum_all = vertcat(truth2_hum_all, 0);
            truth3_hum_all = vertcat(truth3_hum_all, 1);
            truth4_hum_all = vertcat(truth4_hum_all, 0);

        elseif strcmp(num_array_H_maze_answer{i}, 'm')
            truth1_hum_all = vertcat(truth1_hum_all, 0);
            truth2_hum_all = vertcat(truth2_hum_all, 0);
            truth3_hum_all = vertcat(truth3_hum_all, 0);
            truth4_hum_all = vertcat(truth4_hum_all, 1);
        end

    end

[sub_like_j, sub_like_p, sub_like_h, sub_like_c, sub_like_s, sub_like_m] = Compute_likelihoods(h1_hum_all,h2_hum_all,h3_hum_all,h4_hum_all,h5_hum_all,h6_hum_all,d1_hum_all,d2_hum_all,truth1_hum_all,truth2_hum_all,truth3_hum_all,truth4_hum_all, store_wm(sub));


Like_J_All = horzcat(Like_J_All, sub_like_j);
Like_P_All = horzcat(Like_P_All, sub_like_p);
Like_H_All = horzcat(Like_H_All, sub_like_h);
Like_S_All = horzcat(Like_S_All, sub_like_s);
Like_C_All = horzcat(Like_C_All, sub_like_c);
Like_M_All = horzcat(Like_M_All, sub_like_m);

    end
end

H_MAZE_LIKE_ALL = struct;
H_MAZE_LIKE_ALL.J = Like_J_All;
H_MAZE_LIKE_ALL.P = Like_P_All;
H_MAZE_LIKE_ALL.H = Like_H_All;
H_MAZE_LIKE_ALL.S = Like_S_All;
H_MAZE_LIKE_ALL.C = Like_C_All;
H_MAZE_LIKE_ALL.M = Like_M_All;

save('/Volumes/Portable/Human_RNN/Online_Likelihoods/H_maze_like_all.mat', 'H_MAZE_LIKE_ALL')
