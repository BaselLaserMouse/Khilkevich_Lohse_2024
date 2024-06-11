

PSTHwindow = [-3 2];
Stim1Ori_use = [270 ]; % drift direction(s) of gratings 
subjects = fieldnames(data);
TrialGroups = [];

for i = 1 % which mouse
    
    sessions = fieldnames(data.(subjects{i}));
    for j = 1 % which session
        
        probes_numb = length(data.(subjects{i}).(sessions{j}).NPX_probes);
        
        Baseline_ON_times = data.(subjects{i}).(sessions{j}).NI_events.Baseline_ON.rise_t;
        Change_ON_times = data.(subjects{i}).(sessions{j}).NI_events.Change_ON.rise_t;
        Change_ON_dur = data.(subjects{i}).(sessions{j}).NI_events.Change_ON.duration;
        
        Reward_times = data.(subjects{i}).(sessions{j}).NI_events.Valve_L.rise_t;
        Airpuff_times = data.(subjects{i}).(sessions{j}).NI_events.Air_puff.rise_t;
        frame_times = data.(subjects{i}).(sessions{j}).NI_events.frame_times_tr.time;
        
        trials_numb  = length(Baseline_ON_times);
        
        TrialsData = data.(subjects{i}).(sessions{j}).behav_data.trials_data_exp;
        ReactionTimes = [TrialsData.reactiontimes];
        ReactionTimesFA = [ReactionTimes.FA];
        ReactionTimesAbort = [ReactionTimes.abort];

        Change_magn = [TrialsData.Stim2TF];
        Stim1Ori = [TrialsData.Stim1Ori];
        TF = {TrialsData.TF};
        phase = {TrialsData.phase};
        
        picked_Stim1Ori_trials = sum((Stim1Ori==Stim1Ori_use'),1);
        hit_trials = ([TrialsData.IsHit]==1);
        early_blocks_hit_trials = (( ([TrialsData.IsEarlyBlock]==1)&([TrialsData.IsProbe]==0) ) | ( ([TrialsData.IsLateBlock]==1)&([TrialsData.IsProbe]==1) ) ) & ([TrialsData.IsHit]==1) & (picked_Stim1Ori_trials==1);
        early_blocks_miss_trials = (( ([TrialsData.IsEarlyBlock]==1)&([TrialsData.IsProbe]==0) ) | ( ([TrialsData.IsLateBlock]==1)&([TrialsData.IsProbe]==1) ) ) & ([TrialsData.IsMiss]==1) & (picked_Stim1Ori_trials==1);

        late_blocks_hit_trials = (( ([TrialsData.IsEarlyBlock]==1)&([TrialsData.IsProbe]==1) ) | ( ([TrialsData.IsLateBlock]==1)&([TrialsData.IsProbe]==0) ) ) & ([TrialsData.IsHit]==1) & (picked_Stim1Ori_trials==1);
        late_blocks_miss_trials = (( ([TrialsData.IsEarlyBlock]==1)&([TrialsData.IsProbe]==1) ) | ( ([TrialsData.IsLateBlock]==1)&([TrialsData.IsProbe]==0) ) ) & ([TrialsData.IsMiss]==1) & (picked_Stim1Ori_trials==1);
        
        [TF_incr_frame_times, TF_decr_frame_times, TF_incr_frame_ind, TF_decr_frame_ind]  = get_TF_pulses(TrialsData, Change_ON_dur, frame_times, 1.5, PSTHwindow(2), 1:trials_numb);
        
%% aligned to Baseline
% % 
%         EventTimes = Baseline_ON_times;
%         TrialGroups = zeros(1, trials_numb);
% 
%         TrialGroups(early_blocks_hit_trials==1) = 1;
%         TrialGroups(late_blocks_hit_trials==1) = 2;
%         
%         TrialGroups(early_blocks_miss_trials==1) = 3;
%         TrialGroups(late_blocks_miss_trials==1) = 4;

%% aligned to early licks

        EventTimes = Airpuff_times;
        TrialGroups = zeros(1, trials_numb);
        early_lick_trials = (ReactionTimesFA >2); % exclude impulsive licks
        TrialGroups(early_lick_trials) = 1;

%% aligned to TF pulse increase vs decrease

%         EventTimes = [cell2mat(TF_incr_frame_times(:)')  cell2mat(TF_decr_frame_times(:)')];
%         TrialGroups = ones(1, length(EventTimes));
%         TrialGroups(1+length(cell2mat(TF_incr_frame_times(:)')):end) = 2;   % decreases in TF

%% aligned to TF pulse increase, parsed by phase at which TF pulse occured 
% 
%         EventTimes = [cell2mat(TF_incr_frame_times(:)')  cell2mat(TF_decr_frame_times(:)')];
%         tr_to_use = find(sum((Stim1Ori==Stim1Ori_use'), 1) == 1);      
%         TF_incr_frame_ind = TF_incr_frame_ind(tr_to_use);   
%         TF_incr_frame_times = TF_incr_frame_times(tr_to_use);     
%         phase = phase(tr_to_use);     
%        
%         EventTimes = [cell2mat(TF_incr_frame_times(:)')];
%         TrialGroups = zeros(1, length(EventTimes));
%         
%         phase_at_TF_increase = [];
%         for tr = 1:length(TF_incr_frame_times)
%             TF_incr_frame_ind_tr = TF_incr_frame_ind{tr};
%             phase_tr = phase{tr}(:,1);
%             ind = find(phase_tr>0, 1, 'first');
%             phase_tr = phase_tr(ind-1:end); % skip pre-baseline
%             phase_tr = mod(phase_tr, 360);
%             for fr = 1:length(TF_incr_frame_ind_tr)
%                 phase_at_TF_increase = [phase_at_TF_increase phase_tr(TF_incr_frame_ind_tr(fr))];
%             end
%         end
%          
%         phase_bin = 90;
%         phase_bins = 0:phase_bin:360;
%         for ph = 1:length(phase_bins)-1
%             phases_in_bin_ind = find(phase_at_TF_increase>=phase_bins(ph)&phase_at_TF_increase<phase_bins(ph+1));
%             TrialGroups(phases_in_bin_ind) = ph;
%         end

       
%% aligned to Change onset, parsed by Change magnitude

%         EventTimes = Change_ON_times;
%         Change_magn_types = unique(Change_magn);
%         TrialGroups = zeros(1, trials_numb);
% 
% %         Change_magn_types(Change_magn_types==1) = [];   % deleting no change trials
%  
%         for ch = 1:6
%             if ch ==1
%                 TrialGroups( (Change_magn==Change_magn_types(ch)) & ([TrialsData.IsMiss]==1)) = 1;
%             else
%                 if ch < 5 % two groups of change strength
%                     TrialGroups( (Change_magn==Change_magn_types(ch)) & ([TrialsData.IsHit]==1)) = 2;
%                 else
%                     TrialGroups( (Change_magn==Change_magn_types(ch)) & ([TrialsData.IsHit]==1) ) = 3;
%                 end
%     %             TrialGroups( (Change_magn==Change_magn_types(ch)) & ([TrialsData.IsHit]==1)) = ch;
%             end
%         end
%%
        
        not_used_tr_ind = find(TrialGroups==0);
        TrialGroups(not_used_tr_ind) = [];
        EventTimes(not_used_tr_ind) = [];
%                 
        for p = 1 %which probe
            sp = data.(subjects{i}).(sessions{j}).NPX_probes(p);
            
%             good_and_stable_clusters = data.(subjects{i}).(sessions{j}).NPX_probes(p).cluster_id_KS_good;
            good_and_stable_clusters = data.(subjects{i}).(sessions{j}).NPX_probes(p).cluster_id_good_and_stable;  

            try     % if probe track tracing has been done
                good_and_stab_units_coord = data.(subjects{i}).(sessions{j}).NPX_probes(p).good_and_stab_cl_coord ;          
                good_and_stable_cl_depths = -[good_and_stab_units_coord.z];
            catch
                good_and_stable_cl_depths = round(data.(subjects{i}).(sessions{j}).NPX_probes(p).templateDepths);
            end
            
            sp.clu_good = ( NaN(length(sp.clu), 1) );
            
            for cl = 1:length(good_and_stable_clusters)
                sp.clu_good( find(sp.clu == good_and_stable_clusters(cl)) ) = good_and_stable_clusters(cl);       % spike times of specific clusters
            end
                                    
        end

        psthViewer2(sp.st, sp.clu_good, EventTimes, PSTHwindow, TrialGroups, good_and_stable_cl_depths, 25, 1);
% 
    end

end

