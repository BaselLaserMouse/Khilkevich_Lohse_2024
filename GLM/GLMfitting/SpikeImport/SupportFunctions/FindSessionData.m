function [HitTrials,RT,BaseTFvals,BaseOri,BaseTime,FastPulseTime,SlowPulseTime,TrialData,SessionSettings,ComputerSettings]  = FindSessionData(folderSorted,Runs);

cd(folderSorted)
cd .. % Expects he session folder to be on a different path branch than he ephys
cd('Session')

if Runs == 1
    fname=dir('*trials.json');
    TrialData = jsondecode(fileread(fname(1).name)); % loads in part 1, if here are w parts, that needs to be accounted for.
    clear fname
    
    fname=dir('*session_settings.json');
    SessionSettings = jsondecode(fileread(fname(1).name));
    clear fname
    
    fname=dir('*computer_settings.json');
    ComputerSettings = jsondecode(fileread(fname(1).name));
    clear fname
    for T=1:length(TrialData)
        HitTrials(T)=TrialData(T).trialoutcome(1)=='H'; % TODO: double check if there are other otcomes that start with H
        RT(T)=TrialData(T).reactiontimes.RT; 
        BaseTFvals{T}=TrialData(T).St1TrialVector(1:3:floor(TrialData(T).stimT/(0.1/6))); % Finding ales for each of the drfting speeds (TF) assuming each TF value is 3 frames lng with a 16.66 ms refrs rate 
        BaseTime(T)=TrialData(T).stimT; % Finding ales for each of the drfting speeds (TF) assuming each TF value is 3 frames lng with a 16.66 ms refrs rate 
        FastPulseTime(T)=BaseTFvals{T}>1.5; % Finding ales for each of the drfting speeds (TF) assuming each TF value is 3 frames lng with a 16.66 ms refrs rate 
        SlowPulseTime(T)=BaseTFvals{T}<-1.5;
    end

    BaseOri = [TrialData.Stim1Ori]; % Orientation of stimulus
   
else
    for R=1:Runs
        fname=dir('*trials.json');
        TrialData{R} = jsondecode(fileread(fname(R).name)); % loads in part 1, if here are w parts, that needs to be accounted for.
        clear fname
        
        fname=dir('*session_settings.json');
        SessionSettings{R} = jsondecode(fileread(fname(R).name));
        clear fname
        
        fname=dir('*computer_settings.json');
        ComputerSettings{R} = jsondecode(fileread(fname(R).name));
        clear fname
        
        for T=1:length(TrialData{R})
            HitTrialsTemp{R}(T)=TrialData{R}(T).trialoutcome(1)=='H'; % TODO: double check if there are other otcomes that start with H
            RTTemp{R}(T)=TrialData{R}(T).reactiontimes.RT; % TODO: double check if there are other otcomes that start with H
            BaseTFvalsTemp{R}{T}=TrialData{R}(T).St1TrialVector(1:3:floor(TrialData{R}(T).stimT/(0.1/6))); % assuming each TF value is 3 frames lng with a 16.66 ms refrs rate 
            BaseTimeTemp{R}(T)=TrialData{R}(T).stimT; % Finding ales for each of the drfting speeds (TF)
        end     
        BaseOriTemp{R} = [TrialData{R}.Stim1Ori];
    end

HitTrials=[HitTrialsTemp{:}];
RT=[RTTemp{:}];
BaseTFvals=[BaseTFvalsTemp{:}];
BaseTime=[BaseTimeTemp{:}];
BaseOri = [BaseOriTemp{:}];

end


%fsm=[TrialData{:}] % if the json gives cells