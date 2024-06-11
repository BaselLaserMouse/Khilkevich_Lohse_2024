function [trial,param]=MakeTFCDEventGLMInputStructure(EphysData,BehavData,HitTrials,nTrials,curClu,ephysFolder)
%% Create trial structure for TFCD event GLM for neuropixel recordings



tempcoupleClu=curClu+1;

%% trial aligned lick and reward times
[~,TrialLickTimesTemp]=alignedPSTH(EphysData.AllEventTimes{4},EphysData.AllEventTimes{2},[0 30],.05,length(EphysData.AllEventTimes{2}),10,'gaussian');
[~,TrialRewTimesTemp]=alignedPSTH(EphysData.AllEventTimes{1},EphysData.AllEventTimes{2},[0 30],.05,length(EphysData.AllEventTimes{2}),10,'gaussian');

for T=1:length(HitTrials)
    hitTrialId=HitTrials(T);
    TrialLickTimes{T}=TrialLickTimesTemp{hitTrialId}(find(TrialLickTimesTemp{hitTrialId}<(length(find(BehavData.Raw.TF{hitTrialId}~=0))*0.016666666666666666666)+1));
   % TrialRewTimes(T)=TrialRewTimesTemp{hitTrialId}(find(TrialRewTimesTemp{hitTrialId}<(length(find(BehavData.Raw.TF{hitTrialId}~=0))*0.016666666666666666666)+1))
   % for some reason reards are not always registerd on hit trials (double
   % check this). work around for now s this
   TrialRewTimes(T)=TrialLickTimesTemp{hitTrialId}(1);

   clear hitTrialId
end
clear TrialRewTimesTemp TrialLickTimesTemp 



% preallocate structure in memory
trial = struct();
trial(nTrials).duration = 0; % preallocate

for curTrial = 1:nTrials
     hitTrialId=HitTrials(curTrial);

    trial(curTrial).duration = round((length(find(BehavData.Raw.TF{hitTrialId}~=0))*0.016666666666666666666)*1000);
    
    % resmaple stim from frames into ms
    Frames=length(BehavData.Raw.TF{hitTrialId}(find(BehavData.Raw.TF{hitTrialId}~=0)));
    clear instantTFs
    instantTFs=BehavData.Raw.TF{hitTrialId}(find(BehavData.Raw.TF{hitTrialId}~=0));
    instantTFs(floor((BehavData.Raw.BaseT(hitTrialId))/0.0166666666):end)=1;
    instantTFs=zscore(instantTFs);

    trial(curTrial).instantTF = instantTFs;


    clear Frames FrameTFs PulseTFsMat msTFsMat

    trial(curTrial).baseON = 0; % everything is aligned to 1 second prior to stim onset (prestim time0, to avoid negative spike time values
    trial(curTrial).baseBaselineON=1500; %
    trial(curTrial).changeON = BehavData.Raw.BaseT(hitTrialId)*1000;
    trial(curTrial).changeOFF =  trial(curTrial).duration;
    trial(curTrial).reward = TrialRewTimes(curTrial)*1000; % first lick in a hit trial (initiating a reward)
    trial(curTrial).changeTF = BehavData.Raw.changeTF{hitTrialId};
    trial(curTrial).orientation = BehavData.Raw.Ori{hitTrialId};
    trial(curTrial).sptrain = EphysData.Clu(curClu).eventGLMtrialST{hitTrialId}(find((EphysData.Clu(curClu).eventGLMtrialST{hitTrialId}*1000)<trial(curTrial).duration))*1000;
   % trial(curTrial).sptrain2 = EphysData.Clu(tempcoupleClu).eventGLMtrialST{hitTrialId}(find((EphysData.Clu(tempcoupleClu).eventGLMtrialST{hitTrialId}*1000)<trial(curTrial).duration))*1000; % this is going to be for spike trains frm additional neurons for coupling estimation
    
%     trial(curTrial).baseON = 500; % everything is aligned to 1 second prior to stim onset (prestim time0, to avoid negative spike time values
%     trial(curTrial).baseBaselineON = 2000; % everything is aligned to 1 second prior to stim onset (prestim time0, to avoid negative spike time values
%     trial(curTrial).changeON = (BehavData.Raw.BaseT(hitTrialId)*1000)+500;
%     trial(curTrial).changeOFF =  trial(curTrial).duration;
%     trial(curTrial).lick = TrialRewTimes(curTrial)*1000; % first lick in a hit trial (initiating a reward)
%     trial(curTrial).changeTF = BehavData.Raw.changeTF{hitTrialId};
%     trial(curTrial).orientation = BehavData.Raw.Ori{hitTrialId};
%     trial(curTrial).sptrain = EphysData.Clu(curClu).eventGLMtrialST{hitTrialId}(find((EphysData.Clu(curClu).eventGLMtrialST{hitTrialId}*1000)<trial(curTrial).duration))*1000;
%     trial(curTrial).sptrain2 = EphysData.Clu(tempcoupleClu).eventGLMtrialST{hitTrialId}(find((EphysData.Clu(tempcoupleClu).eventGLMtrialST{hitTrialId}*1000)<trial(curTrial).duration))*1000; % this is going to be for spike trains frm additional neurons for coupling estimation
    


    clear BaseFrames
end

param.ephysFolder = ephysFolder;
param.Clu = curClu;
param.CoupleClu = tempcoupleClu;


