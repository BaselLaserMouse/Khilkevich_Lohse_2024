function [AllEventTimes]=FindEventsfromNPXv4Naive(NIdaq_events)
% 1. reward time
% 2: baseline start
% 3: change start
% 4: lick time
% 5: airpuff


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


for T=1:length(NIdaq_events.Baseline_ON.rise_t)
    
    % find trial specific lick times
     clear LickTimeIdx
     LickTimeIdx=find(NIdaq_events.initLickTimes > NIdaq_events.Baseline_ON.rise_t(T) & NIdaq_events.initLickTimes < NIdaq_events.Change_ON.fall_t(T));
     
    if isempty(LickTimeIdx)
        AllEventTimes{4}(T,1:3)=NaN;
    elseif length(LickTimeIdx) ==1
        AllEventTimes{4}(T,1:3)=[NIdaq_events.initLickTimes(LickTimeIdx)' NaN NaN]; % get piezo lick times
           elseif length(LickTimeIdx) ==2
        AllEventTimes{4}(T,1:3)=[NIdaq_events.initLickTimes(LickTimeIdx)' NaN]; % get piezo lick times
           elseif length(LickTimeIdx) ==3
        AllEventTimes{4}(T,1:3)=NIdaq_events.initLickTimes(LickTimeIdx)'; % get piezo lick times
    end
end

for T=1:length(NIdaq_events.Air_puff.rise_t)
    
    if isempty(NIdaq_events.Air_puff.rise_t(T))
        AllEventTimes{5}(T)=NaN;
    else
        AllEventTimes{5}(T)=NIdaq_events.Air_puff.rise_t(T); % get airpuff times
    end
end


 