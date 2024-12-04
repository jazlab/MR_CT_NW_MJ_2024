function [ visible,hierarchy, ntrials, sessions , trial_var] = fix_bad_trials(data,i)

trial_types_vis = {'visible', 'invisible'};
trial_types_hier = {'one', 'two'};

% store variables of interest
VarNames={'tp','LR', 'LR2', 'vel','h1', 'h4', 'h2','h3',...
           'h6','h5', 'sumCorrect', 'key_ans', 'trialsLeft','start_trial','end_trial','eye_x','eye_y'};
vis_id = 2;
hier_id = 2;
       
time_t = min(data.(VarNames{14}).time_us(data.(VarNames{14}).value ~= 0));
for k = 1:length(VarNames)  
    if ~isempty(data.(VarNames{k}))
        trial_var.(trial_types_vis{vis_id}).(trial_types_hier{hier_id}).(VarNames{k}).trial_data = data.(VarNames{k}).value(data.(VarNames{k}).time_us >= time_t);   
        
    if strcmp(VarNames{k}, 'start_trial') == 1 || strcmp(VarNames{k}, 'end_trial') == 1 || strcmp(VarNames{k}, 'eye_x') == 1 || strcmp(VarNames{k}, 'eye_y') == 1            
             trial_var.(trial_types_vis{vis_id}).(trial_types_hier{hier_id}).(VarNames{k}).timing = data.(VarNames{k}).time_us(data.(VarNames{k}).time_us >= time_t);    
    end
         
     
    if strcmp(VarNames{k}, 'key_ans') == 0
        if strcmp(VarNames{k}, 'start_trial') == 1 || strcmp(VarNames{k}, 'end_trial') == 1 || strcmp(VarNames{k}, 'eye_x') == 1 || strcmp(VarNames{k}, 'eye_y') == 1   
            trial_var.(trial_types_vis{vis_id}).(trial_types_hier{hier_id}).(VarNames{k}).trial_data(end) = []; 
            trial_var.(trial_types_vis{vis_id}).(trial_types_hier{hier_id}).(VarNames{k}).timing(end) = []; 
        else
             trial_var.(trial_types_vis{vis_id}).(trial_types_hier{hier_id}).(VarNames{k}).trial_data(end) = [];
        end
        end
    
    if strcmp(VarNames{k}, 'h6') == 1 || strcmp(VarNames{k}, 'h5') == 1
             times_t = data.(VarNames{k}).time_us(data.(VarNames{k}).time_us >= time_t);           
             trial_var.(trial_types_vis{vis_id}).(trial_types_hier{hier_id}).(VarNames{k}).trial_data(find(diff(times_t)./1e6 < 1)) = [];
    end  
    end
end     

   
    % fill in skipped answers
     temp = trial_var.(trial_types_vis{vis_id}).(trial_types_hier{hier_id}).(VarNames{12}).trial_data;

     store = [];
     for g = 1 : length(temp)-1
         if(temp(g) == -99 && temp(g+1) == -99)
             store(end + 1) = g+1;
         end
     end
     
    temp(store) = 0;
   
    trial_var.(trial_types_vis{vis_id}).(trial_types_hier{hier_id}).(VarNames{12}).trial_data = temp(find(temp~=-99));

     % compute trial by trial correct vs. incorrect
     times = data.(VarNames{11}).time_us;
     trial_var.(trial_types_vis{vis_id}).(trial_types_hier{hier_id}).(VarNames{11}).time_us = data.(VarNames{11}).time_us(times >= time_t);
     trial_times =  trial_var.(trial_types_vis{vis_id}).(trial_types_hier{hier_id}).(VarNames{14}).trial_data;
     
     for j = 2:length(trial_times)
         idx = max(find( trial_var.(trial_types_vis{vis_id}).(trial_types_hier{hier_id}).(VarNames{11}).time_us <= trial_times(j))); 
         temp =  trial_var.(trial_types_vis{vis_id}).(trial_types_hier{hier_id}).(VarNames{11}).trial_data;
         trial_var.(trial_types_vis{vis_id}).(trial_types_hier{hier_id}).correct.trial_data(j-1) = sum(temp(idx));
     end
     
     % create correct vector
      trial_var.(trial_types_vis{vis_id}).(trial_types_hier{hier_id}).correct.trial_data(length(trial_times)) = sum(temp(end));  
      trial_var.(trial_types_vis{vis_id}).(trial_types_hier{hier_id}).correct_tbyt.trial_data = [ trial_var.(trial_types_vis{vis_id}).(trial_types_hier{hier_id}).correct.trial_data(1), diff( trial_var.(trial_types_vis{vis_id}).(trial_types_hier{hier_id}).correct.trial_data)];
     
        
      % store trial statistics
        visible = vis_id;
        hierarchy = hier_id;
        ntrials = length(trial_var.(trial_types_vis{vis_id}).(trial_types_hier{hier_id}).tp.trial_data);
        sessions = 1;
end

