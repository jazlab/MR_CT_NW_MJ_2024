clear all; close all; clc;

% adjust to your local path
addpath(genpath('/Volumes/Portable/Human_RNN/Paper_Code/Figure_Three/'));

% Process human eye tracking data
[trial_var, visible, hierarchy, ntrials, sessions, trial_types_vis, ...
    trial_types_hier, subjects, Annotate_Subjects, Session_n, data] = Process_Human_Eye();

% Display boundaries
DisplayLeft = -23.470;
DisplayRight = 23.470;
DisplayDown = -14.669;
DisplayUp = 14.669;

% Constants
feed_t = 0.50;  % Feedback duration
inter_t = 1.00; % Inter-trial interval
sr = 500;       % Sampling rate
minw = -100000; % Min boundary for eye tracking data
maxw = 100000;  % Max boundary for eye tracking data

% Initialize data storage
h1 = [];
h2 = [];
h3 = [];
h4 = [];
h5 = [];
h6 = [];
d1 = [];
d2 = [];
vel = [];
key = [];
t_key = [];
c_tbyt = [];
tp = [];
eye_track_arry_x = cell(550, 1);
eye_track_arry_y = cell(550, 1);
subject = [];
c = 0; % Counter for trials

% Loop through each subject
for n = 1:length(subjects)
    % Find trials for the current subject
    list = find(cellfun(@(x) strcmp(x, subjects{n}), Annotate_Subjects, 'UniformOutput', 1));

    for rr = 1:length(list)
        i = list(rr); % Trial index
        trial_name = strrep(num2words(i), '-', '_');

        % Check if trial exists in `trial_var` and meets conditions
        if isfield(trial_var, trial_name) && visible(i) == 2 && hierarchy(i) == 2
            trial_data = trial_var.(trial_name).(trial_types_vis{2}).(trial_types_hier{2});
            
            % Skip if eye tracking data is missing or empty
            if ~isfield(trial_data, 'eye_x') || isempty(trial_data.eye_x.trial_data)
                continue;
            end
            
            % Extract trial data
            h1t = trial_data.h1.trial_data;
            h2t = trial_data.h2.trial_data;
            h3t = trial_data.h3.trial_data;
            h4t = trial_data.h4.trial_data;
            h5t = trial_data.h5.trial_data;
            h6t = trial_data.h6.trial_data;
            vel_c = trial_data.vel.trial_data;
            went = trial_data.LR.trial_data;
            went2 = trial_data.LR2.trial_data;
            rt = trial_data.tp.trial_data;
            end_t = trial_data.end_trial.trial_data;
            start_t = trial_data.start_trial.trial_data ./ 1e6; % Convert to seconds
            eye_x = trial_data.eye_x.trial_data;
            eye_y = trial_data.eye_y.trial_data;
            correct = trial_data.key_ans.trial_data;
            correct_tbt = trial_data.correct_tbyt.trial_data;
            timing_start = trial_data.start_trial.timing;
            timing_x = trial_data.eye_x.timing;

            % Initialize timing key for trial
            timing_key = zeros(1, length(end_t));

            % Process each segment within the trial
            for l = 1:length(end_t) - 1
                % Find timing indices for current segment
                [~, I_t] = min(abs(timing_start(l) - timing_x));
                [~, I_t2] = min(abs(timing_start(l + 1) - timing_x));
                timing_key(l) = (I_t2 - I_t) - ((feed_t + inter_t) * sr);

                % Extract eye tracking data and clamp values
                x_temp = eye_x(I_t:I_t2);
                y_temp = eye_y(I_t:I_t2);
                eye_track_arry_x{c + l, 1} = min(max(x_temp, minw), maxw);
                eye_track_arry_y{c + l, 1} = min(max(y_temp, minw), maxw);
                subject = [subject, Annotate_Subjects(i)];
            end

            % Process the final segment
            l = length(end_t);
            [~, I_t] = min(abs(timing_start(l) - timing_x));
            [~, I_t2] = min(abs((timing_start(l) + end_t(end) * 1e6) - timing_x));
            timing_key(l) = (I_t2 - I_t) - (feed_t * sr);

            % Extract and clamp final segment eye tracking data
            x_temp = eye_x(I_t:I_t2);
            y_temp = eye_y(I_t:I_t2);
            eye_track_arry_x{c + l, 1} = min(max(x_temp, minw), maxw);
            eye_track_arry_y{c + l, 1} = min(max(y_temp, minw), maxw);
            subject = [subject, Annotate_Subjects(i)];

            % Append trial data to storage
            h1 = [h1, h1t];
            h2 = [h2, h2t];
            h3 = [h3, h3t];
            h4 = [h4, h4t];
            h5 = [h5, h5t];
            h6 = [h6, h6t];
            d1 = [d1, went];
            d2 = [d2, went2];
            key = [key, correct];
            t_key = [t_key, timing_key];
            vel = [vel, vel_c];
            c_tbyt = [c_tbyt, correct_tbt];
            tp = [tp, rt];

            % Update trial counter
            c = c + length(end_t);
        end
    end
end


%% Trial Processing: Generate Eye Tracking Configurations
% Define colors for visual representation
dr = rgb('deep red');
pin = rgb('salmon');
dg = rgb('dark green');
lg = rgb('light lime');

% Initialize storage for eye tracking data and trial configurations
xf = cell(length(t_key), 1); % X-coordinates (first phase)
yf = cell(length(t_key), 1); % Y-coordinates (first phase)
xs = cell(length(t_key), 1); % X-coordinates (second phase)
ys = cell(length(t_key), 1); % Y-coordinates (second phase)

% Initialize storage for trial arm features
f1 = zeros(length(t_key), 1); % Feature 1
f2 = zeros(length(t_key), 1); % Feature 2
f3 = zeros(length(t_key), 1); % Feature 3

% Loop through all trials
for trial_n = 1:length(t_key)
    % Extract eye tracking data for current trial
    x = eye_track_arry_x{trial_n, :};
    y = eye_track_arry_y{trial_n, :};

    % Classify Trial Based on d1 (horizontal) and d2 (vertical) Directions
    if d1(trial_n) == -1
        if d2(trial_n) == 1
            % Left and Up
            f1(trial_n) = h1(trial_n);
            f2(trial_n) = h2(trial_n);
            f3(trial_n) = h5(trial_n);
            xf{trial_n} = x(1:round(t_key(trial_n)));
            yf{trial_n} = y(1:round(t_key(trial_n)));
            xs{trial_n} = x(round(t_key(trial_n)):end);
            ys{trial_n} = y(round(t_key(trial_n)):end);

        elseif d2(trial_n) == -1
            % Left and Down
            f1(trial_n) = h1(trial_n);
            f2(trial_n) = h3(trial_n);
            f3(trial_n) = h6(trial_n);
            xf{trial_n} = x(1:round(t_key(trial_n)));
            yf{trial_n} = -y(1:round(t_key(trial_n))) + 1;
            xs{trial_n} = x(round(t_key(trial_n)):end);
            ys{trial_n} = -y(round(t_key(trial_n)):end) + 1;
        end

    elseif d1(trial_n) == 1
        if d2(trial_n) == 1
            % Right and Up
            f1(trial_n) = h4(trial_n);
            f2(trial_n) = h5(trial_n);
            f3(trial_n) = h2(trial_n);
            xf{trial_n} = -x(1:round(t_key(trial_n)));
            yf{trial_n} = y(1:round(t_key(trial_n)));
            xs{trial_n} = -x(round(t_key(trial_n)):end);
            ys{trial_n} = y(round(t_key(trial_n)):end);

        elseif d2(trial_n) == -1
            % Right and Down
            f1(trial_n) = h4(trial_n);
            f2(trial_n) = h6(trial_n);
            f3(trial_n) = h3(trial_n);
            xf{trial_n} = -x(1:round(t_key(trial_n)));
            yf{trial_n} = -y(1:round(t_key(trial_n))) + 1;
            xs{trial_n} = -x(round(t_key(trial_n)):end);
            ys{trial_n} = -y(round(t_key(trial_n)):end) + 1;
        end
    end
end

% Generate Configurations
% Use helper function to organize trial data into results
[results_xf, results_yf, results_xs, results_ys, order_trial] = ...
    configuration_eye(f1, f2, f3, xf, yf, xs, ys);


%% Plot Dynamic Eye Gaze over H-Maze through out the trial for all trials

c = 0; % Counter for processed trials
sr = 500; % Sampling rate

% Define colors for trajectory visualization
dr = rgb('deep red');
pin = rgb('salmon');
dg = rgb('dark green');
lg = rgb('light lime');
dag = rgb('dark grey');
lig = rgb('light grey');
cy = rgb('cyan');
dbl = rgb('dark blue');
face_alpha = 0.8; % Transparency for scatter points

% Loop Through Conditions
for y1 = 3:7
    for y2 = 3:7
        for y3 = 1:3
            % Extract processed eye-tracking data for the current condition
            dat_xf = results_xf{y1-2, y2-2, y3};
            dat_yf = results_yf{y1-2, y2-2, y3};
            dat_xs = results_xs{y1-2, y2-2, y3};
            dat_ys = results_ys{y1-2, y2-2, y3};
            cur_all = order_trial{y1-2, y2-2, y3};

            % Load offsets for alignment
            offset_x = load('EYE_DATA/off_x').offset_x;
            offset_y = load('EYE_DATA/off_y').offset_y;

            % Iterate through each trial in the current condition
            for o = 1:length(dat_xf)
                c = c + 1; % Increment trial counter
                cur = cur_all(o);
                curs = subject{cur}; % Subject identifier

                % Apply offsets to eye-tracking data
                x_first = dat_xf{o} + offset_x(c);
                y_first = dat_yf{o} + offset_y(c);
                x_second = dat_xs{o} + offset_x(c);
                y_second = dat_ys{o} + offset_y(c);

                % Apply saccade filtering
                buffer = 5; % Buffer for filtering
                x_first = filter_saccade(x_first, buffer);
                y_first = filter_saccade(y_first, buffer);
                x_second = filter_saccade(x_second, buffer);
                y_second = filter_saccade(y_second, buffer);

                % Calculate end duration index
                end_t_dur = 1.5 + 10/vel(cur) + y1/vel(cur) + y2/vel(cur);
                end_dur_index = round(end_t_dur * sr);

                % Handle cases where the duration exceeds the data length
                if end_dur_index > length(x_first)
                    if (end_dur_index - length(x_first)) < 100
                        temp = x_first;
                        x_first = horzcat(x_first, x_second(1:(end_dur_index - length(x_first))));
                        x_second = x_second((end_dur_index - length(temp)):end);
                        y_first = horzcat(y_first, y_second(1:(end_dur_index - length(temp))));
                        y_second = y_second((end_dur_index - length(temp)):end);
                    else
                        continue; % Skip trial if the duration difference is too large
                    end
                end

                % Plot Eye Movement Trajectories
                figure();
                plot_eye_av(y1, y2, 10-y2, 10-y1, f3(cur), key(cur), d1(cur), d2(cur));
                hold on;

                % Past initial movement duration
                past_initial = 1.5 + 10/vel(cur);
                end_first_phase = round((1.5 + 10/vel(cur) + y1/vel(cur)) * sr);

                % Scatter plot for different trajectory phases
                % Phase 1: Initial segment
                len = length(x_first(round(past_initial * sr):end_first_phase));
                grad = [linspace(pin(1), dr(1), len)', linspace(pin(2), dr(2), len)', linspace(pin(3), dr(3), len)'];
                scatter(x_first(round(past_initial * sr):end_first_phase), ...
                        y_first(round(past_initial * sr):end_first_phase) - 0.5, 80, grad, 'filled', 'MarkerFaceAlpha', face_alpha);

                % Phase 2: Intermediate segment
                len = length(x_first(end_first_phase:end_dur_index));
                grad = [linspace(lig(1), dag(1), len)', linspace(lig(2), dag(2), len)', linspace(lig(3), dag(3), len)'];
                scatter(x_first(end_first_phase:end_dur_index), ...
                        y_first(end_first_phase:end_dur_index) - 0.5, 80, grad, 'filled', 'MarkerFaceAlpha', face_alpha);

                % Phase 3: Final segment
                len = length(x_first(end_dur_index:end));
                grad = [linspace(cy(1), dbl(1), len)', linspace(cy(2), dbl(2), len)', linspace(cy(3), dbl(3), len)'];
                scatter(x_first(end_dur_index:end), ...
                        y_first(end_dur_index:end) - 0.5, 80, grad, 'filled', 'MarkerFaceAlpha', face_alpha);

                % Final plot adjustments
                ylim([-10, 10]);
                title(sprintf('x trajectory: %d, %d, %d', y1, y2, y3 + 2));
                hold off;
            end
        end
    end
end



%% Organization according to subject, confidence, and DI

% Initialize variables
c = 0;
sr = 500; % Sampling rate
dr = rgb('deep red');
pin = rgb('salmon');
dg = rgb('dark green');
lg = rgb('light lime');
dag = rgb('grey');
lig = rgb('blue grey');
face_alpha = 0.2;

% Initialize output containers
DI_EYE_x_first = cell(5, 3, 4);
DI_EYE_x_second = cell(5, 3, 4);
DI_EYE_y_first = cell(5, 3, 4);
DI_EYE_y_second = cell(5, 3, 4);
first_arm = cell(5, 3, 4);
second_arm = cell(5, 3, 4);
third_arm = cell(5, 3, 4);
velocity_arm = cell(5, 3, 4);
keys_answered = cell(5, 3, 4);
rt_sub = cell(5, 3, 4);
err_type = cell(5, 3, 4);

% Iterate through configurations (y1, y2, y3)
for y1 = 3:7
    for y2 = 3:7
        for y3 = 1:3

            % Extract trial data for the current configuration
            dat_xf = results_xf{y1 - 2, y2 - 2, y3};
            dat_yf = results_yf{y1 - 2, y2 - 2, y3};
            dat_xs = results_xs{y1 - 2, y2 - 2, y3};
            dat_ys = results_ys{y1 - 2, y2 - 2, y3};
            cur_all = order_trial{y1 - 2, y2 - 2, y3};

            % Load offsets
            offset_x = load('EYE_DATA/off_x');
            offset_y = load('EYE_DATA/off_y');
            offset_x = offset_x.offset_x;
            offset_y = offset_y.offset_y;

            % Process each trial in the current configuration
            for o = 1:length(dat_xf)

                c = c + 1; % Increment trial counter

                % Current trial index and subject
                cur = cur_all(o);
                curs = subject{cur};

                % Apply offsets to trajectory data
                x_first = dat_xf{o} + offset_x(c);
                y_first = dat_yf{o} + offset_y(c);
                x_second = dat_xs{o} + offset_x(c);
                y_second = dat_ys{o} + offset_y(c);

                % Calculate end duration and index
                end_t_dur = (1.5 + 10 / vel(cur) + y1 / vel(cur) + y2 / vel(cur));
                end_dur_index = round(end_t_dur * sr);

                % Adjust data if end duration index exceeds trial length
                if end_dur_index > length(x_first)
                    if (end_dur_index - length(x_first)) < 100
                        temp = x_first;
                        x_first = horzcat(x_first, x_second(1:(end_dur_index - length(x_first))));
                        x_second = x_second((end_dur_index - length(temp)):end);
                        y_first = horzcat(y_first, y_second(1:(end_dur_index - length(temp))));
                        y_second = y_second((end_dur_index - length(temp)):end);
                    else
                        continue;
                    end
                end

                % Identify subject index
                sub_index = find(cellfun(@(x) strcmp(curs, x), subjects, 'UniformOutput', 1));

                % Compute DI (decision index)
                DI = DI_Calc(symmetry(y2), symmetry(y3 + 2));

                % Store trajectory and metadata
                DI_EYE_x_first{sub_index, symmetry(y1), DI} = horzcat(DI_EYE_x_first{sub_index, symmetry(y1), DI}, {x_first});
                DI_EYE_x_second{sub_index, symmetry(y1), DI} = horzcat(DI_EYE_x_second{sub_index, symmetry(y1), DI}, {x_second});
                DI_EYE_y_first{sub_index, symmetry(y1), DI} = horzcat(DI_EYE_y_first{sub_index, symmetry(y1), DI}, {y_first});
                DI_EYE_y_second{sub_index, symmetry(y1), DI} = horzcat(DI_EYE_y_second{sub_index, symmetry(y1), DI}, {y_second});
                first_arm{sub_index, symmetry(y1), DI} = horzcat(first_arm{sub_index, symmetry(y1), DI}, {y1});
                second_arm{sub_index, symmetry(y1), DI} = horzcat(second_arm{sub_index, symmetry(y1), DI}, {y2});
                third_arm{sub_index, symmetry(y1), DI} = horzcat(third_arm{sub_index, symmetry(y1), DI}, {f3(cur)});
                velocity_arm{sub_index, symmetry(y1), DI} = horzcat(velocity_arm{sub_index, symmetry(y1), DI}, {vel(cur)});
                keys_answered{sub_index, symmetry(y1), DI} = horzcat(keys_answered{sub_index, symmetry(y1), DI}, {c_tbyt(cur)});
                rt_sub{sub_index, symmetry(y1), DI} = horzcat(rt_sub{sub_index, symmetry(y1), DI}, {tp(cur)});

                % Store error type
                if d1(cur) == -1
                    if key(cur) == 1 || key(cur) == 2
                        err_type{sub_index, symmetry(y1), DI} = horzcat(err_type{sub_index, symmetry(y1), DI}, {1});
                    else
                        err_type{sub_index, symmetry(y1), DI} = horzcat(err_type{sub_index, symmetry(y1), DI}, {0});
                    end
                elseif d1(cur) == 1
                    if key(cur) == 3 || key(cur) == 4
                        err_type{sub_index, symmetry(y1), DI} = horzcat(err_type{sub_index, symmetry(y1), DI}, {1});
                    else
                        err_type{sub_index, symmetry(y1), DI} = horzcat(err_type{sub_index, symmetry(y1), DI}, {0});
                    end
                end

            end
        end
    end
end


%% Analysis for eye tracking according to subject, confidence, and DI

% Initialize containers for results
first_hier = cell(3, 4);        % Track first decision (left/right)
switch_during = cell(3, 4);     % Count number of switches during the trial
switch_feedback = cell(3, 4);   % Count switches during feedback phase
key_answers = cell(3, 4);       % Store key responses
react_time = cell(3, 4);        % Store reaction times
error_type = cell(3, 4);        % Classify error types

% Iterate through subjects, confidence levels (y1), and decision indices (di)
for n = 1:length(subjects)
    for y1 = 1:3
        for di = 1:4

            % Iterate through trials for the current subject, confidence, and DI
            for i = 1:length(DI_EYE_x_first{n, y1, di})

                % Extract trial-specific data
                x_first = DI_EYE_x_first{n, y1, di}{i};
                y_first = DI_EYE_y_first{n, y1, di}{i};
                x_second = DI_EYE_x_second{n, y1, di}{i};
                y_second = DI_EYE_y_second{n, y1, di}{i};
                arm_one = first_arm{n, y1, di}{i};
                arm_two = second_arm{n, y1, di}{i};
                arm_three = third_arm{n, y1, di}{i};
                velocity = velocity_arm{n, y1, di}{i};
                answers_temp = keys_answered{n, y1, di}{i};
                rt_temp = rt_sub{n, y1, di}{i};
                err_temp = err_type{n, y1, di}{i};

                % Calculate end duration and index
                end_t_dur = (1.5 + 10 / velocity + arm_one / velocity + arm_two / velocity);
                end_dur_index = round(end_t_dur * sr);

                % Adjust scaling based on velocity
                if velocity == 8
                    scaled = 500 * (12 / 8);
                elseif velocity == 12
                    scaled = 500;
                end

                % Determine buffer size for analysis
                if length(x_first(end_dur_index:end)) > 25
                    buffer = 25;
                else
                    buffer = length(x_first(end_dur_index + 1:end));
                end

                % Classify the first decision based on trajectory data
                if all(x_first(end_dur_index:end_dur_index + buffer) < -2) && ...
                   all(x_first(end_dur_index:end_dur_index + buffer) > (-arm_one - 2)) && ...
                   all(abs(y_first(end_dur_index:end_dur_index + buffer)) < 10)
                    first_hier{y1, di} = horzcat(first_hier{y1, di}, {1}); % correct side
                    target = 1;
                elseif all(x_first(end_dur_index:end_dur_index + buffer) > 2) && ...
                       all(x_first(end_dur_index:end_dur_index + buffer) < ((10 - arm_one) + 2)) && ...
                       all(abs(y_first(end_dur_index:end_dur_index + buffer)) < 10)
                    first_hier{y1, di} = horzcat(first_hier{y1, di}, {2}); % incorrect side
                    target = 2;
                else
                    first_hier{y1, di} = horzcat(first_hier{y1, di}, {0}); % No clear decision
                    target = 0;
                end

                % Count switches during the trial
                c = 0;
                for k = end_dur_index:length(x_first) - buffer
                    if target == 1
                        if all(x_first(k:k + buffer) > 2) && ...
                           all(x_first(k:k + buffer) < ((10 - arm_one) + 2)) && ...
                           all(abs(y_first(k:k + buffer)) < 10)
                            c = c + 1;
                            target = 2;
                        end
                    elseif target == 2
                        if all(x_first(k:k + buffer) < -2) && ...
                           all(x_first(k:k + buffer) > (-arm_one - 2)) && ...
                           all(abs(y_first(k:k + buffer)) < 10)
                            c = c + 1;
                            target = 1;
                        end
                    elseif target == 0
                        if all(x_first(k:k + buffer) > 2) && ...
                           all(x_first(k:k + buffer) < ((10 - arm_one) + 2)) && ...
                           all(abs(y_first(k:k + buffer)) < 10)
                            c = c + 1;
                            target = 2;
                        elseif all(x_first(k:k + buffer) < -2) && ...
                               all(x_first(k:k + buffer) > (-arm_one - 2)) && ...
                               all(abs(y_first(k:k + buffer)) < 10)
                            c = c + 1;
                            target = 1;
                        end
                    end
                end
                switch_during{y1, di} = horzcat(switch_during{y1, di}, {c});

                % Store key answers and reaction times
                key_answers{y1, di} = horzcat(key_answers{y1, di}, {answers_temp});
                react_time{y1, di} = horzcat(react_time{y1, di}, {rt_temp});

                % Classify errors
                if answers_temp == 1
                    error_type{y1, di} = horzcat(error_type{y1, di}, {0}); % Correct
                elseif answers_temp == 0 && err_temp == 1
                    error_type{y1, di} = horzcat(error_type{y1, di}, {2}); % Wrong DI
                elseif answers_temp == 0 && err_temp == 0
                    error_type{y1, di} = horzcat(error_type{y1, di}, {1}); % Wrong arm
                end

                % Count switches during feedback
                c = 0;
                for k = 1:length(x_second) - buffer
                    if c == 0
                        if target == 1 && ...
                           all(x_second(k:k + buffer) > 2) && ...
                           all(x_second(k:k + buffer) < ((10 - arm_one) + 2)) && ...
                           all(abs(y_second(k:k + buffer)) < 10)
                            switch_feedback{y1, di} = horzcat(switch_feedback{y1, di}, {1});
                            c = 1;
                        elseif target == 2 && ...
                               all(x_second(k:k + buffer) < -2) && ...
                               all(x_second(k:k + buffer) > (-arm_one - 2)) && ...
                               all(abs(y_second(k:k + buffer)) < 10)
                            switch_feedback{y1, di} = horzcat(switch_feedback{y1, di}, {1});
                            c = 1;
                        end
                    end
                end

                % Default feedback switch classification
                if c == 0
                    switch_feedback{y1, di} = horzcat(switch_feedback{y1, di}, {0});
                end

            end
        end
    end
end



%% Plotting of Hierarchical Saccade Correctness per Condition ( horizontal arm time difference x DI metric of vertical arms ) combining all subject data

dr = rgb('deep red');
pin = rgb('salmon');
dg = rgb('grey');
gradient = [linspace(pin(1),dr(1),4)', linspace(pin(2),dr(2),4)', linspace(pin(3),dr(3),4)'];
labels = { 'Probability Undecided' , 'Probability Correct Initial', 'Probability Incorrect Initial'};


for k = 0:2
    figure()
for y1 = 1:3
    subplot(1,3,y1)
    temp = zeros(1,4);
    for di = [1:4]  
    probs = sum(cellfun(@(x) (x), first_hier{y1,di}) == k)/length(cellfun(@(x) (x), first_hier{y1,di}));
    temp(di) = probs;
    bar(di, probs, 0.5,'FaceColor','w','EdgeColor' ,gradient(di,:), 'LineWidth', 3); 
    hold on
    title(strcat(num2str(y1+2),'/',num2str(10-(y1+2))))
     ylabel(labels{k+1})
    xlabel('DI')
    ylim([0 1])
    end  
    
     line(0:0.1:5,ones(length(0:0.1:5),1)*mean(temp),'Color','k', 'LineStyle', '--','LineWidth', 1)
end
end



%% Plotting of Hierarchical Saccade ( horizontal arm time difference x DI metric of vertical arms ) combining all subject data

dr = rgb('deep red');
pin = rgb('salmon');
dg = rgb('grey');
gradient = [linspace(pin(1),dr(1),4)', linspace(pin(2),dr(2),4)', linspace(pin(3),dr(3),4)'];
labels = { 'Probability Made Hierarchical Saccade'};

figure()
for y1 = 1:3
    subplot(1,3,y1)
    temp = zeros(1,4);
    for di = [1:4]  
    probs = sum(cellfun(@(x) (x), first_hier{y1,di}) > 0)/length(cellfun(@(x) (x), first_hier{y1,di}));
    temp(di) = probs;
    bar(di, probs, 0.5,'FaceColor','w','EdgeColor' ,gradient(di,:), 'LineWidth', 3); 
    hold on
    title(strcat(num2str(y1+2),'/',num2str(10-(y1+2))))
    xlabel('DI')
    ylim([0 1])
    end  
    
     line(0:0.1:5,ones(length(0:0.1:5),1)*mean(temp),'Color','k', 'LineStyle', '--','LineWidth', 1)
end


%% Plotting of Switching Probability per Condition ( horizontal arm time difference x DI metric of vertical arms ) combining all subject data

dr = rgb('deep red');
pin = rgb('salmon');
dg = rgb('grey');
gradient = [linspace(pin(1),dr(1),4)', linspace(pin(2),dr(2),4)', linspace(pin(3),dr(3),4)'];


figure()
for y1 = 1:3
    subplot(1,3,y1)
    temp = zeros(1,4);
    for di = [1:4]  
    probs = sum(cellfun(@(x) (x), switch_during{y1,di}) > 0)/length(cellfun(@(x) (x), switch_during{y1,di}));
    temp(di) = probs;
    bar(di, probs, 0.5,'FaceColor','w','EdgeColor' ,gradient(di,:), 'LineWidth', 3); 
    hold on
    title(strcat(num2str(y1+2),'/',num2str(10-(y1+2))))
    ylabel('Probability Switch')
    xlabel('DI')
    ylim([0 1])
    end  
    
     line(0:0.1:5,ones(length(0:0.1:5),1)*mean(temp),'Color','k', 'LineStyle', '--','LineWidth', 1)
end


%% Analysis of Switching Frequency Based on Initial Correctness Per Subject


% Initialize a variable to store means for all subjects
all_subject_means = [];  % Rows: Subjects, Columns: [Correct Initial Mean, Incorrect Initial Mean]

figure();

% Iterate through subjects
for n = 1:length(subjects)

    % Initialize containers for results
    first_hier = cell(3, 4);        % Track first decision (left/right)
    switch_during = cell(3, 4);     % Count number of switches during the trial
    switch_feedback = cell(3, 4);   % Count switches during feedback phase
    key_answers = cell(3, 4);       % Store key responses
    react_time = cell(3, 4);        % Store reaction times
    error_type = cell(3, 4);        % Classify error types

    for y1 = 1:3
        for di = 1:4

            % Iterate through trials for the current subject, confidence, and DI
            for i = 1:length(DI_EYE_x_first{n, y1, di})

                % Extract trial-specific data
                x_first = DI_EYE_x_first{n, y1, di}{i};
                y_first = DI_EYE_y_first{n, y1, di}{i};
                x_second = DI_EYE_x_second{n, y1, di}{i};
                y_second = DI_EYE_y_second{n, y1, di}{i};
                arm_one = first_arm{n, y1, di}{i};
                arm_two = second_arm{n, y1, di}{i};
                arm_three = third_arm{n, y1, di}{i};
                velocity = velocity_arm{n, y1, di}{i};
                answers_temp = keys_answered{n, y1, di}{i};
                rt_temp = rt_sub{n, y1, di}{i};
                err_temp = err_type{n, y1, di}{i};

                % Calculate end duration and index
                end_t_dur = (1.5 + 10 / velocity + arm_one / velocity + arm_two / velocity);
                end_dur_index = round(end_t_dur * sr);

                % Adjust scaling based on velocity
                if velocity == 8
                    scaled = 500 * (12 / 8);
                elseif velocity == 12
                    scaled = 500;
                end

                % Determine buffer size for analysis
                if length(x_first(end_dur_index:end)) > 25
                    buffer = 25;
                else
                    buffer = length(x_first(end_dur_index + 1:end));
                end

                % Classify the first decision based on trajectory data
                if all(x_first(end_dur_index:end_dur_index + buffer) < -2) && ...
                   all(x_first(end_dur_index:end_dur_index + buffer) > (-arm_one - 2)) && ...
                   all(abs(y_first(end_dur_index:end_dur_index + buffer)) < 10)
                    first_hier{y1, di} = horzcat(first_hier{y1, di}, {1}); % Left
                    target = 1;
                elseif all(x_first(end_dur_index:end_dur_index + buffer) > 2) && ...
                       all(x_first(end_dur_index:end_dur_index + buffer) < ((10 - arm_one) + 2)) && ...
                       all(abs(y_first(end_dur_index:end_dur_index + buffer)) < 10)
                    first_hier{y1, di} = horzcat(first_hier{y1, di}, {2}); % Right
                    target = 2;
                else
                    first_hier{y1, di} = horzcat(first_hier{y1, di}, {0}); % No clear decision
                    target = 0;
                end

                % Count switches during the trial
                c = 0;
                for k = end_dur_index:length(x_first) - buffer
                    if target == 1
                        if all(x_first(k:k + buffer) > 2) && ...
                           all(x_first(k:k + buffer) < ((10 - arm_one) + 2)) && ...
                           all(abs(y_first(k:k + buffer)) < 10)
                            c = c + 1;
                            target = 2;
                        end
                    elseif target == 2
                        if all(x_first(k:k + buffer) < -2) && ...
                           all(x_first(k:k + buffer) > (-arm_one - 2)) && ...
                           all(abs(y_first(k:k + buffer)) < 10)
                            c = c + 1;
                            target = 1;
                        end
                    elseif target == 0
                        if all(x_first(k:k + buffer) > 2) && ...
                           all(x_first(k:k + buffer) < ((10 - arm_one) + 2)) && ...
                           all(abs(y_first(k:k + buffer)) < 10)
                            c = c + 1;
                            target = 2;
                        elseif all(x_first(k:k + buffer) < -2) && ...
                               all(x_first(k:k + buffer) > (-arm_one - 2)) && ...
                               all(abs(y_first(k:k + buffer)) < 10)
                            c = c + 1;
                            target = 1;
                        end
                    end
                end

                switch_during{y1, di} = horzcat(switch_during{y1, di}, {c});

                % Store key answers and reaction times
                key_answers{y1, di} = horzcat(key_answers{y1, di}, {answers_temp});
                react_time{y1, di} = horzcat(react_time{y1, di}, {rt_temp});

                % Classify errors
                if answers_temp == 1
                    error_type{y1, di} = horzcat(error_type{y1, di}, {0}); % Correct
                elseif answers_temp == 0 && err_temp == 1
                    error_type{y1, di} = horzcat(error_type{y1, di}, {2}); % Wrong DI
                elseif answers_temp == 0 && err_temp == 0
                    error_type{y1, di} = horzcat(error_type{y1, di}, {1}); % Wrong arm
                end

                % Count switches during feedback
                c = 0;
                for k = 1:length(x_second) - buffer
                    if c == 0
                        if target == 1 && ...
                           all(x_second(k:k + buffer) > 2) && ...
                           all(x_second(k:k + buffer) < ((10 - arm_one) + 2)) && ...
                           all(abs(y_second(k:k + buffer)) < 10)
                            switch_feedback{y1, di} = horzcat(switch_feedback{y1, di}, {1});
                            c = 1;
                        elseif target == 2 && ...
                               all(x_second(k:k + buffer) < -2) && ...
                               all(x_second(k:k + buffer) > (-arm_one - 2)) && ...
                               all(abs(y_second(k:k + buffer)) < 10)
                            switch_feedback{y1, di} = horzcat(switch_feedback{y1, di}, {1});
                            c = 1;
                        end
                    end
                end

                % Default feedback switch classification
                if c == 0
                    switch_feedback{y1, di} = horzcat(switch_feedback{y1, di}, {0});
                end

            end
        end
    end
        
    % Initialize variables to store means for the current subject
    subject_means = zeros(1, 2);  % [Correct Initial Mean, Incorrect Initial Mean]
    
    % Iterate over Correct Initial (k = 1) and Incorrect Initial (k = 2)
    for k = 1:2
        switch_probs = [];
    
        % Loop over conditions
        for y1 = 1:3
            for di = 1:4
                if isempty(first_hier{y1, di}) || isempty(switch_during{y1, di})
                    continue;
                end
    
                initial_data = cell2mat(first_hier{y1, di});  % Convert to numeric array
                switch_data = cell2mat(switch_during{y1, di});  % Convert to numeric array
    
                % Find trials matching the current correctness type (k)
                correct_indices = find(initial_data == k);
    
                % Collect switch probabilities
                if ~isempty(correct_indices)
                    switch_probs = [switch_probs; mean(switch_data(correct_indices) > 0)];
                end
            end
        end
    
        % Compute the mean switch probability for this correctness type
        if ~isempty(switch_probs)
            subject_means(k) = mean(switch_probs);
        else
            subject_means(k) = NaN;  % If no data, set to NaN
        end
    end
   
    
    
    % Scatter plot and connect data for this subject
    plot(1:2, subject_means, '-o', 'LineWidth', 1.5, 'DisplayName', sprintf('Subject %d', n));  % `n` is the subject ID
    
    hold on;

    % Append the means for this subject to `all_subject_means`
    all_subject_means = [all_subject_means; subject_means];

end

% Plotting Across Subjects

% Compute and plot the overall mean across all subjects (if available)
if exist('all_subject_means', 'var')
    overall_mean = mean(all_subject_means, 1, 'omitnan');
    overall_std = std(all_subject_means, 1, 'omitnan');
    plot(1:2, overall_mean, 'k--o', 'LineWidth', 2, 'DisplayName', 'Overall Mean');
    hold on
    errorbar(1:2, overall_mean, overall_std, 'LineWidth', 2, 'Color', 'k')
end

% Add plot details
xticks(1:2);
xticklabels({'Correct Initial', 'Incorrect Initial'});
ylabel('Switch Probability');
xlabel('Saccade Type');
ylim([0, 1]);
legend('show');
grid on;
title('Switch Probabilities Across Subjects and Saccade Types');


[h, p, ci, stats] = ttest(all_subject_means(:,2),all_subject_means(:,1), 'Tail', 'right');


%% Analysis of Correct, Incorrect, and Total Hierarchical Saccades Per Subject Per Maze

% Initialize variables for storing subject data and overall mean
all_subject_correct = []; % Correct hierarchical saccades
all_subject_incorrect = []; % Incorrect hierarchical saccades
all_subject_hierarchical = []; % Sum of correct + incorrect

% Iterate through subjects
for n = 1:length(subjects)
    
    % Initialize storage for current subject's percentages
    subject_correct = zeros(1, 3); % Correct percentage for each y1
    subject_incorrect = zeros(1, 3); % Incorrect percentage for each y1
    subject_hierarchical = zeros(1, 3); % Total (correct + incorrect)

    % Initialize containers for results
    first_hier = cell(3, 4);        % Track first decision (left/right)
    switch_during = cell(3, 4);     % Count number of switches during the trial
    switch_feedback = cell(3, 4);   % Count switches during feedback phase
    key_answers = cell(3, 4);       % Store key responses
    react_time = cell(3, 4);        % Store reaction times
    error_type = cell(3, 4);        % Classify error types

    for y1 = 1:3
        for di = 1:4

            % Iterate through trials for the current subject, confidence, and DI
            for i = 1:length(DI_EYE_x_first{n, y1, di})

                % Extract trial-specific data
                x_first = DI_EYE_x_first{n, y1, di}{i};
                y_first = DI_EYE_y_first{n, y1, di}{i};
                x_second = DI_EYE_x_second{n, y1, di}{i};
                y_second = DI_EYE_y_second{n, y1, di}{i};
                arm_one = first_arm{n, y1, di}{i};
                arm_two = second_arm{n, y1, di}{i};
                arm_three = third_arm{n, y1, di}{i};
                velocity = velocity_arm{n, y1, di}{i};
                answers_temp = keys_answered{n, y1, di}{i};
                rt_temp = rt_sub{n, y1, di}{i};
                err_temp = err_type{n, y1, di}{i};

                % Calculate end duration and index
                end_t_dur = (1.5 + 10 / velocity + arm_one / velocity + arm_two / velocity);
                end_dur_index = round(end_t_dur * sr);

                % Adjust scaling based on velocity
                if velocity == 8
                    scaled = 500 * (12 / 8);
                elseif velocity == 12
                    scaled = 500;
                end

                % Determine buffer size for analysis
                if length(x_first(end_dur_index:end)) > 25
                    buffer = 25;
                else
                    buffer = length(x_first(end_dur_index + 1:end));
                end

                % Classify the first decision based on trajectory data
                if all(x_first(end_dur_index:end_dur_index + buffer) < -2) && ...
                   all(x_first(end_dur_index:end_dur_index + buffer) > (-arm_one - 2)) && ...
                   all(abs(y_first(end_dur_index:end_dur_index + buffer)) < 10)
                    first_hier{y1, di} = horzcat(first_hier{y1, di}, {1}); % Left
                    target = 1;
                elseif all(x_first(end_dur_index:end_dur_index + buffer) > 2) && ...
                       all(x_first(end_dur_index:end_dur_index + buffer) < ((10 - arm_one) + 2)) && ...
                       all(abs(y_first(end_dur_index:end_dur_index + buffer)) < 10)
                    first_hier{y1, di} = horzcat(first_hier{y1, di}, {2}); % Right
                    target = 2;
                else
                    first_hier{y1, di} = horzcat(first_hier{y1, di}, {0}); % No clear decision
                    target = 0;
                end

            end
        end


        % Collect trials for correct and incorrect hierarchical saccades
        correct_trials = 0;
        incorrect_trials = 0;
        total_trials = 0;

        % Loop over (di) for current maze
        for di = 1:4
            if isempty(first_hier{y1, di})
                continue;
            end

            initial_data = cell2mat(first_hier{y1, di}); % Convert to numeric array

            % Count correct and incorrect trials
            correct_trials = correct_trials + sum(initial_data == 1); % Correct hierarchical
            incorrect_trials = incorrect_trials + sum(initial_data == 2); % Incorrect hierarchical
            total_trials = total_trials + length(initial_data);
        end

        % Compute percentages for the current maze
        if total_trials > 0
            subject_correct(y1) = (correct_trials / total_trials) * 100;
            subject_incorrect(y1) = (incorrect_trials / total_trials) * 100;
            subject_hierarchical(y1) = ((correct_trials + incorrect_trials) / total_trials) * 100;
        else
            subject_correct(y1) = NaN;
            subject_incorrect(y1) = NaN;
            subject_hierarchical(y1) = NaN;
        end

    end
        
    % Store subject data for overall mean computation
    all_subject_correct = [all_subject_correct; subject_correct];
    all_subject_incorrect = [all_subject_incorrect; subject_incorrect];
    all_subject_hierarchical = [all_subject_hierarchical; subject_hierarchical];

end

% Compute means and standard deviations
mean_correct = mean(all_subject_correct, 1, 'omitnan');
std_correct = std(all_subject_correct, 0, 1, 'omitnan');
mean_incorrect = mean(all_subject_incorrect, 1, 'omitnan');
std_incorrect = std(all_subject_incorrect, 0, 1, 'omitnan');
mean_hierarchical = mean(all_subject_hierarchical, 1, 'omitnan');
std_hierarchical = std(all_subject_hierarchical, 0, 1, 'omitnan');

cumulative_incorrect = all_subject_correct + all_subject_incorrect;
mean_cumulative_incorrect = mean(cumulative_incorrect, 1, 'omitnan');
std_cumulative_incorrect = std(cumulative_incorrect, 1, 'omitnan');

% X-axis labels for y1 maze conditions
x_labels = {'y1 = 1', 'y1 = 2', 'y1 = 3'};
x = 1:3;

% Create the plot
figure();
hold on;

% Define colors
colors = lines(3); % Three distinct colors for Correct, Incorrect, and Total

% Compute cumulative incorrect values for each subject (if not already provided)
cumulative_incorrect = all_subject_correct + all_subject_incorrect;

% Create bar data
bar_data = [mean_correct; mean_cumulative_incorrect - mean_correct]';

% Plot bars
b = bar(x, bar_data, 0.6, 'stacked', 'EdgeColor', 'none');
b(1).FaceColor = colors(1, :); % Correct
b(2).FaceColor = colors(2, :); % Incorrect

% Add error bars for the correct and cumulative incorrect values
errorbar(x, mean_correct, std_correct, 'k.', 'LineWidth', 1.5, 'CapSize', 10); % Correct
errorbar(x, mean_cumulative_incorrect, std_cumulative_incorrect, 'k.', 'LineWidth', 1.5, 'CapSize', 10); % Cumulative Incorrect

% Overlay individual data points for correct
scatter(repmat(x(1), size(all_subject_correct, 1), 1), all_subject_correct(:, 1), ...
    50, colors(1, :), 'filled', 'MarkerEdgeColor', 'k');
scatter(repmat(x(2), size(all_subject_correct, 1), 1), all_subject_correct(:, 2), ...
    50, colors(1, :), 'filled', 'MarkerEdgeColor', 'k');
scatter(repmat(x(3), size(all_subject_correct, 1), 1), all_subject_correct(:, 3), ...
    50, colors(1, :), 'filled', 'MarkerEdgeColor', 'k');

% Overlay individual data points for cumulative incorrect
scatter(repmat(x(1), size(all_subject_incorrect, 1), 1), cumulative_incorrect(:, 1), ...
    50, colors(2, :), 'filled', 'MarkerEdgeColor', 'k');
scatter(repmat(x(2), size(all_subject_incorrect, 1), 1), cumulative_incorrect(:, 2), ...
    50, colors(2, :), 'filled', 'MarkerEdgeColor', 'k');
scatter(repmat(x(3), size(all_subject_incorrect, 1), 1), cumulative_incorrect(:, 3), ...
    50, colors(2, :), 'filled', 'MarkerEdgeColor', 'k');

% Customize the plot
xticks(x);
xticklabels(x_labels);
ylabel('Percentage of Trials');
xlabel('y1 Maze Conditions');
ylim([0, 100]);
legend({'Correct Hierarchical Saccade', 'Incorrect Hierarchical Saccade'}, 'Location', 'northwest');
grid on;
title('Percentages of Hierarchical Saccades Across Maze Conditions');

hold off;




%% Analysis of Switching Frequency Based on Maze Per Subject


% Initialize variables for storing subject data
all_subject_switching = []; % Switching percentages for all subjects

% Iterate through subjects, confidence levels (y1), and decision indices (di)
for n = 1:length(subjects)
    
    % Initialize storage for current subject's switching percentages
    subject_switching = zeros(1, 3); % Switching percentage for each y1


    % Initialize containers for results
    first_hier = cell(3, 4);        % Track first decision (left/right)
    switch_during = cell(3, 4);     % Count number of switches during the trial
    switch_feedback = cell(3, 4);   % Count switches during feedback phase
    key_answers = cell(3, 4);       % Store key responses
    react_time = cell(3, 4);        % Store reaction times
    error_type = cell(3, 4);        % Classify error types

    for y1 = 1:3

        total_trials = 0;
        switch_trials = 0;

        for di = 1:4

            % Iterate through trials for the current subject, confidence, and DI
            for i = 1:length(DI_EYE_x_first{n, y1, di})

                % Extract trial-specific data
                x_first = DI_EYE_x_first{n, y1, di}{i};
                y_first = DI_EYE_y_first{n, y1, di}{i};
                x_second = DI_EYE_x_second{n, y1, di}{i};
                y_second = DI_EYE_y_second{n, y1, di}{i};
                arm_one = first_arm{n, y1, di}{i};
                arm_two = second_arm{n, y1, di}{i};
                arm_three = third_arm{n, y1, di}{i};
                velocity = velocity_arm{n, y1, di}{i};
                answers_temp = keys_answered{n, y1, di}{i};
                rt_temp = rt_sub{n, y1, di}{i};
                err_temp = err_type{n, y1, di}{i};

                % Calculate end duration and index
                end_t_dur = (1.5 + 10 / velocity + arm_one / velocity + arm_two / velocity);
                end_dur_index = round(end_t_dur * sr);

                % Adjust scaling based on velocity
                if velocity == 8
                    scaled = 500 * (12 / 8);
                elseif velocity == 12
                    scaled = 500;
                end

                % Determine buffer size for analysis
                if length(x_first(end_dur_index:end)) > 25
                    buffer = 25;
                else
                    buffer = length(x_first(end_dur_index + 1:end));
                end

                % Classify the first decision based on trajectory data
                if all(x_first(end_dur_index:end_dur_index + buffer) < -2) && ...
                   all(x_first(end_dur_index:end_dur_index + buffer) > (-arm_one - 2)) && ...
                   all(abs(y_first(end_dur_index:end_dur_index + buffer)) < 10)
                    first_hier{y1, di} = horzcat(first_hier{y1, di}, {1}); % Left
                    target = 1;
                elseif all(x_first(end_dur_index:end_dur_index + buffer) > 2) && ...
                       all(x_first(end_dur_index:end_dur_index + buffer) < ((10 - arm_one) + 2)) && ...
                       all(abs(y_first(end_dur_index:end_dur_index + buffer)) < 10)
                    first_hier{y1, di} = horzcat(first_hier{y1, di}, {2}); % Right
                    target = 2;
                else
                    first_hier{y1, di} = horzcat(first_hier{y1, di}, {0}); % No clear decision
                    target = 0;
                end

                % Count switches during the trial
                c = 0;
                for k = end_dur_index:length(x_first) - buffer
                    if target == 1
                        if all(x_first(k:k + buffer) > 2) && ...
                           all(x_first(k:k + buffer) < ((10 - arm_one) + 2)) && ...
                           all(abs(y_first(k:k + buffer)) < 10)
                            c = c + 1;
                            target = 2;
                        end
                    elseif target == 2
                        if all(x_first(k:k + buffer) < -2) && ...
                           all(x_first(k:k + buffer) > (-arm_one - 2)) && ...
                           all(abs(y_first(k:k + buffer)) < 10)
                            c = c + 1;
                            target = 1;
                        end
                    elseif target == 0
                        if all(x_first(k:k + buffer) > 2) && ...
                           all(x_first(k:k + buffer) < ((10 - arm_one) + 2)) && ...
                           all(abs(y_first(k:k + buffer)) < 10)
                            c = c + 1;
                            target = 2;
                        elseif all(x_first(k:k + buffer) < -2) && ...
                               all(x_first(k:k + buffer) > (-arm_one - 2)) && ...
                               all(abs(y_first(k:k + buffer)) < 10)
                            c = c + 1;
                            target = 1;
                        end
                    end
                end

                switch_during{y1, di} = horzcat(switch_during{y1, di}, {c});

                % Store key answers and reaction times
                key_answers{y1, di} = horzcat(key_answers{y1, di}, {answers_temp});
                react_time{y1, di} = horzcat(react_time{y1, di}, {rt_temp});

                % Classify errors
                if answers_temp == 1
                    error_type{y1, di} = horzcat(error_type{y1, di}, {0}); % Correct
                elseif answers_temp == 0 && err_temp == 1
                    error_type{y1, di} = horzcat(error_type{y1, di}, {2}); % Wrong DI
                elseif answers_temp == 0 && err_temp == 0
                    error_type{y1, di} = horzcat(error_type{y1, di}, {1}); % Wrong arm
                end

                % Count switches during feedback
                c = 0;
                for k = 1:length(x_second) - buffer
                    if c == 0
                        if target == 1 && ...
                           all(x_second(k:k + buffer) > 2) && ...
                           all(x_second(k:k + buffer) < ((10 - arm_one) + 2)) && ...
                           all(abs(y_second(k:k + buffer)) < 10)
                            switch_feedback{y1, di} = horzcat(switch_feedback{y1, di}, {1});
                            c = 1;
                        elseif target == 2 && ...
                               all(x_second(k:k + buffer) < -2) && ...
                               all(x_second(k:k + buffer) > (-arm_one - 2)) && ...
                               all(abs(y_second(k:k + buffer)) < 10)
                            switch_feedback{y1, di} = horzcat(switch_feedback{y1, di}, {1});
                            c = 1;
                        end
                    end
                end

                % Default feedback switch classification
                if c == 0
                    switch_feedback{y1, di} = horzcat(switch_feedback{y1, di}, {0});
                end

            end
        end

        % Loop over maze conditions (di) for current y1 level
        for di = 1:4
            if isempty(switch_during{y1, di})
                continue;
            end

            % Convert cell contents to numeric array
            switch_data = cell2mat(switch_during{y1, di});

            % Count trials with switches
            switch_trials = switch_trials + sum(switch_data > 0);
            total_trials = total_trials + length(switch_data);
        end

        % Compute switching percentage for the current y1 level
        if total_trials > 0
            subject_switching(y1) = (switch_trials / total_trials) * 100;
        else
            subject_switching(y1) = NaN;
        end

    end
        
     % Store subject data for overall computation
    all_subject_switching = [all_subject_switching; subject_switching];

end

% Compute means and standard deviations
mean_switching = mean(all_subject_switching, 1, 'omitnan');
std_switching = std(all_subject_switching, 0, 1, 'omitnan');

% X-axis labels for y1 levels
x_labels = {'y1 = 1', 'y1 = 2', 'y1 = 3'};
x = 1:3;

% Create the plot
figure();
hold on;

% Define color for individual subjects
subject_color = [0.2, 0.6, 0.4]; % Greenish tone for switches
mean_color = [0, 0, 0]; % Black for the mean

% Plot points for individual subjects and connect with lines
for n = 1:size(all_subject_switching, 1)
    % Plot points for the subject
    plot(x, all_subject_switching(n, :), '-o', 'Color', subject_color, 'LineWidth', 1, ...
         'MarkerFaceColor', subject_color, 'MarkerEdgeColor', 'k', 'DisplayName', sprintf('Subject %d', n));
end

% Plot mean and standard deviation as error bars
errorbar(x, mean_switching, std_switching, '-o', 'Color', mean_color, 'LineWidth', 2, ...
         'MarkerFaceColor', mean_color, 'MarkerEdgeColor', 'k', 'DisplayName', 'Mean Switching Percentage');

% Add labels and legend
xticks(x);
xticklabels(x_labels);
ylabel('Switching Percentage');
xlabel('Confidence Levels (y1)');
ylim([0, 100]);
legend('show', 'Location', 'best');
grid on;
title('Switching Percentage Across Confidence Levels (y1)');

hold off;



[h, p, ci, stats] = ttest( all_subject_switching(:,3), all_subject_switching(:,1), 'Tail', 'right')

[h, p, ci, stats] = ttest( all_subject_switching(:,3), all_subject_switching(:,2), 'Tail', 'right')