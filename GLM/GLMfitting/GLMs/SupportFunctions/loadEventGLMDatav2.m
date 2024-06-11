function [EphysData,BehavData,HitTrials,nTrialsHit,nTrials]=loadEventGLMDatav(Session,ProbeNo)
% V3 For selection of subeset of neurons fr batch script
BehavData=QuickPerformancev3(Session.behav_data.trials_data_exp,0);

EphysData=SpikeimportBasicv2(Session,ProbeNo,[-1.5 4],0.001,15)

HitTrials=find(BehavData.Raw.Corr);
nTrialsHit=length(HitTrials);
nTrials=length(BehavData.Raw.Corr);
