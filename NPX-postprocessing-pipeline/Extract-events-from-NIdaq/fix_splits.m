function [event_fixed, splits_numb] = fix_splits(event_onset_times_orig, event_fall_times_orig, BaselineON_onset_times)
%   Stitch together fake splits in events
%   For currently unclear reason Teensy analog outputs occasionally have 1ms long drops in up state
%   The aim of this function is to stitch these splits together
%   Function requires true trial onset times and assumes that each event type (reward valve, air-puff, ChangeON signal etc ) occures once per trial 

trials_numb = length(BaselineON_onset_times);
event_onset_times_fixed = [];
event_offset_times_fixed = [];
event_duration_fixed = [];
splits_numb = 0;

for tr = 1:trials_numb
    if tr < trials_numb
        ev_ind_tr = find( (event_onset_times_orig >= BaselineON_onset_times(tr)) & (event_onset_times_orig < BaselineON_onset_times(tr+1)) );
    else
        ev_ind_tr = find( (event_onset_times_orig >= BaselineON_onset_times(tr)) & (event_onset_times_orig < (BaselineON_onset_times(tr)+60) ) );
    end
    
    if isempty(ev_ind_tr)
        event_onset_times_fixed(tr) = NaN;
        event_offset_times_fixed(tr) = NaN;
        event_duration_fixed(tr) = NaN;
    else
        if length(ev_ind_tr) > 1
            splits_numb = splits_numb + (length(ev_ind_tr)-1);
        end
        
        event_onset_times_fixed(tr) = event_onset_times_orig( ev_ind_tr(1) );
        event_offset_times_fixed(tr) = event_fall_times_orig( ev_ind_tr(end) );
        event_duration_fixed(tr) = event_offset_times_fixed(tr) - event_onset_times_fixed(tr);
    end
            
end

event_fixed.rise_t = event_onset_times_fixed;
event_fixed.fall_t = event_offset_times_fixed;
event_fixed.duration = event_duration_fixed;

end

