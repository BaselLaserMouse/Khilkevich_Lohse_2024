
%%%%%%%%%%% PLOT RESULTS %%%%%%%%%%%%%

%% Plot kernels estimated from all data
figure(curClu+10000);
hold on
nCovar = numel(Clu(1).dspec.covar);
for kCov = 1:nCovar
    label = Clu(1).dspec.covar(kCov).label;
    subplot(6, 3, kCov);
    hold on
    plot(Clu(1).ws.(label).tr, (Clu(1).ws.(label).data),'k','linewidth',2);
    title(label);
    set(gca,'fontsize', 12);
    
end
xlabel('ms')

%% plot all CV kernels

figure(curClu+10001);
hold on
for c=1:PredictorParams.n_kfold
    nCovar = numel(Clu(1).CV(c).dspec.covar);
    for kCov = 1:nCovar
        label = Clu(1).CV(c).dspec.covar(kCov).label;
        subplot(6, 3, kCov);
        hold on
        plot(Clu(1).CV(c).ws.(label).tr, Clu(1).CV(c).ws.(label).data,'linewidth',2);
        wsAll{curClu}{kCov}(c,:)= Clu(1).CV(c).ws.(label).data;
        timeAll{curClu}{kCov}(c,:)=Clu(1).CV(c).ws.(label).tr;
        title(label);
        set(gca,'fontsize', 12);
        
    end
end
xlabel('ms')

%% plot average CV kernels
figure
for kCov = 1:nCovar
    label = Clu(1).CV(c).dspec.covar(kCov).label;
    subplot(6, 3, kCov);
    shadedErrorBar(timeAll{curClu}{kCov}(1,:),mean(wsAll{curClu}{kCov}),(std(wsAll{curClu}{kCov})/sqrt(3))*1.96,'lineProps', {'r','linewidth',1.5})
    set(gca,'fontsize', 13);clear rawData Clu
for curClu=[8]%[570 635]
    disp(['Fitting unit #' num2str(curClu)])
    [rawData.trial,rawData.param]=MakeTFCDEventGLMInputStructureFullBlocks(EphysData,BehavData,HitTrials,nTrials,curClu,PredictorParams.binSize,ephysFolder,PredictorParams.onlyHit);
    
    %% Estimate weights from all trials
    [Clu(1).model,Clu(1).ws,Clu(1).nCovar,dm,Clu(1).wml,Clu(1).dspec,expt,dmTest,Clu(1).y_hat_fit,~,Clu(1).y,~,Clu(1).FullFit,~,Clu(1).BaselineFit,~,fitoptions]=TFCD_eventGLM_FullBlocks(rawData,curClu,PredictorParams.alpha,1:length(rawData.trial),PredictorParams.binSize,PredictorParams.weightwidth,PredictorParams.PredSmth,0,PredictorParams.inclSpikeHist,PredictorParams.inclTFfilter,PredictorParams.inclBaseON,PredictorParams.inclBaseline,PredictorParams.inclChangeLeadUp,PredictorParams.inclChangeON,PredictorParams.inclLick,PredictorParams.inclAirpuff,PredictorParams.inclRew,PredictorParams.inclAbort,PredictorParams.SingleChangeON,PredictorParams.BaselineBlocks,PredictorParams.TF_Blocks,PredictorParams.UseBasis);
    %% Fit LN ouput nonlinearity
    Clu(1).lnmodel = getlnmodel3(Clu(1).y_hat_fit, full(Clu(1).y));
    Clu(1).y_hat_lnmodel = lnmodelresp(Clu(1).lnmodel.params, Clu(1).y_hat_fit);
    if RunCV ==1
        for c=1:PredictorParams.n_kfold % kfold crossvalidation
            if CVstructcreated==0
                PredictorParams.CVstruct = cvpartition(length(rawData.trial),'KFold',PredictorParams.n_kfold);
                CVstructcreated=1;
            end
            
            clear trainId
            trainId=find(training(PredictorParams.CVstruct,c));
            %% Estimate linear filters
            [Clu(1).CV(c).model,Clu(1).CV(c).ws,Clu(1).CV(c).nCovar,CV(c).dm,Clu(1).CV(c).wml,Clu(1).CV(c).dspec,CV(c).expt,CV(c).dmTest,Clu(1).CV(c).y_hat_fit,Clu(1).CV(c).y_hat_pred,Clu(1).CV(c).y,Clu(1).CV(c).yTest,Clu(1).CV(c).FullFit,Clu(1).CV(c).FullPred,Clu(1).CV(c).BaselineFit,Clu(1).CV(c).BaselinePred,CV(c).fitoptions]=TFCD_eventGLM_FullBlocks(rawData,curClu,PredictorParams.alpha,trainId,PredictorParams.binSize,PredictorParams.weightwidth,PredictorParams.PredSmth,1,PredictorParams.inclSpikeHist,PredictorParams.inclTFfilter,PredictorParams.inclBaseON,PredictorParams.inclBaseline,PredictorParams.inclChangeLeadUp,PredictorParams.inclChangeON,PredictorParams.inclLick,PredictorParams.inclAirpuff,PredictorParams.inclRew,PredictorParams.inclAbort,PredictorParams.SingleChangeON,PredictorParams.BaselineBlocks,PredictorParams.TF_Blocks,PredictorParams.UseBasis);
            %% Fit sigmoid output nonlinearity to training and test set
            Clu(1).CV(c).lnmodel = getlnmodel3(Clu(1).CV(c).y_hat_fit, full(Clu(1).CV(c).y));
            Clu(1).CV(c).y_hat_lnmodel_fit = lnmodelresp(Clu(1).CV(c).lnmodel.params, Clu(1).CV(c).y_hat_fit);
            Clu(1).CV(c).y_hat_lnmodel_pred = lnmodelresp(Clu(1).CV(c).lnmodel.params, Clu(1).CV(c).y_hat_pred);
            
        end
    end
end

end
xlabel('ms')


% get performance
for c=1:3%PredictorParams.n_kfold
    FullFit(c)=Clu(1).CV(c).FullFit;
    FullPred(c)=Clu(1).CV(c).FullPred;
    
    %   BaselineFit(c)=Clu(1).CV(c).BaselineFit;
    %BaselinePred(c)=Clu(1).CV(c).BaselinePred;
end

%% plot performance
figure;
subplot(1,2,1);
boxplot([FullFit FullPred],[ones(1,3),[ones(1,3)+1]])
line([0 5],[0 0],'linewidth',2,'linestyle','--','color','r')
%ylim([-.1 .75])
set(gca,'fontsize', 12);
box off
title('Full trial performance')

% subplot(1,2,2);boxplot([BaselineFit BaselinePred],[ones(1,10),[ones(1,10)+1]])
% line([0 5],[0 0],'linewidth',2,'linestyle','--','color','r')
% ylim([-.1 .75])
% set(gca,'fontsize', 12);
% box off
% title('Baseline performance')
%

%% Plot output nonlineM2arity for latest cell
% get binned dataclear rawData Clu
for curClu=[8]%[570 635]
    disp(['Fitting unit #' num2str(curClu)])
    [rawData.trial,rawData.param]=MakeTFCDEventGLMInputStructureFullBlocks(EphysData,BehavData,HitTrials,nTrials,curClu,PredictorParams.binSize,ephysFolder,PredictorParams.onlyHit);
    
    %% Estimate weights from all trials
    [Clu(1).model,Clu(1).ws,Clu(1).nCovar,dm,Clu(1).wml,Clu(1).dspec,expt,dmTest,Clu(1).y_hat_fit,~,Clu(1).y,~,Clu(1).FullFit,~,Clu(1).BaselineFit,~,fitoptions]=TFCD_eventGLM_FullBlocks(rawData,curClu,PredictorParams.alpha,1:length(rawData.trial),PredictorParams.binSize,PredictorParams.weightwidth,PredictorParams.PredSmth,0,PredictorParams.inclSpikeHist,PredictorParams.inclTFfilter,PredictorParams.inclBaseON,PredictorParams.inclBaseline,PredictorParams.inclChangeLeadUp,PredictorParams.inclChangeON,PredictorParams.inclLick,PredictorParams.inclAirpuff,PredictorParams.inclRew,PredictorParams.inclAbort,PredictorParams.SingleChangeON,PredictorParams.BaselineBlocks,PredictorParams.TF_Blocks,PredictorParams.UseBasis);
    %% Fit LN ouput nonlinearity
    Clu(1).lnmodel = getlnmodel3(Clu(1).y_hat_fit, full(Clu(1).y));
    Clu(1).y_hat_lnmodel = lnmodelresp(Clu(1).lnmodel.params, Clu(1).y_hat_fit);
    if RunCV ==1
        for c=1:PredictorParams.n_kfold % kfold crossvalidation
            if CVstructcreated==0
                PredictorParams.CVstruct = cvpartition(length(rawData.trial),'KFold',PredictorParams.n_kfold);
                CVstructcreated=1;
            end
            
            clear trainId
            trainId=find(training(PredictorParams.CVstruct,c));
            %% Estimate linear filters
            [Clu(1).CV(c).model,Clu(1).CV(c).ws,Clu(1).CV(c).nCovar,CV(c).dm,Clu(1).CV(c).wml,Clu(1).CV(c).dspec,CV(c).expt,CV(c).dmTest,Clu(1).CV(c).y_hat_fit,Clu(1).CV(c).y_hat_pred,Clu(1).CV(c).y,Clu(1).CV(c).yTest,Clu(1).CV(c).FullFit,Clu(1).CV(c).FullPred,Clu(1).CV(c).BaselineFit,Clu(1).CV(c).BaselinePred,CV(c).fitoptions]=TFCD_eventGLM_FullBlocks(rawData,curClu,PredictorParams.alpha,trainId,PredictorParams.binSize,PredictorParams.weightwidth,PredictorParams.PredSmth,1,PredictorParams.inclSpikeHist,PredictorParams.inclTFfilter,PredictorParams.inclBaseON,PredictorParams.inclBaseline,PredictorParams.inclChangeLeadUp,PredictorParams.inclChangeON,PredictorParams.inclLick,PredictorParams.inclAirpuff,PredictorParams.inclRew,PredictorParams.inclAbort,PredictorParams.SingleChangeON,PredictorParams.BaselineBlocks,PredictorParams.TF_Blocks,PredictorParams.UseBasis);
            %% Fit sigmoid output nonlinearity to training and test set
            Clu(1).CV(c).lnmodel = getlnmodel3(Clu(1).CV(c).y_hat_fit, full(Clu(1).CV(c).y));
            Clu(1).CV(c).y_hat_lnmodel_fit = lnmodelresp(Clu(1).CV(c).lnmodel.params, Clu(1).CV(c).y_hat_fit);
            Clu(1).CV(c).y_hat_lnmodel_pred = lnmodelresp(Clu(1).CV(c).lnmodel.params, Clu(1).CV(c).y_hat_pred);
            
        end
    end
end

[xb, yb] = bindata(Clu(1).y_hat_fit, full(Clu(1).y), 100);
[xbLN, ybLN] = bindata(Clu(1).y_hat_fit, Clu(1).y_hat_lnmodel, 250);

figure
%plot(Clu(1).y_hat_fit,full(Clu(1).y),'k.')
hold on
plot(xb,yb,'ko')
plot(xbLN,ybLN,'linewidth',2)
box off
