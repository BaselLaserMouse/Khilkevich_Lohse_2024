function [dmTest,yTest,y_hat_pred]=PredictGLM(cvfit,curClu,expt,dspec,testTrialIndices,trainId,endTrialIndices,PredSmth)
%function [dmTest,yTest,y_hat_pred]=PredictGLM(cvfit,curClu,expt,dspec,testTrialIndices,trainId,endTrialIndices,PredSmth,Off_Phase_cols)

dmTest = buildGLM.compileSparseDesignMatrix(dspec, testTrialIndices');
%dmTest = buildGLM.removeConstantCols(dmTest);
%dmTest.X(:,Off_Phase_cols)=0; % remove phase columns that are not the estimated phase (this has been estimated from a revious model using laso regression)




yTest = buildGLM.getBinnedSpikeTrain(expt, 'sptrain', testTrialIndices);
y_hat_pred = cvglmnetPredict(cvfit,dmTest.X,'lambda_min');

% figure(2000+curClu);plot(zscore(y_hat_pred),'b');
% hold on
% yscat=full(yTest);
% yscat(yscat==0)=NaN;
% scatter(1:length(yscat),yscat,'k.');
% plot(zscore(smoothdata(full(yTest),'movmean',PredSmth)),'m')
% title(['ccPred:' num2str(corr(zscore(smoothdata(full(yTest),'movmean',PredSmth)),y_hat_pred))])
% clear yscat