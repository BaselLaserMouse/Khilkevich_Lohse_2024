function [rise_t, fall_t, duration] = get_event_times_threshold(channel, ch_type, threshold, NI_sample_rate)

%   get onset, offset and duration times of events

if ( strcmp(ch_type, 'D') )||( strcmp(ch_type, 'A') ) == 1

    if strcmp(ch_type, 'A') == 1
        channel = (channel>=threshold);
    end
    
    d_ch = diff(int8(channel))';
        bOn = find(d_ch>0); 
        bOff = find(d_ch<0);
        
        rise_t = bOn/NI_sample_rate;  % on times
        fall_t = bOff/NI_sample_rate; % off times
        
        full_ev_numb = min([length(rise_t) length(fall_t) ]);   
        
        if length(rise_t)>=length(fall_t)
            duration = fall_t(1:full_ev_numb) - rise_t(1:full_ev_numb); % duration from on to off
        else
            duration = fall_t(2:full_ev_numb+1) - rise_t(1:full_ev_numb); % in case line starts on high state
        end
else
    disp('Channel type has to be analog (A) or digital (D)')
end
    
end

