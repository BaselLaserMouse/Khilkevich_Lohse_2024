function [cvfit,ws,nCovar,dm,w,dspec,expt,dmTest,y_hat_fit,y_hat_pred,y,yTest,FullFit,FullPred,FullFitRMSE,FullPredRMSE,options]=TFCD_eventGLM(rawData,curClu,setalpha,trainId,binSize,weightwidth,PredSmth,RunCV,inclSpikeHist,inclTFfilter,inclBaseON,inclTiledBaseline,inclChangeLeadUp,inclChangeON,inclLick,inclPostLick,inclAirpuff,inclRew,inclAbort,SingleChangeON,BaselineBlocks,TF_Blocks,Seperate_SlowFast_TFFilters,DriftDirection,UseBasis,inclPhase,inclFaceMovement,inclPupil,inclRun,BaselineOnly)
%

cd('/home/mlohse/tfcd_npx_basicanalysis/GLMs/BatchTester/GLMfitting/GLMs/neuroGLM')

%% Load the raw data
nTrialsTotal = length(rawData.trial); % number of trials
nTrialsTrain = length(trainId); % number of trials
testTrialIndices = setdiff(1:nTrialsTotal,trainId); % test it on the last trial

unitOfTime = 'ms';

%% Specify the fields to load
expt = buildGLM.initExperiment(unitOfTime, binSize, [], rawData.param);
if inclTFfilter==1
    if TF_Blocks==1
        expt = buildGLM.registerContinuous(expt, 'instantTF_EarlyBlock', 'TF fluctuations in early block', 1); % continuous obsevation over time
        expt = buildGLM.registerContinuous(expt, 'instantTF_LateBlock', 'TF fluctuations in late block', 1); % continuous obsevation over time
    elseif TF_Blocks==2
        expt = buildGLM.registerContinuous(expt, 'instantTFEarlyBlock1', 'TF fluctuations in early block', 1); % continuous obsevation over time
        expt = buildGLM.registerContinuous(expt, 'instantTFLateBlock1', 'TF fluctuations in late block', 1); % continuous obsevation over time
        expt = buildGLM.registerContinuous(expt, 'instantTFLateBlock2', 'TF fluctuations in late block', 1); % continuous obsevation over time
    else
        
        if Seperate_SlowFast_TFFilters==1
            expt = buildGLM.registerContinuous(expt, 'instantTFSlow', 'Slow TF of each frame', 1); % continuous obsevation over time of slow TF pulses
            expt = buildGLM.registerContinuous(expt, 'instantTFFast', 'Fast TF of each frame', 1); % continuous obsevation over time of fast TF pulses
        else
            expt = buildGLM.registerContinuous(expt, 'instantTF', 'TF of each frame', 1); % continuous obsevation over time of all TF pulses
        end
        
    end
end

if inclBaseON ==1
    expt = buildGLM.registerTiming(expt, 'baseON', 'Baseline Onset'); % events that happen 0 or more times per trial (sparse)
end

if inclTiledBaseline ==1
    if BaselineBlocks==1
        expt = buildGLM.registerTiming(expt, 'BaselineEarly', 'Baseline Early Block (after 1000 ms onset) Onset'); % events that happen 0 or more times per trial (sparse)
        expt = buildGLM.registerTiming(expt, 'BaselineLate', 'Baseline Late Block (after 1000 ms onset) Onset'); % events that happen 0 or more times per trial (sparse)
    else
        expt = buildGLM.registerTiming(expt, 'Baseline', 'Baseline (after 1000 ms onset) Onset'); % events that happen 0 or more times per trial (sparse)
    end
    expt = buildGLM.registerTiming(expt, 'baseOff', 'Baseline Offset'); % events that happen 0 or more times per trial (sparse)
end

if inclChangeON ==1
    if SingleChangeON==1
        %Alternaitve 1
        expt = buildGLM.registerTiming(expt, 'changeON', 'Change Onset'); % events that happen 0 or more times per trial (sparse)
        expt = buildGLM.registerTiming(expt, 'changeOFF', 'Change Offset');
        expt = buildGLM.registerTiming(expt, 'changeONForGraded', 'Change Onset used for graded boxcar'); % events that happen 0 or more times per trial (sparse)
        expt = buildGLM.registerTiming(expt, 'changeOFFForGraded', 'Change Offset used for graded boxcar');
        expt = buildGLM.registerValue(expt, 'changeTF', 'mean changeTF'); % information on the trial, but not associated with time
    else
        % Alternative 2: explicitly fitting kernels for each change size
        expt = buildGLM.registerTiming(expt, 'changeON0', 'Change Onset'); % events that happen 0 or more times per trial (sparse)
        expt = buildGLM.registerTiming(expt, 'changeON1', 'Change Onset'); % events that happen 0 or more times per trial (sparse)
        expt = buildGLM.registerTiming(expt, 'changeON2', 'Change Onset'); % events that happen 0 or more times per trial (sparse)
        expt = buildGLM.registerTiming(expt, 'changeON3', 'Change Onset'); % events that happen 0 or more times per trial (sparse)
        expt = buildGLM.registerTiming(expt, 'changeON4', 'Change Onset'); % events that happen 0 or more times per trial (sparse)
        expt = buildGLM.registerTiming(expt, 'changeON5', 'Change Onset'); % events that happen 0 or more times per trial (sparse)
    end
end

if inclChangeLeadUp==1
    expt = buildGLM.registerTiming(expt, 'changeONleadup', 'changeON for 2 sec leadup'); % events that happen 0 or more times per trial (sparse)
end

if inclLick ==1
    expt = buildGLM.registerTiming(expt, 'lick', 'Lick Timing for activity unfolding prior to lick');
end

if inclPostLick ==1
    expt = buildGLM.registerTiming(expt, 'Postlick', 'Lick Timing for activity unfolding after lick irrespective of outcome');
end

if inclAirpuff ==1
    expt = buildGLM.registerTiming(expt, 'airpuff', 'Airpuff Timing');
end
if inclRew ==1
    expt = buildGLM.registerTiming(expt, 'rew', 'Reward Timing');
end

if inclAbort==1
    expt = buildGLM.registerTiming(expt, 'Abort', 'Abort Timing');
end

if DriftDirection ==1
    expt = buildGLM.registerValue(expt, 'orientation', 'Direction of drift');
end

if inclSpikeHist ==1
    expt = buildGLM.registerSpikeTrain(expt, 'sptrain', 'Target Neuron'); % Spike train from self
end

if inclFaceMovement==1
    expt = buildGLM.registerContinuous(expt, 'FaceMovement', 'Face Camera Motion Energy', 1); % continuous obsevation over time
end

if inclPupil==1
    expt = buildGLM.registerContinuous(expt, 'Pupil', 'Pupil Diamater', 1); % continuous obsevation over time
end

if inclRun==1
    expt = buildGLM.registerContinuous(expt, 'RunSpeed', 'Runing Wheel', 1); % continuous obsevation over time
end

if inclPhase ==1
    expt = buildGLM.registerContinuous(expt, 'Phase', 'Phase in degrees', 1); % continuous obsevation over time
end
%% Convert the raw data into the experiment structure
expt.trial = rawData.trial;
%verifyTrials(expt); % checks if the formats are correct

%% Build 'designSpec' which specifies how to generate the design matrix
% Each covariate to include in the model and analysis is specified.
dspec = buildGLM.initDesignSpec(expt);
binfun = expt.binfun;

if inclTFfilter==1
    %% Instantaneous TF
    if UseBasis==1
        bs = basisFactory.makeNonlinearRaisedCos(20, 1, [1 20], 10); % this is probably the one to use % 15 basis 2 to 50
    else
        bs = basisFactory.makeSmoothTemporalBasis('boxcar', 1500, 1500/(binSize*weightwidth), binfun);
        % bs = basisFactory.makeSmoothTemporalBasis('raised cosine', 1500, 1500/(binSize*weightwidth), binfun); % have a little bit of smoothing
        
    end
    if TF_Blocks==1
        % Early block
        dspec = buildGLM.addCovariateRaw(dspec, 'instantTF_EarlyBlock', [],bs);
        % Late block
        dspec = buildGLM.addCovariateRaw(dspec, 'instantTF_LateBlock', [],bs);
        
    elseif TF_Blocks==2
        % Early block
        dspec = buildGLM.addCovariateRaw(dspec, 'instantTFEarlyBlock1', [],bs);
        % Late block parts
        dspec = buildGLM.addCovariateRaw(dspec, 'instantTFLateBlock1', [],bs);
        dspec = buildGLM.addCovariateRaw(dspec, 'instantTFLateBlock2', [],bs);
    else
        if Seperate_SlowFast_TFFilters==1
            dspec = buildGLM.addCovariateRaw(dspec, 'instantTFSlow', [],bs);
            dspec = buildGLM.addCovariateRaw(dspec, 'instantTFFast', [],bs);
        else
            dspec = buildGLM.addCovariateRaw(dspec, 'instantTF', [],bs);
        end
        
    end
end

if BaselineOnly
    UseBasis=0; %if you only use basleine you baseline/TF only use these other variables for contamination elimatation in dm.X
end

if inclSpikeHist ==1
    %% Spike history
    dspec = buildGLM.addCovariateSpiketrain(dspec, 'hist', 'sptrain', 'History filter');
end

baseOnsetDur=1000;%ms
if inclBaseON ==1
    %% Dynamic baseline onset
    %bs = basisFactory.makeNonlinearRaisedCos(6, 1, [2 75], 10);
    if UseBasis==1
        bs = basisFactory.makeNonlinearRaisedCos(20, 1, [2 100], 5); % this is probably the one to use % 15 basis 2 to 50
    else
        bs = basisFactory.makeSmoothTemporalBasis('boxcar', baseOnsetDur, baseOnsetDur/(binSize*weightwidth), binfun);
    end
    dspec = buildGLM.addCovariateTiming(dspec, 'baseON', [],[], bs,0);
end

%  %% Duration boxcar for remainder of baseline
%dspec = buildGLM.addCovariateBoxcar(dspec, 'Baseline', 'baseBaselineON', 'baseOff', 'Baseline stim');

if inclTiledBaseline==1
    %%tiling throughout remainder baseline
    if BaselineBlocks==1
        %    bs = basisFactory.makeSmoothTemporalBasis('boxcar', 8000, 8000/(binSize*weightwidth), binfun);
        bs = basisFactory.makeSmoothTemporalBasis('boxcar', 8000, 8000/(binSize*4), binfun);  % 200 ms binning
        dspec = buildGLM.addCovariateTiming(dspec, 'BaselineEarly', [],[], bs,0);
        %    bs = basisFactory.makeSmoothTemporalBasis('boxcar', 16000, 16000/(binSize*weightwidth), binfun);
        bs = basisFactory.makeSmoothTemporalBasis('boxcar', 16000, 16000/(binSize*4), binfun);  % 200 ms binning
        dspec = buildGLM.addCovariateTiming(dspec, 'BaselineLate', [],[], bs,0);
    else
        %   bs = basisFactory.makeSmoothTemporalBasis('boxcar', 16000, 16000/(binSize*weightwidth), binfun);
        bs = basisFactory.makeSmoothTemporalBasis('boxcar', 16000, 16000/(binSize*4), binfun); % 200 ms binning
        
        dspec = buildGLM.addCovariateTiming(dspec, 'Baseline', [],[], bs,0);
    end
end

if inclChangeLeadUp==1
    %% leadup to change
    bs = basisFactory.makeSmoothTemporalBasis('boxcar', 2500, 2500/250, binfun);
    dspec = buildGLM.addCovariateTiming(dspec, 'changeONleadup', [],[], bs,0);
end

if inclChangeON ==1
    if UseBasis==1
        bs = basisFactory.makeSmoothTemporalBasis('raised cosine', 2000, ceil(2000/(binSize*4)), binfun);
    else
        bs = basisFactory.makeSmoothTemporalBasis('boxcar', 2000, 2000/(binSize*weightwidth), binfun);
    end
    if SingleChangeON==1
        
        %% Dynamic change reponse
        %bs = basisFactory.makeNonlinearRaisedCos(6, 1, [2 100], 10);
        dspec = buildGLM.addCovariateTiming(dspec, 'changeON', [],[], bs,0);
        % %% Alternatively: Duration boxcar for change stim
        % dspec = buildGLM.addCovariateBoxcar(dspec, 'Change', 'changeON', 'changeOFF', 'Change stim');
    else
        %% Alterniatively fit separate change kernels to each change size
        dspec = buildGLM.addCovariateTiming(dspec, 'changeON0', [],[], bs,0);
        dspec = buildGLM.addCovariateTiming(dspec, 'changeON1', [],[], bs,0);
        dspec = buildGLM.addCovariateTiming(dspec, 'changeON2', [],[], bs,0);
        dspec = buildGLM.addCovariateTiming(dspec, 'changeON3', [],[], bs,0);
        dspec = buildGLM.addCovariateTiming(dspec, 'changeON4', [],[], bs,0);
        dspec = buildGLM.addCovariateTiming(dspec, 'changeON5', [],[], bs,0);
    end
    
end

if inclLick ==1
    %% licking
    % bs = basisFactory.makeSmoothTemporalBasis('raised cosine', 500, 10, binfun);
    % offset = -15;
    if UseBasis==1
        bs = basisFactory.makeSmoothTemporalBasis('raised cosine', 1250, ceil(1250/(binSize*4)), binfun);
    else
        bs = basisFactory.makeSmoothTemporalBasis('boxcar', 1250, 1250/(binSize*weightwidth), binfun);
    end
    offset = -25;
    dspec = buildGLM.addCovariateTiming(dspec, 'lick', [], [], bs, offset);
end

if inclPostLick ==1
    %% post licking
    % bs = basisFactory.makeSmoothTemporalBasis('raised cosine', 500, 10, binfun);
    % offset = -15;
    if UseBasis==1
        bs = basisFactory.makeSmoothTemporalBasis('raised cosine', 750, ceil(750/(binSize*4)), binfun);
    else
        bs = basisFactory.makeSmoothTemporalBasis('boxcar', 750, 750/(binSize*weightwidth), binfun);
    end
    offset = 0;
    dspec = buildGLM.addCovariateTiming(dspec, 'Postlick', [], [], bs, offset);
end

if inclAirpuff ==1
    %% Airpuff
    % bs = basisFactory.makeSmoothTemporalBasis('raised cosine', 500, 10, binfun);
    % offset = -15;
    if UseBasis==1
        bs = basisFactory.makeSmoothTemporalBasis('raised cosine', 250, ceil(250/(binSize*4)), binfun);
    else
        bs = basisFactory.makeSmoothTemporalBasis('boxcar', 250, 250/(binSize*weightwidth), binfun);
    end
    offset = 0;
    dspec = buildGLM.addCovariateTiming(dspec, 'airpuff', [], [], bs, offset);
end
if inclRew ==1
    %% reward
    % bs = basisFactory.makeSmoothTemporalBasis('raised cosine', 500, 10, binfun);
    % offset = -15;
    if UseBasis==1
        bs = basisFactory.makeSmoothTemporalBasis('raised cosine', 500, ceil(500/(binSize*4)), binfun);
    else
        bs = basisFactory.makeSmoothTemporalBasis('boxcar', 500, 500/(binSize*weightwidth), binfun);
    end
    offset = 0;
    dspec = buildGLM.addCovariateTiming(dspec, 'rew', [], [], bs, offset);
end

if inclAbort==1
    %% Abort
    % bs = basisFactory.makeSmoothTemporalBasis('raised cosine', 500, 10, binfun);
    % offset = -15;
    if UseBasis==1
        bs = basisFactory.makeSmoothTemporalBasis('raised cosine', 1250, ceil(1500/(binSize*4)), binfun);
    else
        bs = basisFactory.makeSmoothTemporalBasis('boxcar', 1250, 1250/(binSize*weightwidth), binfun);
    end
    offset = -25;
    dspec = buildGLM.addCovariateTiming(dspec, 'Abort', [], [], bs, offset);
end

if inclChangeON ==1
    if SingleChangeON==1
        
        %     %% Change size
        %     % a box car that depends on the change value
        %    %  bs = basisFactory.makeSmoothTemporalBasis('raised cosine', 1000,1000/(binSize*weightwidth), binfun);
        bs = basisFactory.makeSmoothTemporalBasis('boxcar', binSize, 1, binfun);
        stimHandle = @(trial, expt) trial.changeTF * basisFactory.boxcarStim(binfun(trial.changeONForGraded), binfun(trial.changeOFFForGraded), binfun(trial.duration));
        
        dspec = buildGLM.addCovariate(dspec, 'changeKer', 'TF dependent change stimulus', stimHandle,bs);
    end
end

if inclFaceMovement==1
    %% Face motion energy
    bs = basisFactory.makeSmoothTemporalBasis('boxcar', 850, 850/(binSize*weightwidth), binfun);
    
    offset = -1;
    dspec = buildGLM.addCovariateRaw(dspec, 'FaceMovement', [], bs,offset);
end
if inclPupil==1
    %% Pupil Diameter
    bs = basisFactory.makeSmoothTemporalBasis('boxcar', 1500, 1500/(binSize*weightwidth), binfun);
    
    offset = -15;
    dspec = buildGLM.addCovariateRaw(dspec, 'Pupil', [], bs,offset);
end

if inclRun==1
    %% Running Wheel movement
    bs = basisFactory.makeSmoothTemporalBasis('boxcar', 850, 850/(binSize*weightwidth), binfun);
    
    offset = -1;
    dspec = buildGLM.addCovariateRaw(dspec, 'RunSpeed', [], bs,offset);
end


if inclPhase ==1
    % I use this to onstrut the basics of the design matrix, so it integraeds better witht the building of Weights, but the pahse
    % input is actually set in degreess instad of time, and is manually
    % constructed and inserted into the design matrix below
    bs = basisFactory.makeSmoothTemporalBasis('boxcar', 600, 12, binfun); % it is 600 to match bin size
    dspec = buildGLM.addCovariateRaw(dspec, 'PhaseUP', [],bs);
    dspec = buildGLM.addCovariateRaw(dspec, 'PhaseDOWN', [],bs);
end

%% Compile the data into 'DesignMatrix' structure
trialIndices = trainId;
dm = buildGLM.compileSparseDesignMatrix(dspec, trainId);

%% Do some processing on the design matrix

if inclTiledBaseline ==1
    if BaselineBlocks==1
        TiledBaselineBlock
    else
        TiledBaseline
    end
end

if inclFaceMovement==1
    %% normalise facemovemnt values
    startIdx = [1 (cumsum([dspec.covar(:).edim]) + 1)];
    k_FaceMovement = dm.dspec.idxmap.FaceMovement;
    FaceMovement_cols = startIdx(k_FaceMovement) + (1:dspec.covar(k_FaceMovement).edim) - 1;
    meanFaceMove=mean(full(dm.X(:,FaceMovement_cols(1))));
    STDFaceMove=std(full(dm.X(:,FaceMovement_cols(1))));
    
    FaceColumnsValues=full(dm.X(:,FaceMovement_cols));
    FaceColumnsValues(FaceColumnsValues==0)=meanFaceMove;
    dm.X(:,FaceMovement_cols)=(FaceColumnsValues-meanFaceMove)./STDFaceMove; % zscoring face movement values
    clear FaceColumnsValues
    
end

if inclRun==1
    %% normalise run wheel values
    startIdx = [1 (cumsum([dspec.covar(:).edim]) + 1)];
    k_Run = dm.dspec.idxmap.RunSpeed;
    Run_cols = startIdx(k_Run) + (1:dspec.covar(k_Run).edim) - 1;
    meanRun=mean(full(dm.X(:,Run_cols(1))));
    STDRun=std(full(dm.X(:,Run_cols(1))));
    
    RunColumnsValues=full(dm.X(:,Run_cols));
    RunColumnsValues(RunColumnsValues==0)=meanRun;
    dm.X(:,Run_cols)=(RunColumnsValues-meanRun)./STDRun; % zscoring face movement values
    clear RunColumnsValues
    
end

if inclPupil==1
    %% normalise pupil values
    startIdx = [1 (cumsum([dspec.covar(:).edim]) + 1)];
    k_Pupil = dm.dspec.idxmap.Pupil;
    Pupil_cols = startIdx(k_Pupil) + (1:dspec.covar(k_Pupil).edim) - 1;
    meanPupilMove=mean(full(dm.X(:,Pupil_cols(1))));
    STDPupilMove=std(full(dm.X(:,Pupil_cols(1))));
    
    PupilColumnsValues=full(dm.X(:,Pupil_cols));
    PupilColumnsValues(PupilColumnsValues==0)=meanPupilMove;
    dm.X(:,Pupil_cols)=(PupilColumnsValues-meanPupilMove)./STDPupilMove; % zscoring pupil size values with the data used
    clear PupilColumnsValues
    
end

if inclPhase==1
    %% Construct Phase bins in 30 degree bins (12 bins), to account for, and estaimte estimate phase preference
    startIdx = [1 (cumsum([dspec.covar(:).edim]) + 1)];
    
    k_PhaseUP = dm.dspec.idxmap.PhaseUP;
    PhaseUP_cols = startIdx(k_PhaseUP) + (1:dspec.covar(k_PhaseUP).edim) - 1;
    
    k_PhaseDOWN = dm.dspec.idxmap.PhaseDOWN;
    PhaseDOWN_cols = startIdx(k_PhaseDOWN) + (1:dspec.covar(k_PhaseDOWN).edim) - 1;
    
    PhaseUPValues=full(dm.X(:,PhaseUP_cols(1)));
    PhaseDOWNValues=full(dm.X(:,PhaseDOWN_cols(1)));
    
    PBinStart=00:30:340;
    PBinStop=30:30:360;
    
    for P=1:12
        PhaseUPBinsForDM(:,P)=PhaseUPValues>PBinStart(P) & PhaseUPValues<PBinStop(P);
        PhaseDOWNBinsForDM(:,P)=PhaseDOWNValues>PBinStart(P) & PhaseDOWNValues<PBinStop(P);
    end
    
    dm.X(:,PhaseUP_cols)=PhaseUPBinsForDM;
    dm.X(:,PhaseDOWN_cols)=PhaseDOWNBinsForDM;
end

if BaselineOnly
    
    OrigSize=size(dm.X);
    
    %% remove all periods with contaminants of baseline activity
    % first isolate baseline
    dm.X(find(baselineBinIdx==0), :) = [];
    
    % then remove additional contaminators
    k_BaseON = dm.dspec.idxmap.baseON;
    k_Abort = dm.dspec.idxmap.Abort;
    k_EarlyLick = dm.dspec.idxmap.airpuff;
    k_Lick = dm.dspec.idxmap.lick;
    k_PostLick = dm.dspec.idxmap.Postlick;
    k_Rew = dm.dspec.idxmap.rew;
    
    BaseON_cols = startIdx(k_BaseON) + (1:dspec.covar(k_BaseON).edim) - 1;
    Abort_cols = startIdx(k_Abort) + (1:dspec.covar(k_Abort).edim) - 1;
    EarlyLick_cols = startIdx(k_EarlyLick) + (1:dspec.covar(k_EarlyLick).edim) - 1;
    Lick_cols = startIdx(k_Lick) + (1:dspec.covar(k_Lick).edim) - 1;
    PostLick_cols = startIdx(k_PostLick) + (1:dspec.covar(k_PostLick).edim) - 1;
    Rew_cols = startIdx(k_Rew) + (1:dspec.covar(k_Rew).edim) - 1;
    
    Contamination_cols=[Abort_cols,EarlyLick_cols,Lick_cols,PostLick_cols,Rew_cols];
    
    ContaminatedBaseline=sum(full(dm.X(:, Contamination_cols)),2)>0;
    
    dm.X(find(ContaminatedBaseline), :) = [];
    
    %   dm.X(:,baseline_cols(end)+1:end)=[]; % remove columns related to contmainated columns, to make it all a bit cleaner
    %   dm.X(:,BaseON_cols)=[]; % remove columns related to BaseON
    
    %% make a note of what clumns have been removed, for later reconstruction  (this uses the structure from removeConstantCols.m)
    %   Temp=zeros(1,OrigSize(2));
    %   Temp([BaseON_cols Contamination_cols])=1;
    %    dm.constCols = sparse(Temp); %
    clear Temp
    
end

% in case there are nans or infs in the deisgn matrix (this should not notmally be the case)
    dm.X(find(isnan(dm.X)))=0;
    dm.X(find(isinf(dm.X)))=0;

clear k_baseline Temp T Tcount BaseON_cols Abort_cols EarlyLick_cols Lick_cols Rew_cols k_BaseON k_Abort k_EarlyLick k_EarlyLick k_Lick k_Rew k_Rew k_PostLick PostLick_cols

% dm = buildGLM.zscoreDesignMatrix(dm);

%  if RunCV==0
%      dm = buildGLM.removeConstantCols(dm); %For crossvlaidatio I have to be able to predcit with the same predicors, so I cant remov constant columns.
%  end
%dm = buildGLM.addBiasColumn(dm); % DO NOT ADD THE BIAS TERM IF USING GLMFIT

%% Get the spike trains back to regress against
%yOrig = buildGLM.getBinnedSpikeTrain(expt, 'sptrain', dm.trialIndices);
%yFull=double(full(yOrig)>0); % limit 1 ms bin to one spike
%y=sparse(yFull);

y = buildGLM.getBinnedSpikeTrain(expt, 'sptrain', dm.trialIndices);
yFull=full(y);

if BaselineOnly
    %% cut spike times to include baseline only
    yFull(find(baselineBinIdx==0))=[];
    yFull(find(ContaminatedBaseline))=[];
    clear y
    y=sparse(yFull);
end

clear baselineBinIdx ContaminatedBaseline


%% Visualize the design matrix
endTrialIndices = cumsum(binfun([expt.trial(trialIndices).duration]));
% X = dm.X(1:endTrialIndices(100),:);
% mv = max(abs(X), [], 1); mv(isnan(mv)) = 1;
% X = bsxfun(@times, X, 1 ./ mv);
% figure(745); clf; imagesc(X);

%% if the tiled baseline have few <10 observations, heavily penalize these weights, as they can only be very poorly estaimted and likely overfit
TrPerBaseTile=sum(full((dm.X(2:end,baseline_cols)-dm.X(1:end-1,baseline_cols))>0)); % find tile beginnings
excludeTiles=zeros(1,size(dm.X,2));
excludeTiles(baseline_cols(TrPerBaseTile<10))=1; % find varibales corresponding to tiles with few trials

%%%%%%%% START FITTING %%%%%%%%%

%% elnet estimation using glmnet

% %% first find phase, fit is there
% optionsLasso.alpha =1;%.2; % 1 is lasso %between 0 and 1 is elnet, 0 is ridge
% %options.nlambda = 10; % do only a small search - otherwise it takes forever
%
% cvfitLasso = cvglmnet(dm.X,y,'poisson',optionsLasso,[],[],[],true);
% bestLambdaLasso=find(cvfitLasso.lambda==cvfitLasso.lambda_min); % I am using minimum lambda (best cross validated performance), alternatively use llse)
% wLasso= cvfitLasso.glmnet_fit.beta(:,bestLambdaLasso);

% %% find phase, and zero anything tht is not correct phase
% wsLasso = buildGLM.combineWeights(dm,wLasso);
%
% k_Phase = dm.dspec.idxmap.Phase;
% Phase_cols = startIdx(k_Phase) + (1:dspec.covar(k_Phase).edim) - 1;
%
% [~,PhaseIdx]=max(wLasso(Phase_cols));
%
% Phase_cols(PhaseIdx)=[];
%
% dm.X(:,Phase_cols)=0; % remove phase columns that are not the estimated phase

%% estimate main model with ridge

options.alpha =setalpha;%.2; % 1 is lasso %between 0 and 1 is elnet, 0 is ridge
%options.nlambda = 10; % do only a small search - otherwise it takes forever
options.penalty_factor=((excludeTiles)*999)+1;

cvfit = cvglmnet(dm.X,y,'poisson',options,[],[],[],true);
bestLambda=find(cvfit.lambda==cvfit.lambda_min); % I am using minimum lambda (best cross validated performance), alternatively use llse)
w= cvfit.glmnet_fit.beta(:,bestLambda);

%% Calculale kernels
ws = buildGLM.combineWeights(dm,w);

%% Plot kernels
fig = figure(curClu);
hold on
nCovar = numel(dspec.covar);
for kCov = 1:nCovar
    label = dspec.covar(kCov).label;
    subplot(ceil(nCovar/3), 3, kCov);
    hold on
    
    if strcmp(label,'PhaseUP')  
        % interpolate with shape preservation (cubic)
        [xInterp, yInterp] = smoothLine(15:30:360,(ws.(label).data)); % in degrees
        plot(xInterp, yInterp,'linewidth',2);
        clear xInterp yInterp
        xlabel('degrees (30 deg bins)')
        xlim([0 360])
    elseif strcmp(label,'PhaseDOWN')
         % interpolate with shape preservation (cubic)
        [xInterp, yInterp] = smoothLine(15:30:360,(ws.(label).data)); 
        plot(xInterp, yInterp,'linewidth',2);
        clear xInterp yInterp
        xlabel('degrees (30 deg bins)')
        xlim([0 360])
    else
         % interpolate with shape preservation (cubic)
        [xInterp, yInterp] = smoothLine(ws.(label).tr,(ws.(label).data)); % in millisecond
        plot(xInterp, yInterp,'linewidth',2);
        clear xInterp yInterp
        xlabel('time (ms)')
    end
    title(label);
end
% cd('figs')
%savefig(fig,num2str(curClu))
%cd ..
% close(fig)


%% Estimate and plot fit
y_hat_fit = cvglmnetPredict(cvfit,dm.X,'lambda_min');
% figure(1000+curClu);plot(zscore(y_hat_fit),'b');
% hold on;
% yscat=full(y);
% yscat(yscat==0)=NaN;
% scatter(1:length(yscat),yscat,'k.');
% plot(zscore(smoothdata(full(y),'movmean',PredSmth)),'m')
% title(['ccFit: ' num2str(corr(zscore(smoothdata(full(y),'movmean',PredSmth)),y_hat_fit))])
% clear yscat

if RunCV==1
    
    %% Simulate from model for test data
    %[dmTest,yTest,y_hat_pred]=PredictGLM(cvfit,curClu,expt,dspec,testTrialIndices,trainId,endTrialIndices,PredSmth,Phase_cols);
%   if researchLambda==1
        [dmTest,yTest,y_hat_pred]=PredictGLM_CV(rawData,cvfit,curClu,expt,dspec,testTrialIndices,trainId,endTrialIndices,PredSmth,'lambda_min',inclTiledBaseline,inclFaceMovement,inclRun,inclPupil,inclPhase,BaselineBlocks,baseOnsetDur,binSize);
%     else
%         [dmTest,yTest,y_hat_pred]=PredictGLM_CV(rawData,cvfit,curClu,expt,dspec,testTrialIndices,trainId,endTrialIndices,PredSmth,lambda,inclTiledBaseline,inclFaceMovement,inclRun,inclPupil,inclPhase,BaselineBlocks,baseOnsetDur,binSize);
%     end    
    
    if BaselineOnly
        BaselineOnly_XY_Predict
    end
    
    %     yFull=full(y);
    %     cleanBasePeriodIdx=full(dm.X(:,22));
    %    [BaselineFit,BaselineFit_pval]=corr(zscore(smoothdata(yFull(find(cleanBasePeriodIdx)),'movmean',PredSmth)),y_hat_fit(find(cleanBasePeriodIdx)))
    
    %     figure(3000+curClu)
    %     scatter((zscore(smoothdata(yTest,'movmean',PredSmth))),y_hat_pred,'r.')
    %     lsline
    
    [FullFit,FullFit_pval]=corr(zscore(smoothdata(yFull,'movmean',PredSmth)),y_hat_fit);
    [FullPred,FullPred_pval]=corr(zscore(smoothdata(yTest,'movmean',PredSmth)),y_hat_pred);
    
    FullFitRMSE=sqrt(mean(((smoothdata(yFull,'movmean',PredSmth))-y_hat_fit).^2));
    FullPredRMSE=sqrt(mean(((smoothdata(yTest,'movmean',PredSmth))-y_hat_pred).^2));
    
    
    BaselineFit=[];
    BaselinePred=[];
    
else
    
    [FullFit,FullFit_pval]=corr(zscore(smoothdata(yFull,'movmean',PredSmth)),y_hat_fit);
    FullFitRMSE=mean(((smoothdata(yFull,'movmean',PredSmth))-y_hat_fit).^2);
    
    
    % [FullFit,FullFit_pval]=corr(zscore(smoothdata(yFull,'movmean',PredSmth)),y_hat_fit)
    %     yFull=full(y);
    %     cleanBasePeriodIdx=full(dm.X(:,22));
    % [BaselineFit,BaselineFit_pval]=corr(zscore(smoothdata(yFull(find(cleanBasePeriodIdx)),'movmean',PredSmth)),y_hat_fit(find(cleanBasePeriodIdx)))
    FullPredRMSE=[];
    dmTest=[];
    yTest=[];
    y_hat_pred=[];
    BaselineFit=[];
    BaselinePred=[];
    FullPred=[];
end


