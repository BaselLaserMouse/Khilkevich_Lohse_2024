function [trial,param]=MakeTFCDEventGLMInputStructurev3(EphysData,BehavData,VideoData,HitTrials,nTrials,curClu,binSize,ExpName,ProbeNo,onlyHit,excludeMiss)
%% Create trial structure for TFCD event GLM for neuropixel recordings

% preallocate structure in memory
trial = struct();

curTrial=0;
for SelectTrial = 1:nTrials
    
    %% skip trials with no estimatable motion onsets
    if isnan(BehavData.Raw.RT(SelectTrial)) 
       continue 
    end
    
    if excludeMiss %%
        if BehavData.Raw.changeTF{SelectTrial} == 1
            % if there was no change, the misses means the animal did what he
            % was trained to
        else
            if BehavData.Raw.Miss(SelectTrial)==1
                continue
            end
        end
    end
    
    if onlyHit ==1%% only select hit trials
        if BehavData.Raw.Corr(SelectTrial)==0
            continue
        else
            curTrial=curTrial+1;
        end
    else
        
        %% if the trial is ended before 1500ms, skip it
        if round((length(find(BehavData.Raw.TF{SelectTrial}~=0))*0.016666666666666666666)*1000)<1500
            continue
        else
            curTrial=curTrial+1;
        end
    end
    
    trial(curTrial).duration = round((length(find(BehavData.Raw.TF{SelectTrial}~=0 & ~isnan(BehavData.Raw.TF{SelectTrial})))*0.016666666666666666666)*1000);
    
    %% if the trial is early lick or aborted, skip everything related to what happens after change
    if BehavData.Raw.Abort(SelectTrial) > 0
        trial(curTrial).changeONleadup = NaN;
        trial(curTrial).changeON = NaN;
        trial(curTrial).changeOFF =  NaN;
        trial(curTrial).changeTF = 0;
        trial(curTrial).lick = NaN;
        trial(curTrial).Postlick = NaN;
        trial(curTrial).rew = NaN;
        trial(curTrial).airpuff = NaN;
 
        trial(curTrial).Abort = BehavData.Raw.RT(SelectTrial)*1000;
        trial(curTrial).baseOff = trial(curTrial).duration; 
        
    elseif BehavData.Raw.EarlyLick(SelectTrial) > 0
        trial(curTrial).changeONleadup = NaN;
        trial(curTrial).changeON = NaN;
        trial(curTrial).changeOFF =  NaN;
        trial(curTrial).changeTF = 0;
        trial(curTrial).rew = NaN;
        trial(curTrial).Abort = NaN;
                
        if BehavData.Raw.HiddenEarlyLick(SelectTrial)
            trial(curTrial).airpuff=NaN; %No airpuff on hidden early lick trials
        else
            trial(curTrial).airpuff = (EphysData.AllEventTimes{5}(SelectTrial)-EphysData.AllEventTimes{2}(SelectTrial))*1000;
        end
        
        trial(curTrial).lick = BehavData.Raw.RT(SelectTrial)*1000;
        trial(curTrial).Postlick = BehavData.Raw.RT(SelectTrial)*1000;
        trial(curTrial).baseOff = trial(curTrial).duration;
        
    else
        trial(curTrial).changeONleadup = (BehavData.Raw.BaseT(SelectTrial)*1000)-2000; % 2 seconds leading up to change point
        trial(curTrial).changeON = BehavData.Raw.BaseT(SelectTrial)*1000;
        trial(curTrial).changeOFF =  trial(curTrial).duration;
        trial(curTrial).changeTF = log2(BehavData.Raw.changeTF{SelectTrial}); % changes are converted to log scale
        trial(curTrial).baseOff = trial(curTrial).changeON;
        trial(curTrial).airpuff = NaN;

        %% if trial is a miss
        if BehavData.Raw.Miss(SelectTrial) >0
            trial(curTrial).lick = NaN; 
            trial(curTrial).Postlick = NaN; 
            trial(curTrial).rew = NaN;
            
        else
            % trial(curTrial).lick = TrialRewTimes(curTrial)*1000; % lick that initates the reward
            % trial(curTrial).rew = TrialRewTimes(curTrial)*1000;
            
          %  trial(curTrial).lick = (BehavData.Raw.RT(SelectTrial)+BehavData.Raw.BaseT(SelectTrial))*1000; % lick that initates the reward
          %  trial(curTrial).rew = (BehavData.Raw.RT(SelectTrial)+BehavData.Raw.BaseT(SelectTrial))*1000;
          
            trial(curTrial).lick = BehavData.Raw.RT(SelectTrial)*1000; % lick that initates the reward (reaction time is now motoin onset from trial start)
            trial(curTrial).Postlick = BehavData.Raw.RT(SelectTrial)*1000; % lick that initates the reward (reaction time is now motoin onset from trial start)
            trial(curTrial).rew = (EphysData.AllEventTimes{1}(SelectTrial)-EphysData.AllEventTimes{2}(SelectTrial))*1000;
        end
        
    end
    
    if ((BehavData.Raw.Abort(SelectTrial) == 1) + (BehavData.Raw.EarlyLick(SelectTrial) == 1))>0
            
            trial(curTrial).changeONForGraded = 0;
            trial(curTrial).changeOFFForGraded =  1;
    else
            trial(curTrial).changeONForGraded = BehavData.Raw.BaseT(SelectTrial)*1000;
            trial(curTrial).changeOFFForGraded =  trial(curTrial).duration;
    end
    
    trial(curTrial).Miss = BehavData.Raw.Miss(SelectTrial);

    IndieChangeKernels   % sperate predictors for eeach change size 
    %%
    Extract_TFs_For_Full_GLM 

    %%
    
    trial(curTrial).baseON = 0; 
    trial(curTrial).Baseline=1000; %
    
    %% Allocate bsaeline onsets for early and late blocks separately
    if BehavData.Raw.TempBlock(SelectTrial) ==0 % early block
        trial(curTrial).BaselineEarly=1000; %
        trial(curTrial).BaselineLate=NaN; %
    elseif BehavData.Raw.TempBlock(SelectTrial) ==1 % late block
        trial(curTrial).BaselineLate=1000; %
        trial(curTrial).BaselineEarly=NaN; %
    end
    
    trial(curTrial).orientation = BehavData.Raw.Ori{SelectTrial};
    trial(curTrial).sptrain = EphysData.Clu(curClu).eventGLMtrialST{SelectTrial}(find((EphysData.Clu(curClu).eventGLMtrialST{SelectTrial}*1000)<trial(curTrial).duration))*1000;
    
    %% MOVEMENT AND PUPIL
    clear FaceMotionEnergy FaceFrameTimes RawTrialStartTimes
    RawTrialStartTimes=EphysData.AllEventTimes{2}*1000;
    FaceFrameTimes=VideoData.FaceEnergyTimes*1000;
    FaceMotionEnergy=VideoData.FaceEnergyFiltered;
    
    trial(curTrial).FaceMovement=ExtractTrialVideoPredictor(RawTrialStartTimes,FaceFrameTimes,FaceMotionEnergy,curTrial,trial(curTrial).duration);
    
    clear PupilSize PupilFrameTimes RawTrialStartTimes
    RawTrialStartTimes=EphysData.AllEventTimes{2}*1000;
    PupilFrameTimes=VideoData.PupilTimesFiltered*1000;
    PupilSize=VideoData.PupilFiltered_smoothed;
    
    trial(curTrial).Pupil=ExtractTrialVideoPredictor(RawTrialStartTimes,PupilFrameTimes,PupilSize,curTrial,trial(curTrial).duration);
    trial(curTrial).Pupil(isnan(trial(curTrial).Pupil))=0;

    %% Running wheel
    clear RunSpeedTimeAxis RunSpeedAbs RawTrialStartTimes
    RawTrialStartTimes=EphysData.AllEventTimes{2}*1000;
    RunSpeed=(EphysData.RunningSpeed); %  speed 
    RunSpeedTimeAxis=EphysData.RunningSpeedtimeAxis;

    trial(curTrial).RunSpeed=ExtractTrialVideoPredictor(RawTrialStartTimes,RunSpeedTimeAxis.*1000,RunSpeed,curTrial,trial(curTrial).duration); % reuse this functin for running wheel
    
    % Parameters for estimating dm lengths in bins
    param.baselineBins(curTrial)=sum(trial(curTrial).instantTF~=0);
    param.TrialBins(curTrial)= trial(curTrial).duration/binSize;
    param.SelectedTrials(curTrial)= SelectTrial;
end

param.ephysFolder = ExpName;
param.ProbeNo=ProbeNo;
param.Clu = curClu;


