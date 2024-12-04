clear all; clc; close all;
addpath(genpath('/Users/mahdiramadan/Documents/Matlab Add-Ons/'));
 
dr = rgb('deep red');
pin = rgb('salmon');

db = rgb('blue');
xc = rgb('cyan');

%%
%%%%%%%%% Analyze V2 %%%%%%%%%%%%%%%%%%%%%

% load and pre-process data
all_data_t_maze_v1 = readtable('v2-v3-maze.csv');
all_subject_ids = unique(all_data_t_maze_v1.subject_id);

sub_performance_online = [];
sub_performance_offline = [];

pixels_per_sec = 150;

wm_all_offline= [];
wm_all_online = [];

bias_all_offline =[];
bias_all_online =[];

lapse_all_offline =[];
lapse_all_online =[];

% Initialize arrays to store mean performances
mean_performance_hidden_all = zeros(length(all_subject_ids ), 5);
mean_performance_visible_all = zeros(length(all_subject_ids ), 5);

% figure();

for sub = 1:length(all_subject_ids )

    current_sub_id = all_subject_ids(sub);
    current_H_maze_data = all_data_t_maze_v1( (all_data_t_maze_v1.subject_id ==  current_sub_id) & strcmp(all_data_t_maze_v1.task, 'V2') ,:);
  
    num_array_H_maze_data = cellfun(@(x) str2num(x), current_H_maze_data.condition, 'UniformOutput', false);

    h2_hum_all= cellfun(@(x) x(2), num_array_H_maze_data)./pixels_per_sec;
    h3_hum_all = cellfun(@(x) x(3), num_array_H_maze_data)./pixels_per_sec;
    uniq_dif = abs(h2_hum_all-h3_hum_all);

    num_array_H_maze_direction = current_H_maze_data.target;
    num_array_H_maze_answer = current_H_maze_data.response;

    hidden_boolean = current_H_maze_data.hidden_first;

    correct = [];
    correct_interval = [];
    incorrect_interval = [];
    chose_long = [];
    short_long_correct = [];

    for i = 1:length(num_array_H_maze_direction)
        
        if strcmp(num_array_H_maze_direction{i}, 'LU')

            correct_interval = vertcat(correct_interval, h2_hum_all(i));
            incorrect_interval = vertcat(incorrect_interval, h3_hum_all(i));
            
            if h2_hum_all(i) <= h3_hum_all(i) 
                chose_long = horzcat(chose_long, 0 );
            else
                chose_long = horzcat(chose_long, 1 );
            end

            if strcmp(num_array_H_maze_answer{i}, 'q')
                correct = vertcat(correct, 1);
            else
                correct = vertcat(correct, 0);
            end

        elseif strcmp(num_array_H_maze_direction{i}, 'LD')

            correct_interval = vertcat(correct_interval, h3_hum_all(i));
            incorrect_interval = vertcat(incorrect_interval, h2_hum_all(i));
            
            if h3_hum_all(i) <= h2_hum_all(i) 
                chose_long = horzcat(chose_long, 0 );
            else
                chose_long = horzcat(chose_long, 1);
            end

            if strcmp(num_array_H_maze_answer{i}, 'z')
                correct = vertcat(correct, 1);
            else
                correct = vertcat(correct, 0);
            end
        elseif strcmp(num_array_H_maze_direction{i}, 'RU')

            if strcmp(num_array_H_maze_answer{i}, 'p')
                correct = vertcat(correct, 1);
            else
                correct = vertcat(correct, 0);
            end
        elseif strcmp(num_array_H_maze_direction{i}, 'RD')

            if strcmp(num_array_H_maze_answer{i}, 'm')
                correct = vertcat(correct, 1);
            else
                correct = vertcat(correct, 0);
            end
        end   

    end

% Psychometric Fitting

Input.Response = correct(strcmp(hidden_boolean, 'TRUE'));
Input.Sample_Interval = correct_interval(strcmp(hidden_boolean, 'TRUE'));
Input.short_long_correct = chose_long(strcmp(hidden_boolean, 'TRUE'));
Input.h1 = h2_hum_all(strcmp(hidden_boolean, 'TRUE'));
Input.h4 = h3_hum_all(strcmp(hidden_boolean, 'TRUE'));

[Synthetic_p_left, est_parameters] = model_half_psychometric_gamma(Input);

correct_minus_incorrect = abs(correct_interval(strcmp(hidden_boolean, 'TRUE'))-incorrect_interval(strcmp(hidden_boolean, 'TRUE')));
un_dif = unique(correct_minus_incorrect);

[g, id] = findgroups (correct_minus_incorrect );
% fh = figure();
% fh.WindowState = 'maximized';
% subplot(1,2,1)
% hold on
% scatter(un_dif , 100*splitapply(@mean, Synthetic_p_left', g), 100, pin, 'filled', 'MarkerEdgeColor','k');
% hold on
% scatter(un_dif , 100*splitapply(@mean, correct(strcmp(hidden_boolean, 'TRUE')), g), 100, dr, 'filled', 'MarkerEdgeColor','k');
% ylim([0 100])
% title(strcat('Offline, subject -', num2str(sub)))

wm_all_offline= vertcat(wm_all_offline, est_parameters(1));
% bias_all_offline =vertcat(bias_all_offline, est_parameters(2));
% lapse_all_offline =vertcat(lapse_all_offline, est_parameters(2));


Input.Response = correct(strcmp(hidden_boolean, 'FALSE'));
Input.Sample_Interval = correct_interval(strcmp(hidden_boolean, 'FALSE'));
Input.short_long_correct = chose_long(strcmp(hidden_boolean, 'FALSE'));
Input.h1 = h2_hum_all(strcmp(hidden_boolean, 'FALSE'));
Input.h4 = h3_hum_all(strcmp(hidden_boolean, 'FALSE'));

[Synthetic_p_left, est_parameters] = model_half_psychometric_gamma(Input);

correct_minus_incorrect = abs(correct_interval(strcmp(hidden_boolean, 'FALSE'))-incorrect_interval(strcmp(hidden_boolean, 'FALSE')));
un_dif = unique(correct_minus_incorrect);


[g, id] = findgroups (correct_minus_incorrect );
% subplot(1,2,2)
% hold on
% scatter(un_dif , 100*splitapply(@mean, Synthetic_p_left', g), 100, pin, 'filled', 'MarkerEdgeColor','k');
% hold on
% scatter(un_dif, 100*splitapply(@mean, correct(strcmp(hidden_boolean, 'FALSE')), g), 100, dr, 'filled', 'MarkerEdgeColor','k');
% ylim([0 100])
% legend('model', 'subject')
% title(strcat('Online, subject -', num2str(sub)))
% saveas(gcf, strcat('/Users/mahdiramadan/Documents/Jaz_Lab/Cognitive Mapping/Matlab_COM/COM/Prolific/V2_Figures/subject_', num2str(sub),'.fig'))
% close gcf

wm_all_online= vertcat(wm_all_online, est_parameters(1));
% bias_all_online =vertcat(bias_all_online, est_parameters(2));
% lapse_all_online =vertcat(lapse_all_online, est_parameters(2));


% Unique conditions and sub_conditions
conditions = {'TRUE', 'FALSE'};
unique_uniq_dif = unique(uniq_dif);

% Marker shapes for each uniq_dif value
markers = {'o', 's', 'd', '^', '>'};

% Loop over each uniq_dif value
for i = 1:length(unique_uniq_dif)
    current_dif = unique_uniq_dif(i);
    current_marker = markers{i};
            
        % Find indices matching the current condition and uniq_dif
        indices = strcmp(hidden_boolean, conditions{1}) & uniq_dif == current_dif;
        % Calculate mean performance for the current condition and uniq_dif
        mean_performance_hidden = mean(correct(indices));
        
        mean_performance_hidden_all(sub, i) = mean_performance_hidden;
 

         % Find indices matching the current condition and uniq_dif
        indices = strcmp(hidden_boolean, conditions{2}) & uniq_dif == current_dif;
        % Calculate mean performance for the current condition and uniq_dif
        mean_performance_visible = mean(correct(indices));
        
        mean_performance_visible_all(sub, i) = mean_performance_visible;

%         scatter(mean_performance_hidden, mean_performance_visible, 40, 'filled')
%         hold on
%         plot([0 1], [0 1], 'r--');

end




end


wm_cutoff = 0.4;

wm_all_offline_filt = wm_all_offline(wm_all_online<wm_cutoff);
wm_all_online_filt = wm_all_online(wm_all_online<wm_cutoff);

%%

figure()
violinplot((wm_all_offline_filt - wm_all_online_filt)./wm_all_online_filt, [], 'Bandwidth', 0.1, 'ViolinAlpha', 0.2, 'MarkerSize', 10, 'ShowMean', true)
 
[h,p3,ci,stats] = ttest((wm_all_offline_filt - wm_all_online_filt)./wm_all_online_filt)