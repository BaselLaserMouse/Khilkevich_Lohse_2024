function []= NaiveEventGLMWrapperArbitraryBinningFullModelBlocksBATCHRUNv5(SubjectName)

% V5 is from 05/22, and runs the full GLM while using bothhidden licks and
% early licks as earcly licks


close all

addpath(genpath('~/GLMfitting'))

%% First load in all data with loadallsessions function %% make this automatic

data=GetPreloadedAnimalNaive(SubjectName);

SubjectIds=fieldnames(data);

%% if loading multiple subjcts and sessions
% MetaData.ResultsFolder='/mnt/data/mlohse/GLMFilesJan2021';
% MetaData.SubId=SubjectId;
% MetaData.SessId=SessionId;
% MetaData.ProbeNo=ProbeNumber;
%SessionIds{MetaData.SubId}=fieldnames(data.(SubjectIds{1}));
%SessionSelected=data.(SubjectIds{MetaData.SubId}).(SessionIds{MetaData.SubId}{MetaData.SessId});

%% if loading one subjct and one session at a time (for batch script)
MetaData.ResultsFolder='...GLMOutputs/August2022_Final/Naive/'; % output folder
MetaData.SubId=1;
MetaData.SessId=1;
SessionIds{1}=fieldnames(data.(SubjectIds{1}));

for SessionNo=8:length(SessionIds{1})
    clearvars -except SessionIds MetaData SubjectIds data SessionNo
    
    SessionSelected=data.(SubjectIds{1}).(SessionIds{1}{SessionNo}); % if using batch when nly loading one subject at a time
    MetaData.Completed=0;
    
    for ProbeNumber =1:length(SessionSelected.NPX_probes)
        clearvars -except SessionIds MetaData SubjectIds data ProbeNumber SessionNo SessionSelected
        MetaData.ProbeNo=ProbeNumber;
        
        disp(['Subject: ' SubjectIds{MetaData.SubId} ' - Session: ' SessionSelected.behav_data.SessionSettings.token ' - Probe No: ' num2str(MetaData.ProbeNo)])
        
        GoodClustersToRun=1:length(SessionSelected.NPX_probes(ProbeNumber).cluster_id_good_and_stable);
        
        
        %% Setup
        MetaData.ExpName=SessionSelected.behav_data.SessionSettings.token;
        
        [EphysData,BehavData,VideoData,MetaData.HitTrials,MetaData.nTrialsHit,MetaData.nTrials]=loadEventGLMDatav4Naive(SessionSelected,MetaData.ProbeNo,GoodClustersToRun);
        
        MetaData.RunCV=1; % run cross validation
        
        PredictorParams.onlyHit=0; % all trials (0), or only hit trials (1), if only hit trials: turn also of abort and airpuff kernels
        PredictorParams.excludeMiss=0; %set to 1 if you want to eclude all trials where mouse did not do anything
        PredictorParams.alpha=0; % Regularization type:  1 is lasso %between 0 and 1 is elnet, 0 is ridge
        %% Binning
        PredictorParams.binSize=50;% bin size (has to be a round number)
        PredictorParams.weightwidth=1; %number of bins each time in history spans
        PredictorParams.PredSmth=1;% smoothing of y in bins during prediction
        PredictorParams.UseBasis=0;
        
        %% Models to run
        
        disp('Running Full Model')
        NaiveFullModelSubscript
        disp('Full Model Completed')
        
        clearvars -except PredictorParams MetaData SessionSelected SessionIds SubjectIds data GoodClustersToRun SubjectName SessionNo ProbeNumber EphysData BehavData VideoData
        MetaData.Completed=0;
        disp('Running Reduced (TF) Model')
        NaiveReduced_TF_ModelSubscript
        disp('Reduced (TF) Model Completed')
        
        clearvars -except PredictorParams MetaData SessionSelected SessionIds SubjectIds data GoodClustersToRun SubjectName SessionNo ProbeNumber EphysData BehavData VideoData
        MetaData.Completed=0;
        disp('Running Reduced (PreLick) Model')
        NaiveReduced_PreLick_ModelSubscript
        disp('Reduced (PreLick) Model Completed')
        
        
        clearvars -except PredictorParams MetaData SessionSelected SessionIds SubjectIds data GoodClustersToRun SubjectName SessionNo ProbeNumber EphysData BehavData VideoData
        MetaData.Completed=0;
        disp('Running Reduced (Movement) Model')
        NaiveReduced_Movement_ModelSubscript
        disp('Reduced (Movement) Model Completed')
        
        % clearvars -except PredictorParams MetaData SessionSelected SessionIds SubjectIds data GoodClustersToRun SubjectName SessionNo ProbeNumber EphysData BehavData VideoData
        % MetaData.Completed=0;
        % disp('Running Baseline Only (Slow and Fast separate) Model')
        % NaiveBaselineOnly_ModelSubscript
        % disp('Baseline Only Model (Slow and Fast separate) Completed')
    end
end
end
