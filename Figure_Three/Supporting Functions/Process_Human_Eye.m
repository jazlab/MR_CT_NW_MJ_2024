function [trial_var,visible,hierarchy,ntrials,sessions,trial_types_vis,trial_types_hier,subjects,Annotate_Subjects,Session_n,data] = Process_Human_Eye()
%Process Human data

%% load all data

% Adjust to local directory
directory = '/Volumes/Portable/Human_RNN/Paper_Code/Figure_Three/HMAZE_DATA';
files = dir(strcat(directory, '/*.mat'));
directoryNames = {files.name};

for i = 1:length(directoryNames)
 temp = load(strcat(directory,'/',directoryNames{i}));
 data.(strrep(strrep(num2words(i),'-','_'),'-','_')) = temp.S;
end

subjects = {'Alex', 'Cody', 'Guarav', 'Hilary', 'Paula'};

Annotate_Subjects = {'Guarav', 'Guarav', 'Guarav', 'Guarav', 'Guarav', 'Guarav','Guarav','Alex', 'Alex', 'Alex', 'Alex','Hilary','Hilary','Hilary','Hilary','Hilary','Hilary','Paula','Paula','Paula','Paula','Paula','Paula','Paula','Paula','Paula','Paula','Paula','Paula','Guarav','Paula','Paula','Paula','Paula','Paula','Paula','Alex','Alex','Alex','Alex','Alex','Alex','Alex','Cody','Cody','Cody','Cody','Guarav','Guarav','Guarav','Guarav','Cody','Cody','Cody','Cody','Cody','Hilary','Hilary','Hilary','Alex','Alex','Alex','Alex','Hilary','Hilary','Hilary','Hilary','Alex'}; 

Session_n = { '2','2','2','4','4','4','4','2','2','2','2','1','1','1','1','1','1','1','1','1','1','1','1','1','2','2','2','2','2','2','3','3','3','4','4','4','1','1','1','1','1','1','1','2','2','2','2','3','3','3','3','3','3','3','3','3','2','2','2','3','3','3','3','3','3','3','3','3'};

%%  Organize Trial Data


trial_types_vis = {'visible', 'invisible'};
trial_types_hier = {'one', 'two'};

% store variables of interest
VarNames={'tp','LR', 'LR2', 'vel','h1', 'h4', 'h2','h3',...
           'h6','h5', 'sumCorrect', 'key_ans', 'trialsLeft','start_trial','end_trial','eye_x','eye_y'};

hierarchy = zeros(length(fieldnames(data)),1);
visible = zeros(length(fieldnames(data)),1);
sessions = zeros(length(fieldnames(data)),1);
ntrials = zeros(length(fieldnames(data)),1);

% get trial data
for i = 1:length(fieldnames(data))
    
    % get start and end times for experiment
    if ~isempty(find(data.(strrep(num2words(i),'-','_')).start_trial.value)) 
        [~, ~, val] = find(data.(strrep(num2words(i),'-','_')).start_trial.value);
        [~, ~, val2] = find(data.(strrep(num2words(i),'-','_')).end_trial.value);
    
    % get protocol changes from Trials Left
    times = data.(strrep(num2words(i),'-','_')).trialsLeft.time_us;
    temp = data.(strrep(num2words(i),'-','_')).trialsLeft.value(find(times >= val(1) & times <= (val(end) + val2(end)*1e6))); 
    times_left = data.(strrep(num2words(i),'-','_')).trialsLeft.time_us(find(times >= val(1) & times <= (val(end) + val2(end)*1e6)));
    change = [];
    
    % find the changes indices
    for l = 1: length(diff(temp))-1
        a = diff(temp);
        if (a(l) == -1 & a(l+1) == 0)
            change(end + 1 ) = l+1;  
        end
    end
    if ~isempty(change)
    l = change(end);
    while (a(l) == 0)
         l = l+ 1;
    end
     change(end + 1 ) = l; 
    end
   
    % get times when protocol changes
    changes = [val(1), times_left(change), (val(end) + val2(end)*1e6)]; 
    
 
 % get rid of =99 in protocol
 proto_temp = data.(strrep(num2words(i),'-','_')).proto.value(find( data.(strrep(num2words(i),'-','_')).proto.value ~= -99));
 proto_times = data.(strrep(num2words(i),'-','_')).proto.time_us(find( data.(strrep(num2words(i),'-','_')).proto.value ~= -99));
 
 
 % for each protocol, store data with appopriate label
 for p = 2:2:length(changes)   
     
        % One or Two Hierarchy
        if p == 2
            proto_type_all = proto_temp(find(proto_times <= changes(p) & proto_times > 0));
        else
            proto_type_all = proto_temp(find(proto_times <= changes(p) & proto_times > changes(p-1)));
        end
        
        un = unique(proto_type_all);
         
        hier_id = [];
        
        if un(end) == 5
            
           hier_id = 1;
           
        elseif un(end) == 6 || un(end) == 7
            
             hier_id = 2;
        end
        
        h = length(un);
        
        vis_id = 2;
        % visible or invisible
        while h ~= 0
            if un(h) == 3 
                vis_id = 1;
                break
            elseif un(h) == 4
                vis_id = 2;
                break
            end
            h = h-1;
        end
        
       
        % trim key_ans
        times = data.(strrep(num2words(i),'-','_')).key_ans.time_us;
        data.(strrep(num2words(i),'-','_')).key_ans.value = data.(strrep(num2words(i),'-','_')).key_ans.value(find(times >= val(1) & times <= (val(end) + val2(end)*1e6)));
        data.(strrep(num2words(i),'-','_')).key_ans.time_us = data.(strrep(num2words(i),'-','_')).key_ans.time_us(find(times >= val(1) & times <= (val(end) + val2(end)*1e6)));

       if i == 29 || i == 59 || i == 51 || i == 42  
          [visible(i), hierarchy(i),ntrials(i), sessions(i),trial_var.(strrep(num2words(i),'-','_'))]=  fix_bad_trials (data.(strrep(num2words(i),'-','_')),i);
       end  
       
        % save data
       if ~isempty(hier_id)
           
        for k = 1:length(VarNames)
         if ~isempty(data.(strrep(num2words(i),'-','_')).(VarNames{k}))
         times = data.(strrep(num2words(i),'-','_')).(VarNames{k}).time_us;
         trial_var.(strrep(num2words(i),'-','_')).(trial_types_vis{vis_id}).(trial_types_hier{hier_id}).(VarNames{k}).trial_data = data.(strrep(num2words(i),'-','_')).(VarNames{k}).value(find(times >= changes(p-1) & times <= changes(p)));    
         
         if strcmp(VarNames{k}, 'start_trial') == 1 || strcmp(VarNames{k}, 'end_trial') == 1 || strcmp(VarNames{k}, 'eye_x') == 1 || strcmp(VarNames{k}, 'eye_y') == 1            
             trial_var.(strrep(num2words(i),'-','_')).(trial_types_vis{vis_id}).(trial_types_hier{hier_id}).(VarNames{k}).timing = data.(strrep(num2words(i),'-','_')).(VarNames{k}).time_us(find(times >= changes(p-1) & times <= changes(p)));    
         end
             
                         
         % get rid of repeats in h5 and h6
         if strcmp(VarNames{k}, 'h6') == 1 || strcmp(VarNames{k}, 'h5') == 1
             times_t = times((times >= changes(p-1) & times <= changes(p)));           
             trial_var.(strrep(num2words(i),'-','_')).(trial_types_vis{vis_id}).(trial_types_hier{hier_id}).(VarNames{k}).trial_data(find(diff(times_t)./1e6 < 1)) = [];
         end  
         end
       end
       
    % fill in skipped answers
     temp = trial_var.(strrep(num2words(i),'-','_')).(trial_types_vis{vis_id}).(trial_types_hier{hier_id}).(VarNames{12}).trial_data;

     store = [];
     for g = 1 : length(temp)-1
         if(temp(g) == -99 && temp(g+1) == -99)
             store(end + 1) = g+1;
         end
     end
     
    temp(store) = 0;
   
    trial_var.(strrep(num2words(i),'-','_')).(trial_types_vis{vis_id}).(trial_types_hier{hier_id}).(VarNames{12}).trial_data = temp(find(temp~=-99));

     % compute trial by trial correct vs. incorrect
     times = data.(strrep(num2words(i),'-','_')).(VarNames{11}).time_us;
     trial_var.(strrep(num2words(i),'-','_')).(trial_types_vis{vis_id}).(trial_types_hier{hier_id}).(VarNames{11}).time_us = data.(strrep(num2words(i),'-','_')).(VarNames{11}).time_us(find(times >= changes(p-1) & times <= changes(p)));
     trial_times =  trial_var.(strrep(num2words(i),'-','_')).(trial_types_vis{vis_id}).(trial_types_hier{hier_id}).(VarNames{14}).trial_data;
     
     for j = 2:length(trial_times)
         idx = max(find( trial_var.(strrep(num2words(i),'-','_')).(trial_types_vis{vis_id}).(trial_types_hier{hier_id}).(VarNames{11}).time_us <= trial_times(j))); 
         temp =  trial_var.(strrep(num2words(i),'-','_')).(trial_types_vis{vis_id}).(trial_types_hier{hier_id}).(VarNames{11}).trial_data;
         trial_var.(strrep(num2words(i),'-','_')).(trial_types_vis{vis_id}).(trial_types_hier{hier_id}).correct.trial_data(j-1) = sum(temp(idx));
     end
     
     % create correct vector
      trial_var.(strrep(num2words(i),'-','_')).(trial_types_vis{vis_id}).(trial_types_hier{hier_id}).correct.trial_data(length(trial_times)) = sum(temp(end));  
      trial_var.(strrep(num2words(i),'-','_')).(trial_types_vis{vis_id}).(trial_types_hier{hier_id}).correct_tbyt.trial_data = [ trial_var.(strrep(num2words(i),'-','_')).(trial_types_vis{vis_id}).(trial_types_hier{hier_id}).correct.trial_data(1), diff( trial_var.(strrep(num2words(i),'-','_')).(trial_types_vis{vis_id}).(trial_types_hier{hier_id}).correct.trial_data)];
     
      % add trialsLeft == 0 for last trial
     trial_var.(strrep(num2words(i),'-','_')).(trial_types_vis{vis_id}).(trial_types_hier{hier_id}).trialsLeft.trial_data = [ trial_var.(strrep(num2words(i),'-','_')).(trial_types_vis{vis_id}).(trial_types_hier{hier_id}).trialsLeft.trial_data, 0];

     
     % fix trials with misaligned protocols
     VarNames_t={'tp','LR', 'LR2', 'vel','h1', 'h4', 'h2','h3',...
           'h6','h5', 'sumCorrect', 'key_ans', 'trialsLeft','start_trial','end_trial','correct','correct_tbyt'};
         for k = 1:length(VarNames_t)
             if length(trial_var.(strrep(num2words(i),'-','_')).(trial_types_vis{vis_id}).(trial_types_hier{hier_id}).(VarNames_t{k}).trial_data)>100
                 if k == 13
                     if i == 56
                       trial_var.(strrep(num2words(i),'-','_')).(trial_types_vis{vis_id}).(trial_types_hier{hier_id}).(VarNames_t{k}).trial_data([46]) = [];
                     else
                        trial_var.(strrep(num2words(i),'-','_')).(trial_types_vis{vis_id}).(trial_types_hier{hier_id}).(VarNames_t{k}).trial_data([1,2]) = [];
                     end
                  else
                     if  k == 14
                     trial_var.(strrep(num2words(i),'-','_')).(trial_types_vis{vis_id}).(trial_types_hier{hier_id}).(VarNames_t{k}).trial_data(1) = [];
                     trial_var.(strrep(num2words(i),'-','_')).(trial_types_vis{vis_id}).(trial_types_hier{hier_id}).(VarNames_t{k}).timing(1) = [];

                    else
                    trial_var.(strrep(num2words(i),'-','_')).(trial_types_vis{vis_id}).(trial_types_hier{hier_id}).(VarNames_t{k}).trial_data(1) = [];
                     end
                 end
              end
         end
         
     
      % store trial statistics
        visible(i) = vis_id;
        hierarchy(i) = hier_id;
        ntrials(i) = length(trial_var.(strrep(num2words(i),'-','_')).(trial_types_vis{vis_id}).(trial_types_hier{hier_id}).tp.trial_data);
        sessions(i) =  length(changes)/2;
        %% example code: sum(ntrials(hierarchy == 2 & visible == 2 & cellfun(@(x) strcmp(x,'Paula'), Annotate_Subjects, 'UniformOutput', 1)'))
 
 end
 end
end
 
end

