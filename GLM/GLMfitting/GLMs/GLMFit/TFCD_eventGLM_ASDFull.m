function [cvfit,ws,nCovar,dm,w,dspec,expt,dmTest,y_hat_fit,y_hat_pred,y,yTest,FullFit,FullPred,BaselineFit,BaselinePred,options]=TFCD_eventGLM_ASDFull(rawData,curClu,trainId,binSize,weightwidth,PredSmth,RunCV,inclSpikeHist,inclTFfilter,inclBaseON,inclBaseline,inclChangeLeadUp,inclChangeON,inclLick,inclRew,inclAbort,BaselineBlocks,TF_Blocks)
%

cd('/home/mlohse/tfcd_npx_basicanalysis/GLMs/neuroGLM')

%% Load the raw data
nTrialsTotal = length(rawData.trial); % number of trials
nTrialsTrain = length(trainId); % number of trials

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
        expt = buildGLM.registerContinuous(expt, 'instantTF', 'TF of each frame', 1); % continuous obsevation over time
    end
end

if inclBaseON ==1
    expt = buildGLM.registerTiming(expt, 'baseON', 'Baseline Onset'); % events that happen 0 or more times per trial (sparse)
end

if inclBaseline ==1
    if BaselineBlocks==1
        expt = buildGLM.registerTiming(expt, 'BaselineEarly', 'Baseline Early Block (after 1000 ms onset) Onset'); % events that happen 0 or more times per trial (sparse)
        expt = buildGLM.registerTiming(expt, 'BaselineLate', 'Baseline Late Block (after 1000 ms onset) Onset'); % events that happen 0 or more times per trial (sparse)
    else
        expt = buildGLM.registerTiming(expt, 'Baseline', 'Baseline (after 1000 ms onset) Onset'); % events that happen 0 or more times per trial (sparse)
    end
    expt = buildGLM.registerTiming(expt, 'baseOff', 'Baseline Offset'); % events that happen 0 or more times per trial (sparse)
end

if inclChangeON ==1
    expt = buildGLM.registerTiming(expt, 'changeON', 'Change Onset'); % events that happen 0 or more times per trial (sparse)
    expt = buildGLM.registerTiming(expt, 'changeOFF', 'Change Offset');

    expt = buildGLM.registerTiming(expt, 'changeONForGraded', 'Change Onset used for graded boxcar'); % events that happen 0 or more times per trial (sparse)
    expt = buildGLM.registerTiming(expt, 'changeOFFForGraded', 'Change Offset used for graded boxcar');
  
end
if inclChangeLeadUp==1
    expt = buildGLM.registerTiming(expt, 'changeONleadup', 'changeON for 2 sec leadup'); % events that happen 0 or more times per trial (sparse)
end

if inclLick ==1
    expt = buildGLM.registerTiming(expt, 'lick', 'Lick Timing');
end
if inclRew ==1
    expt = buildGLM.registerTiming(expt, 'rew', 'Lick Timing');
end
if inclAbort==1
    expt = buildGLM.registerTiming(expt, 'Abort', 'Lick Timing');
end
expt = buildGLM.registerValue(expt, 'changeTF', 'mean changeTF'); % information on the trial, but not associated with time
expt = buildGLM.registerValue(expt, 'orientation', 'Direction of drift');
if inclSpikeHist ==1
    expt = buildGLM.registerSpikeTrain(expt, 'sptrain', 'Our Neuron'); % Spike train from self
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
    bs = basisFactory.makeSmoothTemporalBasis('boxcar', 1500, 1500/(binSize*weightwidth), binfun);
    
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
        dspec = buildGLM.addCovariateRaw(dspec, 'instantTF', [],bs);
    end
end

if inclSpikeHist ==1
    %% Spike history
    dspec = buildGLM.addCovariateSpiketrain(dspec, 'hist', 'sptrain', 'History filter');
end

if inclBaseON ==1
    %% Dynamic baseline onset
    %bs = basisFactory.makeNonlinearRaisedCos(6, 1, [2 75], 10);
    baseOnsetDur=1000;%ms
    bs = basisFactory.makeSmoothTemporalBasis('boxcar', baseOnsetDur, baseOnsetDur/(binSize*weightwidth), binfun);
    dspec = buildGLM.addCovariateTiming(dspec, 'baseON', [],[], bs,0);
end

%  %% Duration boxcar for remainder of baseline
%dspec = buildGLM.addCovariateBoxcar(dspec, 'Baseline', 'baseBaselineON', 'baseOff', 'Baseline stim');

if inclBaseline==1
    %%tiling throughout remainder baseline
    if BaselineBlocks==1
        bs = basisFactory.makeSmoothTemporalBasis('boxcar', 7500, 30, binfun);
        dspec = buildGLM.addCovariateTiming(dspec, 'BaselineEarly', [],[], bs,0);
        bs = basisFactory.makeSmoothTemporalBasis('boxcar', 15000, 60, binfun);
        dspec = buildGLM.addCovariateTiming(dspec, 'BaselineLate', [],[], bs,0);
    else
        bs = basisFactory.makeSmoothTemporalBasis('boxcar', 15000, 60, binfun);
        dspec = buildGLM.addCovariateTiming(dspec, 'Baseline', [],[], bs,0);
    end
end

if inclChangeLeadUp==1
    %% leadup to change
    bs = basisFactory.makeSmoothTemporalBasis('boxcar', 2500, 2500/250, binfun);
    dspec = buildGLM.addCovariateTiming(dspec, 'changeONleadup', [],[], bs,0);
end

if inclChangeON ==1
    %% Dynamic change onset
    %bs = basisFactory.makeNonlinearRaisedCos(6, 1, [2 100], 10);
    bs = basisFactory.makeSmoothTemporalBasis('boxcar', 2000, 2000/(binSize*weightwidth), binfun);
    dspec = buildGLM.addCovariateTiming(dspec, 'changeON', [],[], bs,0);
    % %% Alternatively: Duration boxcar for change stim
    % dspec = buildGLM.addCovariateBoxcar(dspec, 'Change', 'changeON', 'changeOFF', 'Change stim');
end

if inclLick ==1
    %% licking
    % bs = basisFactory.makeSmoothTemporalBasis('raised cosine', 500, 10, binfun);
    % offset = -15;
    bs = basisFactory.makeSmoothTemporalBasis('boxcar', 1250, 1250/(binSize*weightwidth), binfun);
    offset = -50;
    dspec = buildGLM.addCovariateTiming(dspec, 'lick', [], [], bs, offset);
end
if inclRew ==1
    %% reward
    % bs = basisFactory.makeSmoothTemporalBasis('raised cosine', 500, 10, binfun);
    % offset = -15;
    bs = basisFactory.makeSmoothTemporalBasis('boxcar', 500, 500/(binSize*weightwidth), binfun);
    offset = 0;
    dspec = buildGLM.addCovariateTiming(dspec, 'rew', [], [], bs, offset);
end

if inclAbort==1
    %% Abort
    % bs = basisFactory.makeSmoothTemporalBasis('raised cosine', 500, 10, binfun);
    % offset = -15;
    bs = basisFactory.makeSmoothTemporalBasis('boxcar', 1500, 1500/(binSize*weightwidth), binfun);
    offset = -50;
    dspec = buildGLM.addCovariateTiming(dspec, 'Abort', [], [], bs, offset);
end

if inclChangeON ==1
    %% Change size
    % a box car that depends on the change value
%      bs = basisFactory.makeSmoothTemporalBasis('raised cosine', 300, 8, binfun);
%     % bs = basisFactory.makeSmoothTemporalBasis('boxcar', 500, 20, binfun);
%     stimHandle = @(trial, expt) trial.changeTF * basisFactory.boxcarStim(binfun(trial.changeON), binfun(trial.changeOFF), binfun(trial.duration));
%     
%     dspec = buildGLM.addCovariate(dspec, 'changeKer', 'TF dependent change stimulus', stimHandle,bs);
end
%% Compile the data into 'DesignMatrix' structure
trialIndices = trainId;
dm = buildGLM.compileSparseDesignMatrix(dspec, trialIndices);

if inclBaseline ==1
    if BaselineBlocks==1
        TiledBaselineBlock
    else
        TiledBaseline
    end
end

%% Get the spike trains back to regress against
yOrig = buildGLM.getBinnedSpikeTrain(expt, 'sptrain', dm.trialIndices);
yFull=double(full(yOrig)>0); % limit 1 ms bin to one spike
y=sparse(yFull);

%% Do some processing on the design matrix
dm = buildGLM.removeConstantCols(dm);
%dm = buildGLM.addBiasColumn(dm); % DO NOT ADD THE BIAS TERM IF USING GLMFIT

%% Visualize the design matrix
endTrialIndices = cumsum(binfun([expt.trial(trialIndices).duration]));
X = dm.X(1:endTrialIndices(10),:);
mv = max(abs(X), [], 1); mv(isnan(mv)) = 1;
X = bsxfun(@times, X, 1 ./ mv);
figure(742); clf; imagesc(X);


%%%%%%%% START FITTING %%%%%%%%%


%%  estimation using fast ASD
nkgrp = [30,20,1,30,25,10,30]
minlen = 1;
tic; 
[w,asdstats2] = fastASD_group(dm.X,y,nkgrp,minlen);
toc;



%% Calculale kernels
ws = buildGLM.combineWeights(dm,w);

%% Visualize

fig = figure(curClu);
hold on
nCovar = numel(dspec.covar);
for kCov = 1:nCovar
    label = dspec.covar(kCov).label;
    subplot(4, 2, kCov);
    hold on
    plot(ws.(label).tr, ws.(label).data);
    title(label);
    % end
end
