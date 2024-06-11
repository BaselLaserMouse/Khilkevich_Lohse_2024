function [HitTrials,RT,BaseTFvals,BaseOri,BaseTime,FastPulseTime,SlowPulseTime]  = FindSessionDatav4(Behav_data)

for T=1:length(Behav_data.trials_data_exp)
    HitTrials(T)=Behav_data.trials_data_exp(T).trialoutcome(1)=='H'; % TODO: double check if there are other otcomes that start with H
    RT(T)=Behav_data.trials_data_exp(T).reactiontimes.RT;
    TFTemp=Behav_data.trials_data_exp(T).TF(Behav_data.trials_data_exp(T).TF>0);
    
    if strcmp(Behav_data.trials_data_exp(T).trialoutcome,'abort') || strcmp(Behav_data.trials_data_exp(T).trialoutcome,'FA')
        BaseTFvals{T}=TFTemp; % Finding ales for each of the drfting speeds (TF) assuming each TF value is 3 frames lng with a 16.66 ms refrs rate
    else
        BaseTFvals{T}=TFTemp(1:3:round(Behav_data.trials_data_exp(T).stimT/(0.1/6))); % Finding ales for each of the drfting speeds (TF) assuming each TF value is 3 frames lng with a 16.66 ms refrs rate
    end
    
    BaseTime(T)=Behav_data.trials_data_exp(T).stimT; % Finding ales for each of the drfting speeds (TF) assuming each TF value is 3 frames lng with a 16.66 ms refrs rate
    BaseOri(T) = Behav_data.trials_data_exp(T).Stim1Ori; % Orientation of stimulus
    FastPulseTime{T}=(find(BaseTFvals{T}>1.25)*50)-50; % each pulse lasts 50 ms;
    SlowPulseTime{T}=(find(BaseTFvals{T}<0.75) * 50)-50;% each pulse lasts 50 ms;
end

