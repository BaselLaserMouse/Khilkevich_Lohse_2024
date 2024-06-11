function [AllEventTimes]=FindEventsfromNPXv2(NIdaq_events)
% 1. reward time
% 2: baseline start
% 3: change start
% 4: lick time


for T=1:length(NIdaq_events.Baseline_ON.rise_t)
    
    
    AllEventTimes{2}(T)=NIdaq_events.Baseline_ON.rise_t(T); % get timings from photodiode
    
    if isempty(NIdaq_events.Change_ON.rise_t(T))
        AllEventTimes{3}(T)=NaN;
    else
        AllEventTimes{3}(T)=NIdaq_events.Change_ON.rise_t(T); % get timings from photodiode
    end
    
end

for T=1:length(NIdaq_events.Valve_L.rise_t)
    
    if isempty(NIdaq_events.Valve_L.rise_t(T))
        AllEventTimes{1}(T)=NaN;
    else
        AllEventTimes{1}(T)=NIdaq_events.Valve_L.rise_t(T); % get reward times
    end
end


for T=1:length(NIdaq_events.Lick_L.rise_t)
    
    if isempty(NIdaq_events.Lick_L.rise_t(T))
        AllEventTimes{4}(T)=NaN;
    else
        AllEventTimes{4}(T)=NIdaq_events.Lick_L.rise_t(T); % get lick times
    end
end

 