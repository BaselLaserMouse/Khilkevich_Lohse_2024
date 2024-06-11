function [HitTrials,RT,BaseTFvals,BaseOri,BaseTime,TrialData,FastPulseTime,SlowPulseTime,SessionSettings,ComputerSettings]  = FindSessionData(folderSorted,Runs);

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
        BaseTFvals{T}=TrialData(T).St1TrialVector(1:3:floor(TrialData(1).stimT/(0.1/6))); % Finding ales for each of the drfting speeds (TF) assuming each TF value is 3 frames lng with a 16.66 ms refrs rate 
        BaseTime(T)=TrialData(T).stimT; % Finding ales for each of the drfting speeds (TF) assuming each TF value is 3 frames lng with a 16.66 ms refrs rate 
        BaseOri(T) = TrialData(T).Stim1Ori; % Orientation of stimulus
        LaserOn(T) = TrialData(T).LaserOn; % Orientation of stimulus

       % FastPulseTime{T}=(find(BaseTFvals{T}>1.25)*50)-50; % each pulse lasts 50 ms; 
      %  SlowPulseTime{T}=(find(BaseTFvals{T}<0.75) * 50)-50;% each pulse lasts 50 ms; 
    end

   
else
        error('multisession extraction currently undergoing maintanence')

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
            HitTrialsTemp{R}(T)=TrialData{R}{1}.trialoutcome(1)=='H'; % TODO: double check if there are other otcomes that start with H
            RTTemp{R}(T)=TrialData{R}{1}.reactiontimes.RT; % TODO: double check if there are other otcomes that start with H
            BaseTFvalsTemp{R}{T}=TrialData{R}{1}.St1TrialVector(1:3:floor(TrialData{R}{1}.stimT/(0.1/6))); % assuming each TF value is 3 frames lng with a 16.66 ms refrs rate 
            BaseTimeTemp{R}(T)=TrialData{R}{1}.stimT; % Finding ales for each of the drfting speeds (TF)
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