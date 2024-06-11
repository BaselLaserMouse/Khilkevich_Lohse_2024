function [dmTest,yTest,y_hat_pred]=PredictGLM(rawData,cvfit,curClu,expt,dspec,testTrialIndices,trainId,endTrialIndices,PredSmth,lambda,inclTiledBaseline,inclFaceMovement,inclRun,inclPupil,inclPhase,BaselineBlocks,baseOnsetDur,binSize)
%function [dmTest,yTest,y_hat_pred]=PredictGLM(cvfit,curClu,expt,dspec,testTrialIndices,trainId,endTrialIndices,PredSmth,Off_Phase_cols)

dmTest = buildGLM.compileSparseDesignMatrix(dspec, testTrialIndices');
%dmTest = buildGLM.removeConstantCols(dmTest);
%dmTest.X(:,Off_Phase_cols)=0; % remove phase columns that are not the estimated phase (LEGACY: this has been estimated from a revious model using laso regression)

%% Do some processing on the design matrix

if inclTiledBaseline ==1
    if BaselineBlocks==1
        TiledBaselineBlock_Test
    else
        TiledBaseline_Test
    end
end


if inclFaceMovement==1
    %% normalise facemovemnt values
    startIdx = [1 (cumsum([dspec.covar(:).edim]) + 1)];
    k_FaceMovement = dmTest.dspec.idxmap.FaceMovement;
    FaceMovement_cols = startIdx(k_FaceMovement) + (1:dspec.covar(k_FaceMovement).edim) - 1;
    meanFaceMove=mean(full(dmTest.X(:,FaceMovement_cols(1))));
    STDFaceMove=std(full(dmTest.X(:,FaceMovement_cols(1))));
    
    FaceColumnsValues=full(dmTest.X(:,FaceMovement_cols));
    FaceColumnsValues(FaceColumnsValues==0)=meanFaceMove;
    dmTest.X(:,FaceMovement_cols)=(FaceColumnsValues-meanFaceMove)./STDFaceMove; % zscoring face movement values
    clear FaceColumnsValues
    
end

if inclRun==1
    %% normalise run wheel values
    startIdx = [1 (cumsum([dspec.covar(:).edim]) + 1)];
    k_Run = dmTest.dspec.idxmap.RunSpeed;
    Run_cols = startIdx(k_Run) + (1:dspec.covar(k_Run).edim) - 1;
    meanRun=mean(full(dmTest.X(:,Run_cols(1))));
    STDRun=std(full(dmTest.X(:,Run_cols(1))));
    
    RunColumnsValues=full(dmTest.X(:,Run_cols));
    RunColumnsValues(RunColumnsValues==0)=meanRun;
    dmTest.X(:,Run_cols)=(RunColumnsValues-meanRun)./STDRun; % zscoring face movement values
    clear RunColumnsValues
end

if inclPupil==1
    %% normalise pupil values
    startIdx = [1 (cumsum([dspec.covar(:).edim]) + 1)];
    k_Pupil = dmTest.dspec.idxmap.Pupil;
    Pupil_cols = startIdx(k_Pupil) + (1:dspec.covar(k_Pupil).edim) - 1;
    meanPupilMove=mean(full(dmTest.X(:,Pupil_cols(1))));
    STDPupilMove=std(full(dmTest.X(:,Pupil_cols(1))));
    
    PupilColumnsValues=full(dmTest.X(:,Pupil_cols));
    PupilColumnsValues(PupilColumnsValues==0)=meanPupilMove;
    dmTest.X(:,Pupil_cols)=(PupilColumnsValues-meanPupilMove)./STDPupilMove; % zscoring pupil size values with the data used
    clear PupilColumnsValues
    
end

if inclPhase==1
    %% Construct Phase bins in 30 degree bins (12 bins), to account for, and estaimte estimate phase preference
    startIdx = [1 (cumsum([dspec.covar(:).edim]) + 1)];
    
    k_PhaseUP = dmTest.dspec.idxmap.PhaseUP;
    PhaseUP_cols = startIdx(k_PhaseUP) + (1:dspec.covar(k_PhaseUP).edim) - 1;
    
    k_PhaseDOWN = dmTest.dspec.idxmap.PhaseDOWN;
    PhaseDOWN_cols = startIdx(k_PhaseDOWN) + (1:dspec.covar(k_PhaseDOWN).edim) - 1;
    
    PhaseUPValues=full(dmTest.X(:,PhaseUP_cols(1)));
    PhaseDOWNValues=full(dmTest.X(:,PhaseDOWN_cols(1)));
    
    PBinStart=00:30:340;
    PBinStop=30:30:360;
    
    for P=1:12
        PhaseUPBinsForDM(:,P)=PhaseUPValues>PBinStart(P) & PhaseUPValues<PBinStop(P);
        PhaseDOWNBinsForDM(:,P)=PhaseDOWNValues>PBinStart(P) & PhaseDOWNValues<PBinStop(P);
    end
    
    dmTest.X(:,PhaseUP_cols)=PhaseUPBinsForDM;
    dmTest.X(:,PhaseDOWN_cols)=PhaseDOWNBinsForDM;
    
end





yTest = buildGLM.getBinnedSpikeTrain(expt, 'sptrain', testTrialIndices);
if isstr(lambda) % means it has been run with cvglmnet, and takes 'lambda_min'
    y_hat_pred = cvglmnetPredict(cvfit,dmTest.X,lambda);
else
    y_hat_pred = glmnetPredict(cvfit,dmTest.X,lambda);
end
% figure(2000+curClu);plot(zscore(y_hat_pred),'b');
% hold on
% yscat=full(yTest);
% yscat(yscat==0)=NaN;
% scatter(1:length(yscat),yscat,'k.');
% plot(zscore(smoothdata(full(yTest),'movmean',PredSmth)),'m')
% title(['ccPred:' num2str(corr(zscore(smoothdata(full(yTest),'movmean',PredSmth)),y_hat_pred))])
% clear yscat
