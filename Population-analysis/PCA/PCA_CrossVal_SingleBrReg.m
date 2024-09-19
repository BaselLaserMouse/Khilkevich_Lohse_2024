% Find projections on main principal components (in cross-validated way) of actiivty of selsected brain region aligned to a given event. 
% Show contributions of TF responsive and TF non-responsive units to these projections as well as what's expected from a random sample of the same number of units as there are TF responsive ones.

ChangeSpParams = allUnitsSumm.ChangeSpParams;
EarlyLickSpParams = allUnitsSumm.EarlyLickSpParams;
TFSpparams = allUnitsSumm.TFSpParams;
binSize = EarlyLickSpParams.binSize;

drawsNumb = 500; % cross-validation draws, 50/50 split on each draw. used for cross-val svd
drawsNumbRandTF = 20; % number of random combinations of units, the same sample size as the number of TF responsive ones, gets effectively multiplied by drawsNumb

maxPCsToUse = 4;  % number of PCs to use for a selected brain region
sigma = 0.03; % sd of gaussian in s for smoothing fr
TFpValThresh = 0.01; 
zeroInitialCond = 1;

brRegOfIntr = {'MOs'}; 

    
BrainRegNames = BrainRegNamesLegendFriendly(brRegOfIntr);
unitPerBrainReg = GroupDataPerBrainRegionDimRedCrossVal(allUnitsSumm, brRegOfIntr);

frHitsWeakChangeBrRegTr = SpikesToFR(unitPerBrainReg.SpikesHitTrs(1,:), sigma, ChangeSpParams.binSize, ChangeSpParams.PSTHwindowExtra); % use activity on hit trials during change (aligned to lick onsets); 1.25 and 1.3 Hz
frHitsModChangeBrRegTr = SpikesToFR(unitPerBrainReg.SpikesHitTrs(2,:), sigma, ChangeSpParams.binSize, ChangeSpParams.PSTHwindowExtr);  % 1.5 Hz
frHitsStrongChangeBrRegTr = SpikesToFR(unitPerBrainReg.SpikesHitTrs(3,:), sigma, ChangeSpParams.binSize, ChangeSpParams.PSTHwindowExtra); % 2 and 4 Hz
frEarlyLickBrRegTr = SpikesToFR(unitPerBrainReg.SpikesELTrs, sigma, EarlyLickSpParams.binSize, EarlyLickSpParams.PSTHwindowExtra); % early lick trials

frCombCond = frHitsWeakChangeBrRegTr; % 1.25 and 1.3Hz 
% frCombCond = frHitsModChangeBrRegTr;
% frCombCond = [frHitsWeakChangeBrRegTr; frHitsModChangeBrRegTr; frHitsStrongChangeBrRegTr];
% frCombCond = [frEarlyLickBrRegTr];

CondNumb = size(frCombCond,1);
[frMatrFit, frMatrTest, TFRespNonRespUnits, tooFewTrUnitInd] = constructFrMatrixCrossVal(unitPerBrainReg, frCombCond, TFpValThresh, drawsNumb, 'minmaxV2');
% [frMatrFit, frMatrTest, TFRespNonRespUnits, tooFewTrUnitInd] = constructFrMatrixCrossVal(unitPerBrainReg, frCombCond, TFpValThresh, drawsNumb);

varPerPCTest = [];
RsqTest = [];
frProjTest = [];
frProjTFRespTest = [];
frProjTFnonRespTest = [];
frProjTFRandSel = [];

for d=1:drawsNumb
    if d==1         %use eigenvector from the average across all draws as a template to realign for other draws 
        frMatrFitCntrAvg = centerFrMatr(mean(frMatrFit, 3));
        [uTempl, ~, vTempl] = svd(frMatrFitCntrAvg);                                 % 
        [frProjFitAvg, ~, ~, ~] = calcLowDProj(mean(frMatrFit, 3), uTempl(:,1:maxPCsToUse), [], drawsNumbRandTF);
        if  zeroInitialCond==1
            TimeIndToZeroMean = 1:round(0.5/binSize);
            frProjFitAvg = frProjFitAvg - mean(frProjFitAvg(:,TimeIndToZeroMean), 2);
        end        
        
        TimeIndToMotionOnsetExtra = 1:round((-ChangeSpParams.PSTHwindow(1)+0.5)/binSize);
        for dim = 1:size(frProjFitAvg,1)             % make the projection values to be positive
            if mean(frProjFitAvg(dim,TimeIndToMotionOnsetExtra))<0
                uTempl(:,dim) = -uTempl(:,dim);
            end
        end        
    end
    
    frMatrFitCntr = centerFrMatr(frMatrFit(:,:,d));
    frMatrTestCntr = centerFrMatr(frMatrTest(:,:,d));
    [uFit, sFit, vFit] = svd(frMatrFitCntr);
    
    predFrMatrTot = 0;
        for i=1:maxPCsToUse
            predFrMatrPCi = uFit(:,i)*sFit(i,i)*vFit(:,i)';
            predFrMatrTot = predFrMatrTot+predFrMatrPCi;
            frMatrResCurrPC = frMatrTestCntr-predFrMatrTot;
            RsqTest(d,i) = 1 - sum(frMatrResCurrPC(:).^2)/sum(frMatrTestCntr(:).^2);
            if i>1
                varPerPCTest(d,i) = RsqTest(d,i)-RsqTest(d,i-1); 
            else
                varPerPCTest(d,i) = RsqTest(d,i); 
            end
        end
    
    uFit = alignEigenVect(uFit(:, 1:maxPCsToUse), uTempl(:, 1:maxPCsToUse));
    [frProjTest(:,:,d), frProjTFRespTest(:,:,d), frProjTFnonRespTest(:,:,d), frProjTFRandSel(:,:,d)] = calcLowDProj(frMatrTest(:,:,d), uFit(:,1:maxPCsToUse), TFRespNonRespUnits, drawsNumbRandTF);  
            
    if  zeroInitialCond==1
        TimeIndToZeroMean = 1:round(0.5/binSize);
        frProjTest(:,:,d) = frProjTest(:,:,d) - mean(frProjTest(:,TimeIndToZeroMean, d), 2);
        frProjTFRespTest(:,:,d) = frProjTFRespTest(:,:,d) - mean(frProjTFRespTest(:,TimeIndToZeroMean, d), 2);
        frProjTFnonRespTest(:,:,d) = frProjTFnonRespTest(:,:,d) - mean(frProjTFnonRespTest(:,TimeIndToZeroMean, d), 2);
        frProjTFRandSel(:,:,d) = frProjTFRandSel(:,:,d) - mean(frProjTFRandSel(:,TimeIndToZeroMean, d), 2);
    end
end

%% Plot projections on principal components

colors = [[0.3010 0.7450 0.9330];
    [0.8500 0.3250 0.0980];
    [0 0.4470 0.7410];
    [0.6350 0.0780 0.1840];
];

PSTHwindow = ChangeSpParams.PSTHwindow;
binSize = ChangeSpParams.binSize;
timeBinsNumbPerCond = round((PSTHwindow(2)-PSTHwindow(1))/binSize);

for j=1:CondNumb
    CondIndPlot(j,:) = 1+(j-1)*timeBinsNumbPerCond:j*timeBinsNumbPerCond;
end

figure('units','normalized','outerposition',[0.05 0.15 0.6 0.25]);
conf =  [];

for i=1:maxPCsToUse  % PCs
    subplot(1,maxPCsToUse,i)
    hold on
    
    for j=1:CondNumb
        plots(1) = plot(PSTHwindow(1)+binSize:binSize:PSTHwindow(2), mean(frProjTest(i,CondIndPlot(j,:),:),3), 'color', 'k', 'LineWidth', 0.6);
        conf(1,:) = prctile(permute((frProjTest(i,CondIndPlot(j,:),:)), [3 2 1]), 2.5);
        conf(2,:) = prctile(permute((frProjTest(i,CondIndPlot(j,:),:)), [3 2 1]), 97.5);
        ciplot(conf(1,:), conf(2,:), PSTHwindow(1)+binSize:binSize:PSTHwindow(2), 'k', 0.3)

        plots(3) = plot(PSTHwindow(1)+binSize:binSize:PSTHwindow(2), mean(frProjTFnonRespTest(i,CondIndPlot(j,:),:),3), 'color', colors(2,:), 'LineWidth', 0.6);
        conf(1,:) = prctile(permute((frProjTFnonRespTest(i,CondIndPlot(j,:),:)), [3 2 1]), 2.5);
        conf(2,:) = prctile(permute((frProjTFnonRespTest(i,CondIndPlot(j,:),:)), [3 2 1]), 97.5); 
        ciplot(conf(1,:), conf(2,:), PSTHwindow(1)+binSize:binSize:PSTHwindow(2), colors(2,:), 0.3)        
        
        plots(2) = plot(PSTHwindow(1)+binSize:binSize:PSTHwindow(2), mean(frProjTFRespTest(i,CondIndPlot(j,:),:),3), 'color', colors(1,:), 'LineWidth', 0.6);
        conf(1,:) = prctile(permute((frProjTFRespTest(i,CondIndPlot(j,:),:)), [3 2 1]), 2.5);
        conf(2,:) = prctile(permute((frProjTFRespTest(i,CondIndPlot(j,:),:)), [3 2 1]), 97.5); 
        ciplot(conf(1,:), conf(2,:), PSTHwindow(1)+binSize:binSize:PSTHwindow(2), colors(1,:), 0.3)
        
        plots(4) = plot(PSTHwindow(1)+binSize:binSize:PSTHwindow(2), mean(frProjTFRandSel(i,CondIndPlot(j,:),:),3), 'color', [0.7 0.7 0.7], 'LineWidth', 0.6);
        conf(1,:) = prctile(permute((frProjTFRandSel(i,CondIndPlot(j,:),:)), [3 2 1]), 2.5);
        conf(2,:) = prctile(permute((frProjTFRandSel(i,CondIndPlot(j,:),:)), [3 2 1]), 97.5); 
        ciplot(conf(1,:), conf(2,:), PSTHwindow(1)+binSize:binSize:PSTHwindow(2), [0.7 0.7 0.7], 0.3)
    end
    
    yl = ylim;
    plot([0 0], [yl(1) yl(2)], '--k')
    ylabel(['Proj. on PC' num2str(i)], 'FontSize', 14)
    xlabel('Time from lick onset (s)')
    title([num2str(round(10000*mean(varPerPCTest(:,i)))/100) '% var'])
    axis([-2 1.5 yl])
end

sgtitle(brRegOfIntr, 'FontWeight', 'bold', 'FontSize', 14)















