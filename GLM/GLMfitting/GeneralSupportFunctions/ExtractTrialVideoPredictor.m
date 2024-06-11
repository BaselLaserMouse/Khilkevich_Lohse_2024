function [TrialVideoValuesBinned,TrialVideoValuesRaw,TrialFrameTimes]=ExtractTrialVideoPredictor(TrialStartTimes,FrameTimes,VideoValues,curTrial,trialDuration)
%% Trial specific extration of video for GLM

   TrialStartTime=TrialStartTimes(curTrial);
   TrialAlignedVideoTimes=FrameTimes-TrialStartTime;
   
   try
   FrameTimeTrialIdx=find(TrialAlignedVideoTimes>0 & TrialAlignedVideoTimes<(trialDuration));
   TrialFrameTimes=TrialAlignedVideoTimes(FrameTimeTrialIdx);
   TrialVideoValuesRaw=VideoValues(FrameTimeTrialIdx);
   catch
       keyboard
   end
   %% parse out into 50 ms bins to mach the bin size
   t=0;
for B=1:50:trialDuration
    t=t+1;
    clear BWin
    BWin=find(TrialFrameTimes>=B & TrialFrameTimes<(B+50));
    TrialVideoValuesBinned(t)=mean(TrialVideoValuesRaw(BWin));
end

TrialVideoValuesBinned=TrialVideoValuesBinned'; % transpose
    

