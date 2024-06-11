%% Predictors to include

%% Baseline only model
PredictorParams.BaselineOnly=0; % if you choose this keep BaseOn, Lick, Airpuff, Abort and Rew on, as these will be used to fully remove these preiods when this is set to 1

%% Full model parameters
PredictorParams.inclSpikeHist=0;
PredictorParams.inclTFfilter=1;
PredictorParams.Separate_SlowFast_TFFilters=0;
PredictorParams.inclBaseON=1;
PredictorParams.inclTiledBaseline=1;
PredictorParams.inclChangeLeadUp=0; % 2 seconds leading up to the change
PredictorParams.inclChangeON=1;
PredictorParams.inclLick=1;
PredictorParams.inclPostLick=0;
PredictorParams.inclAirpuff=1;
PredictorParams.inclRew=1;
PredictorParams.inclAbort=1;
PredictorParams.SingleChangeON=0;% if you only want to fit a single change onset across all conditions, with a separate change size kernel
PredictorParams.inclPhase=1;%
PredictorParams.BaselineBlocks=0;
PredictorParams.TF_Blocks=0; % 0 is no blocks, 1 is sepearated int blocks, 2 is one for early block and 2 for late block
PredictorParams.DriftDirection=0; %
PredictorParams.FaceMovement=0; %
PredictorParams.Pupil=1; %
PredictorParams.RunWheel=0; %


% if ~isfield(SessionSelected.)

%% Crossvalidation parameters
PredictorParams.n_kfold=10; %number of crossvalidations
clear CVstruct
CVstructcreated=0;
clear rawData Clu
close all

for curClu=1%GoodClustersToRun%1:length(EphysData.Clu)
    clear rawData Clu CV GLM dm dmTest Bestlambda
    cd(MetaData.ResultsFolder)
    tic
    
    %     MetaData.CluId=SessionSelected.NPX_probes(MetaData.ProbeNo).cluster_id_KS_good(curClu);
    %     MetaData.Region=SessionSelected.NPX_probes(MetaData.ProbeNo).good_cl_coord(curClu).brain_region;
    %     MetaData.xyz=[SessionSelected.NPX_probes(MetaData.ProbeNo).good_cl_coord(curClu).x,SessionSelected.NPX_probes(MetaData.ProbeNo).good_cl_coord(curClu).y,SessionSelected.NPX_probes(MetaData.ProbeNo).good_cl_coord(curClu).z];
    
    MetaData.CluId=SessionSelected.NPX_probes(MetaData.ProbeNo).cluster_id_good_and_stable(curClu);
    MetaData.Region=SessionSelected.NPX_probes(MetaData.ProbeNo).good_and_stab_cl_coord(curClu).brain_region;
    MetaData.xyz=[SessionSelected.NPX_probes(MetaData.ProbeNo).good_and_stab_cl_coord(curClu).x,SessionSelected.NPX_probes(MetaData.ProbeNo).good_and_stab_cl_coord(curClu).y,SessionSelected.NPX_probes(MetaData.ProbeNo).good_and_stab_cl_coord(curClu).z];
    
    if contains(MetaData.Region , '/' )
        backslash_pos=strfind(MetaData.Region , '/' );
        RegionName=MetaData.Region(setdiff(1:length( MetaData.Region),backslash_pos));
    else
        RegionName=MetaData.Region;
    end
    
    cd([MetaData.ResultsFolder '/ReducedMovement'])

%     if isfile(['ReducedMovement-'  RegionName '-' SubjectIds{MetaData.SubId} '-' SessionSelected.behav_data.SessionSettings.token '-ProbeNo_' num2str(MetaData.ProbeNo) '-CluId_' num2str(MetaData.CluId) '-GoodCluNo_' num2str(curClu) '.mat'])
%         toc
%         disp('Already Estimated')
%         
%         continue
%     end
    clear RegionName
    disp(['Fitting Cluster Id: ' num2str(MetaData.CluId) ' - Good Cluster No. ' num2str(curClu) '/' num2str(max(GoodClustersToRun))])
    
    [rawData.trial,rawData.param]=MakeTFCDEventGLMInputStructureFullBlocks(EphysData,BehavData,VideoData,MetaData.HitTrials,MetaData.nTrials,curClu,PredictorParams.binSize,MetaData.ExpName,MetaData.ProbeNo,PredictorParams.onlyHit,PredictorParams.excludeMiss);
    
    %% Estimate weights from all trials
    [Clu(1).model,Clu(1).ws,Clu(1).nCovar,dm,Clu(1).wml,Clu(1).dspec,Clu(1).expt,dmTest,Clu(1).y_hat_fit,~,Clu(1).y,~,Clu(1).FullFit,~,Clu(1).FullFitRMSE,~,Clu(1).fitoptions]=TFCD_eventGLM_FullBlocks(rawData,curClu,PredictorParams.alpha,1:length(rawData.trial),PredictorParams.binSize,PredictorParams.weightwidth,PredictorParams.PredSmth,0,PredictorParams.inclSpikeHist,PredictorParams.inclTFfilter,PredictorParams.inclBaseON,PredictorParams.inclTiledBaseline,PredictorParams.inclChangeLeadUp,PredictorParams.inclChangeON,PredictorParams.inclLick,PredictorParams.inclPostLick,PredictorParams.inclAirpuff,PredictorParams.inclRew,PredictorParams.inclAbort,PredictorParams.SingleChangeON,PredictorParams.BaselineBlocks,PredictorParams.TF_Blocks,PredictorParams.Separate_SlowFast_TFFilters,PredictorParams.DriftDirection,PredictorParams.UseBasis,PredictorParams.inclPhase,PredictorParams.FaceMovement,PredictorParams.Pupil,PredictorParams.RunWheel,PredictorParams.BaselineOnly);
    Bestlambda=Clu.model.lambda(Clu.model.lambda==Clu.model.lambda_min);
    %% Fit LN ouput nonlinearity
    %Clu(1).lnmodel = getlnmodel3(Clu(1).y_hat_fit, full(Clu(1).y));
    % Clu(1).y_hat_lnmodel = lnmodelresp(Clu(1).lnmodel.params, Clu(1).y_hat_fit);
    if MetaData.RunCV ==1
        
        rng(MetaData.CluId) % fix random seed (to cluid), so that te training data is the same no matter which iteation of the GLM you ru (for nested comparison)
        
        PredictorParams.CVstruct = cvpartition(length(rawData.trial),'KFold',PredictorParams.n_kfold);
        CVstructcreated=1;
        
        for c=1:PredictorParams.n_kfold % initialise viariales for parallel loop
            CV{c}=[];
            trainId{c}=[];
            CVPred{c}=[];
        end
        parfor c=1:PredictorParams.n_kfold % kfold crossvalidation
        % for c=1:PredictorParams.n_kfold % kfold crossvalidation

            disp(['k-fold ' num2str(c)])
            trainId{c}=find(training(PredictorParams.CVstruct,c));
            %% Estimate linear filters
            [CV{c}.model,CV{c}.ws,CV{c}.nCovar,CV{c}.dm,CV{c}.wml,CV{c}.dspec,CV{c}.expt,CV{c}.dmTest,CV{c}.y_hat_fit,CV{c}.y_hat_pred,CV{c}.y,CV{c}.yTest,CV{c}.FullFit,CV{c}.FullPred,CV{c}.FullFitRMSE,CV{c}.FullPredRMSE,CV{c}.fitoptions]=TFCD_eventGLM_FullBlocks_CV(rawData,curClu,PredictorParams.alpha,trainId{c},PredictorParams.binSize,PredictorParams.weightwidth,PredictorParams.PredSmth,1,PredictorParams.inclSpikeHist,PredictorParams.inclTFfilter,PredictorParams.inclBaseON,PredictorParams.inclTiledBaseline,PredictorParams.inclChangeLeadUp,PredictorParams.inclChangeON,PredictorParams.inclLick,PredictorParams.inclPostLick,PredictorParams.inclAirpuff,PredictorParams.inclRew,PredictorParams.inclAbort,PredictorParams.SingleChangeON,PredictorParams.BaselineBlocks,PredictorParams.TF_Blocks,PredictorParams.Separate_SlowFast_TFFilters,PredictorParams.DriftDirection,PredictorParams.UseBasis,PredictorParams.inclPhase,PredictorParams.FaceMovement,PredictorParams.Pupil,PredictorParams.RunWheel,PredictorParams.BaselineOnly,Bestlambda);
            CVPred{c}=CV{c}.FullPred;
        end
        
        % put unified structures
        for c=1:PredictorParams.n_kfold
            Clu(1).CV=CV;
            Clu(1).CVPred=[CVPred{:}];
            GLM.Full.glmfit=Clu(1).model;
            GLM.fitoptions=Clu(1).fitoptions;
            GLM.dspec=Clu(1).dspec;
            GLM.CV(c).glmfit=Clu(1).CV{c}.model;
            GLM.CV(c).fitoptions=Clu(1).CV{c}.fitoptions;
            GLM.CV(c).dspec=Clu.CV{c}.dspec;
            GLM.CV(c).yTest=Clu(1).CV{c}.yTest;
            GLM.CV(c).y_hat_pred=Clu(1).CV{c}.y_hat_pred;
            GLM.CV(c).dmTest=Clu(1).CV{c}.dmTest;
            GLM.CVPred=[CVPred{:}];
            
        end
        
    end
    
    %% save
    Clu(1).Fitting_Time=toc;
    toc
    
    MetaData.PredictorParams=PredictorParams;
    
    MetaData.Completed=1; % mark as completed
    
    cd([MetaData.ResultsFolder '/ReducedMovement'])
    if contains( MetaData.Region , '/' )
        backslash_pos=strfind( MetaData.Region , '/' );
        RegionName=MetaData.Region(setdiff(1:length( MetaData.Region),backslash_pos));
        FileSaveName=['ReducedMovement-'  RegionName '-' SubjectIds{MetaData.SubId} '-' SessionSelected.behav_data.SessionSettings.token '-ProbeNo_' num2str(MetaData.ProbeNo) '-CluId_' num2str(MetaData.CluId) '-GoodCluNo_' num2str(curClu)];
    else
        FileSaveName=['ReducedMovement-'  MetaData.Region '-' SubjectIds{MetaData.SubId} '-' SessionSelected.behav_data.SessionSettings.token '-ProbeNo_' num2str(MetaData.ProbeNo) '-CluId_' num2str(MetaData.CluId) '-GoodCluNo_' num2str(curClu)];
    end
    save(FileSaveName,'Clu','rawData','PredictorParams','MetaData','GLM')
    cd('Figs')
    suptitle(['FullFit:' num2str(Clu(1).FullFit) ', FullPred: ' num2str(nanmean(Clu(1).CVPred))])
    set(gcf, 'Position',  [100, 100, 1000, 1000])
    set(findall(gcf,'-property','FontSize'),'FontSize',12)
    savefig(FileSaveName)
    saveas(figure(curClu),[FileSaveName '.png'])
    
    clf
    close all
    clear Clu rawData
    
end
