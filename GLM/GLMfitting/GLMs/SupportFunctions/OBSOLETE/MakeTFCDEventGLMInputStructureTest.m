function [trial,param]=MakeTFCDEventGLMInputStructure(EphysData,BehavData,HitTrials,nTrials,curClu,ephysFolder)
%% Create trial structure for TFCD event GLM for neuropixel recordings
% REQUIRES stat toolbox for poissnrnd

%% input override
BehavData.Raw.BaseT>1.5
for T=1:270
   Incl(T)=round((length(find(BehavData.Raw.TF{T}~=0))*0.016666666666666666666)*1000)>1500 
    
end

HitTrials=find(Incl) % currently overriding hittrials wit all trials
nTrials=length(HitTrials)
%%



tempcoupleClu=curClu+1

%% trial aligned lick and reward times
[~,TrialLickTimesTemp]=alignedPSTH(EphysData.AllEventTimes{4},EphysData.AllEventTimes{2},[0 30],.05,length(EphysData.AllEventTimes{2}),10,'gaussian');
[~,TrialRewTimesTemp]=alignedPSTH(EphysData.AllEventTimes{1},EphysData.AllEventTimes{2},[0 30],.05,length(EphysData.AllEventTimes{2}),10,'gaussian');

for T=1:length(HitTrials)
    hitTrialId=HitTrials(T)
    TrialLickTimes{T}=TrialLickTimesTemp{hitTrialId}(find(TrialLickTimesTemp{hitTrialId}<(length(find(BehavData.Raw.TF{hitTrialId}~=0))*0.016666666666666666666)+1));
   % TrialRewTimes(T)=TrialRewTimesTemp{hitTrialId}(find(TrialRewTimesTemp{hitTrialId}<(length(find(BehavData.Raw.TF{hitTrialId}~=0))*0.016666666666666666666)+1))
   % for some reason reards are not always registerd on hit trials (double
   % check this). work around for now s this
   if isempty(TrialLickTimesTemp{hitTrialId})
        TrialRewTimes(T)=NaN;
   else
         TrialRewTimes(T)=TrialLickTimesTemp{hitTrialId}(1);
 
   end

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
    FrameTFs=BehavData.Raw.TF{hitTrialId}(find(BehavData.Raw.TF{hitTrialId}~=0));
    PulseTFsMat=reshape(FrameTFs,3,Frames/3);
    msTFsMat=(repmat(PulseTFsMat(1,:),50,1));
    clear instantTFs
    instantTFs=zscore(msTFsMat(:));
    instantTFs(floor(BehavData.Raw.BaseT(hitTrialId)*1000):end)=0;
    % instantTFs(1:1000)=0;

    trial(curTrial).instantTF = instantTFs;
    %    tstep=[1:50:1000];
    %    nsteps=10;
%    trial(curTrial).instantTFHis=zeros(length(instantTFs),nsteps)
%    for t=1:10
%     trial(curTrial).instantTFHis(tstep(t):end,t) = instantTFs(1:end-tstep(t)+1);
%    end
    

    clear Frames FrameTFs PulseTFsMat msTFsMat

    trial(curTrial).baseON = 0; % everything is aligned to 1 second prior to stim onset (prestim time0, to avoid negative spike time values
    trial(curTrial).baseBaselineON1 = 1750; %
    trial(curTrial).baseBaselineON2 = 2250; % 
    trial(curTrial).baseBaselineON3 = 2750; % 
    trial(curTrial).baseBaselineON4 = 3250; % 
    trial(curTrial).baseBaselineON5 = 3750; % 
    trial(curTrial).baseBaselineONRem=1500; %
    
    if BehavData.Raw.BaseT>  trial(curTrial).duration/1000
            trial(curTrial).changeON = [];
    trial(curTrial).changeOFF =  [];
    trial(curTrial).baseOFF =  trial(curTrial).duration;

    else
            trial(curTrial).changeON = BehavData.Raw.BaseT(hitTrialId)*1000;
    trial(curTrial).changeOFF =  trial(curTrial).duration;
        trial(curTrial).baseOFF =  trial(curTrial).changeON;


    end
    
    if isnan(TrialRewTimes(curTrial))
       trial(curTrial).lick = []; % first lick in a hit trial (initiating a reward)

    else
    trial(curTrial).lick = TrialRewTimes(curTrial)*1000; % first lick in a hit trial (initiating a reward)
    end
    trial(curTrial).changeTF = BehavData.Raw.changeTF{hitTrialId};
    trial(curTrial).orientation = BehavData.Raw.Ori{hitTrialId};
    trial(curTrial).sptrain = EphysData.Clu(curClu).eventGLMtrialST{hitTrialId}(find((EphysData.Clu(curClu).eventGLMtrialST{hitTrialId}*1000)<trial(curTrial).duration))*1000;
    %trial(curTrial).sptrain2 = EphysData.Clu(tempcoupleClu).eventGLMtrialST{hitTrialId}(find((EphysData.Clu(tempcoupleClu).eventGLMtrialST{hitTrialId}*1000)<trial(curTrial).duration))*1000; % this is going to be for spike trains frm additional neurons for coupling estimation
    
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


