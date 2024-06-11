function [meanPSTH,TrialST,TrialPSTH,edges]=alignedPSTH(SpikeTimes,Events,Window,Bin,nTrials,smoothing,smoothtype)
% function for creating PSTHs aligned to a particular event
% ML 2020

edges=[Window(1):Bin:Window(2)];

for T=1:nTrials
    
    StimAlignedST=SpikeTimes-(Events(T)); % align all spiketimes the event
    TrialST{T}=StimAlignedST(find(StimAlignedST>Window(1) & StimAlignedST<Window(2))); % spike times (around a given window) aligned to event

  
    if isnan(Events(T))
        TrialPSTH(T,:)=nan(1,length(edges));
    else
        TrialPSTH(T,:)=histc(TrialST{T}, edges)./Bin;  % Single trial psths at Bin (given in seconds) resolution - in sp/s
    end
    clear StimAlignedST
end

meanPSTH=smoothdata(nanmean(TrialPSTH),smoothtype,smoothing); % smoothed PSTH

