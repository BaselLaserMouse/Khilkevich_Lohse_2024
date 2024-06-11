function [EphysData,BehavData,HitTrials,nTrialsHit,nTrials]=loadEventGLMData(ephysFolder)

BehavData=QuickPerformance([ephysFolder 'Session'],0,0) % prompts you to find matching behaviour file

EphysData=SpikeimportBasic({ephysFolder},[-1.5 20],0.001,15)

HitTrials=find(BehavData.Raw.Corr)
nTrialsHit=length(HitTrials)
nTrials=length(BehavData.Raw.Corr);
