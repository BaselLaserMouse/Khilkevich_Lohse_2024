function [cvfit,ws,nCovar,dm,w,dspec,expt,dmTest,y_hat_fit,y_hat_pred,y,yTest,FullFit,FullPred,FullFitRMSE,FullPredRMSE,options]=TFCD_eventGLM(rawData,curClu,setalpha,trainId,binSize,weightwidth,PredSmth,RunCV,inclSpikeHist,inclTFfilter,inclBaseON,inclBaseline,inclChangeLeadUp,inclChangeON,inclLick,inclAirpuff,inclRew,inclAbort,SingleChangeON,BaselineBlocks,TF_Blocks,Seperate_SlowFast_TFFilters,UseBasis,inclPhase)
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
    expt = buildGLM.registerTiming(expt, 'lick', 'Lick Timing');
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

if inclPhase ==1
     expt = buildGLM.registerContinuous(expt, 'Phase', 'Phase of grating', 1); % continuous obsevation over time
end

expt = buildGLM.registerValue(expt, 'orientation', 'Direction of drift');

if inclSpikeHist ==1
    expt = buildGLM.registerSpikeTrain(expt, 'sptrain', 'Target Neuron'); % Spike train from self
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
        bs = basisFactory.makeNonlinearRaisedCos(20, 1, [2 100], 5); % this is probably the one to use % 15 basis 2 to 50
    else
        bs = basisFactory.makeSmoothTemporalBasis('boxcar', 1500, 1500/(binSize*weightwidth), binfun);
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

if inclPhase ==1
    bs = basisFactory.makeSmoothTemporalBasis('boxcar', 500, 500/(binSize*weightwidth), binfun);
    dspec = buildGLM.addCovariateRaw(dspec, 'Phase', [],bs);
end

if inclSpikeHist ==1
    %% Spike history
    dspec = buildGLM.addCovariateSpiketrain(dspec, 'hist', 'sptrain', 'History filter');
end

if inclBaseON ==1
    %% Dynamic baseline onset
    %bs = basisFactory.makeNonlinearRaisedCos(6, 1, [2 75], 10);
    baseOnsetDur=1000;%ms
    if UseBasis==1
        bs = basisFactory.makeNonlinearRaisedCos(20, 1, [2 100], 5); % this is probably the one to use % 15 basis 2 to 50
    else
        bs = basisFactory.makeSmoothTemporalBasis('boxcar', baseOnsetDur, baseOnsetDur/(binSize*weightwidth), binfun);
    end
    dspec = buildGLM.addCovariateTiming(dspec, 'baseON', [],[], bs,0);
end

%  %% Duration boxcar for remainder of baseline
%dspec = buildGLM.addCovariateBoxcar(dspec, 'Baseline', 'baseBaselineON', 'baseOff', 'Baseline stim');

if inclBaseline==1
    %%tiling throughout remainder baseline
    if BaselineBlocks==1
        bs = basisFactory.makeSmoothTemporalBasis('boxcar', 8000, 8000/(binSize*weightwidth), binfun);
        dspec = buildGLM.addCovariateTiming(dspec, 'BaselineEarly', [],[], bs,0);
        bs = basisFactory.makeSmoothTemporalBasis('boxcar', 16000, 16000/(binSize*weightwidth), binfun);
        dspec = buildGLM.addCovariateTiming(dspec, 'BaselineLate', [],[], bs,0);
    else
        bs = basisFactory.makeSmoothTemporalBasis('boxcar', 16000, 16000/(binSize*weightwidth), binfun);
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
        bs = basisFactory.makeSmoothTemporalBasis('raised cosine', 1500, ceil(1500/(binSize*4)), binfun);
    else
        bs = basisFactory.makeSmoothTemporalBasis('boxcar', 1500, 1500/(binSize*weightwidth), binfun);
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

%% Compile the data into 'DesignMatrix' structure
trialIndices = trainId;
dm = buildGLM.compileSparseDesignMatrix(dspec, trainId);

%% Do some processing on the design matrix
if inclBaseline ==1
    if BaselineBlocks==1
        TiledBaselineBlock
    else
        TiledBaseline
    end
end
if RunCV==0
    dm = buildGLM.removeConstantCols(dm); %For crossvlaidatio I have to be able to predcit with the same predicors, so I cant remov constant columns.
end
%dm = buildGLM.addBiasColumn(dm); % DO NOT ADD THE BIAS TERM IF USING GLMFIT

%% Get the spike trains back to regress against
%yOrig = buildGLM.getBinnedSpikeTrain(expt, 'sptrain', dm.trialIndices);
%yFull=double(full(yOrig)>0); % limit 1 ms bin to one spike
%y=sparse(yFull);

y = buildGLM.getBinnedSpikeTrain(expt, 'sptrain', dm.trialIndices);
yFull=full(full(y));

%% Visualize the design matrix
 endTrialIndices = cumsum(binfun([expt.trial(trialIndices).duration]));
%  X = dm.X(1:endTrialIndices(50),:);
%  mv = max(abs(X), [], 1); mv(isnan(mv)) = 1;
%  X = bsxfun(@times, X, 1 ./ mv);
% figure(745); clf; imagesc(X);


%%%%%%%% START FITTING %%%%%%%%%


%% elnet estimation using glmnet
options.alpha =setalpha;%.2; % 1 is lasso %between 0 and 1 is elnet, 0 is ridge
%options.nlambda = 10; % do only a small search - otherwise it takes forever

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
    plot(ws.(label).tr, (ws.(label).data),'linewidth',2);
    title(label); 
end
% cd('figs')
%savefig(fig,num2str(curClu))
%cd ..
% close(fig)


%% Estimate and plot fit
 y_hat_fit = cvglmnetPredict(cvfit,dm.X);
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
    [dmTest,yTest,y_hat_pred]=PredictGLM(cvfit,curClu,expt,dspec,testTrialIndices,trainId,endTrialIndices,PredSmth);
    
    
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
