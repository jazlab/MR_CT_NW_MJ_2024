clear all; clc; close all;
addpath(genpath('/Volumes/Portable/Human_RNN/Paper_Code/Figure_Four/Prolific_V1/'));
addpath '/Volumes/Portable/Human_RNN/Paper_Code/Figure_Four/Prolific_V1/Supporting_Functions/'

dr = rgb('deep red');
pin = rgb('salmon');

db = rgb('blue');
xc = rgb('cyan');

store_subject_id = [];
store_wm = [];
store_lapse = [];
% This script fits a psychometric model to data. The three fitted
% parameters are a wm value ( parameter 1), a bias value (parameter 2) and
% a lapse paramater ( parameter 3 ). To start, we need a to keep track of a
% couple variables:

% correct_minus_incorrect - a variable that keeps track of the time
% difference between the correct and incorrect answers ( time units)

% correct_short - a variable that indicates whether the shorter of the two
% arms was chosen correctly. 50/50 which arm is short if arms are equal

% occ_t - a variable that keps track of the sample interval of the correct
% choice

% arm_1 - the length of the left arm in time

% arm_2 - the length of the right arm in time

all_data_t_maze_v1 = readtable('t-v1-maze.csv');
all_subject_ids = unique(all_data_t_maze_v1.subject_id);


%%%%%%%%% LOAD DATA FOR T_MAZE V1 %%%%%%%%%%%%%%%%%%%%%

pattern = '\[([-+]?\d+(\.\d+)?|\.\d+),([-+]?\d+(\.\d+)?|\.\d+)';

pixels_per_sec = 150;

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


% 
% figure(1)
% 
% for u = 1:length(un_dif)
%     scatter( un_dif(u), (1- mean(correct_short(correct_minus_incorrect == un_dif(u))))*100, 50,'filled');
%     ylim([0 100])
%     hold on
% end


Input.Response = ~correct_short;
Input.Sample_Interval = correct;
Input.h1 = arm_1;
Input.h4 = arm_2;

[Synthetic_p_left, est_parameters] = model_psychometric_gamma(Input);
% [Synthetic_p_left, est_parameters] = model_psychometric_gamma_total_time(Input);

% figure(1)
% hold on
% [g, id] = findgroups (correct_minus_incorrect );
% scatter(unique(correct_minus_incorrect) , 100*splitapply(@mean, Synthetic_p_left', g), 100, pin, 'filled', 'MarkerEdgeColor','k');

store_subject_id = vertcat(store_subject_id, current_sub_id);
store_wm = vertcat(store_wm, est_parameters(1));
store_lapse = vertcat(store_lapse, est_parameters(3));
end




%%%%%%%%% Analyze V1 maze variant %%%%%%%%%%%%%%%%%%%%%
%%

sub_performance = [];
model_performance = [];
for sub = 1:length(store_subject_id )
    if store_wm (sub) < 0.4
    current_sub_id = store_subject_id(sub);
    current_t_maze_data = all_data_t_maze_v1( (all_data_t_maze_v1.subject_id ==  current_sub_id) & strcmp(all_data_t_maze_v1.task, 'V1')  ,:);
    
    %%% subject performance 

     temp = [];
     for i = 1:length(current_t_maze_data.Var1)

            temp = vertcat(temp , str2num(current_t_maze_data.target{i})+1 == str2num(current_t_maze_data.response{i}) );
     end

    sub_performance = vertcat(sub_performance,mean(temp));



    %%% model prediction
    

    % generate samples
    rect_1 = 0.4;
    rect_2 = 0.6;
    rect_3 = 0.5;
    rect_4 = 0.7;

    condition_lengths = 17;

    % generate trials
    occ_t = [];
    n_bounces = [];
    which = [];

    for ii = 1:condition_lengths
        occ_t = vertcat(occ_t, rect_1);
        n_bounces = vertcat(n_bounces, 2);
        which = vertcat(which ,1);
    end

    for ii = 1:condition_lengths
        occ_t = vertcat(occ_t, rect_1);
        n_bounces = vertcat(n_bounces, 3);
        which = vertcat(which ,1);
    end
    for ii = 1:condition_lengths
        occ_t = vertcat(occ_t, rect_1);
        n_bounces = vertcat(n_bounces, 4);
        which = vertcat(which ,1);
    end
    for ii = 1:condition_lengths
        occ_t = vertcat(occ_t, rect_2);
        n_bounces = vertcat(n_bounces, 1);
        which = vertcat(which ,2);
    end
    for ii = 1:condition_lengths
        occ_t = vertcat(occ_t, rect_2);
        n_bounces = vertcat(n_bounces, 2);
        which = vertcat(which ,2);
    end
    for ii = 1:condition_lengths
        occ_t = vertcat(occ_t, rect_3);
        n_bounces = vertcat(n_bounces, 1);
        which = vertcat(which ,3);
    end
    for ii = 1:condition_lengths
        occ_t = vertcat(occ_t, rect_3);
        n_bounces = vertcat(n_bounces, 2);
        which = vertcat(which ,3);
    end
    for ii = 1:condition_lengths
        occ_t = vertcat(occ_t, rect_3);
        n_bounces = vertcat(n_bounces, 3);
        which = vertcat(which ,3);
    end
    for ii = 1:condition_lengths
        occ_t = vertcat(occ_t, rect_4);
        n_bounces = vertcat(n_bounces, 1);
        which = vertcat(which ,4);
    end
    for ii = 1:condition_lengths
        occ_t = vertcat(occ_t, rect_4);
        n_bounces = vertcat(n_bounces, 2);
        which = vertcat(which ,4);
    end
    
    arm_1 = [];
    arm_2 = [];
    arm_3 = [];
    arm_4 = [];

    bounces_right = [1,3];
    bounces_left = [2,4];
    for iii = 1:length(n_bounces)

        if n_bounces(iii) == 1 || n_bounces(iii) == 3
            max_bounces = [1,3];
        else
            max_bounces = [2,4];
        end
        
      

        [min_v, min_i] = min( abs((rect_1).*(max_bounces) - (occ_t(iii)*n_bounces(iii))) );
        arm_1 = horzcat(arm_1, (rect_1)*max_bounces (min_i));
        
        [min_v, min_i] = min( abs( (rect_2).*(max_bounces) - (occ_t(iii)*n_bounces(iii)) ) );
        arm_2 = horzcat(arm_2, (rect_2)*max_bounces (min_i));
        
        [min_v, min_i] = min( abs( ( rect_3).*(max_bounces) - (occ_t(iii)*n_bounces(iii))) );
        arm_3 = horzcat(arm_3, (rect_3)*max_bounces (min_i));
        
        [min_v, min_i] = min( abs( (rect_4).*(max_bounces) - (occ_t(iii)*n_bounces(iii))) );
        arm_4 = horzcat(arm_4, (rect_4)*max_bounces (min_i));

       
    end

    scalar = store_wm (sub); % per subject
    ntrials = 1000;
    perf = [];
    
    for i = 1:ntrials
    
        [truth_1,truth_2,truth_3,truth_4,Total_noise] = generate_structure_NHP(arm_1,arm_2,arm_3,arm_4,eps,scalar,which);
        [alt1,alt2,alt3,alt4,correctnh] = total_time(arm_1,arm_2,arm_3,arm_4, Total_noise, scalar,truth_1,truth_2,truth_3,truth_4);
        perf = horzcat(perf ,mean(correctnh));

    end
    
    model_performance = vertcat(model_performance, mean(perf));

    end
end

%%

figure()

scatter(sub_performance , model_performance  , 'filled')
xlim([0 1])
ylim([0 1])

[h,p1,ci,stats] = ttest(sub_performance,model_performance,"Tail","left");


