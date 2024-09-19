% Decomposition of acitivity of each brain region onto movement and movement-null subspaces 
% step 1: do PCA, save eigenvectors and FR matrices (fit and test) 

ChangeSpParams = allUnitsSumm.ChangeSpParams;
EarlyLickSpParams = allUnitsSumm.EarlyLickSpParams;
TFSpParams = allUnitsSumm.TFSpParams;
TFfrMult = TFSpParams.spAvgMult;
PSTHwindowTF = TFSpParams.PSTHwindow;

drawsNumb = 500; % cross-validation draws, 50/50 trials split on each draw. used for cross-val svd
maxPCsToUse = 4; % number of PCs to use 
sigma = 0.03; % sd of gaussian in s for smoothing fr
TFpValThresh = 0.01;

[BrainRegGroups, BrainRegGroupNames] = defineBrainRegGroupsV2;
count = 0;
groupID = [];

for g=1:length(BrainRegGroups)
    brRegGroup = BrainRegGroups{g};
    
    tic
    for k=1:length(brRegGroup)
        count = count+1;
        
        brRegOfIntr = brRegGroup{k};
        BrainRegNames{count} = BrainRegNamesLegendFriendly(brRegOfIntr);
        unitPerBrainReg = GroupDataPerBrainRegionDimRedCrossVal(allUnitsSumm, brRegOfIntr);
        
        frHitsWeakChangeBrRegTr = SpikesToFR(unitPerBrainReg.SpikesHitTrs(1,:), sigma, ChangeSpParams.binSize, ChangeSpParams.PSTHwindowExtra); % use activity on hit trials during change; 1.25 and 1.3 Hz                
        frCombCond = frHitsWeakChangeBrRegTr;
        [frMatrFit, frMatrTest, TFRespNonRespUnits, tooFewTrUnitInd] = constructFrMatrixCrossVal(unitPerBrainReg, frCombCond, TFpValThresh, drawsNumb, 'minmaxV2');

        frTFBaselineBrRegTr = SpikesToFR(unitPerBrainReg.SpikesTFBinTr(1,:), sigma, TFSpParams.binSize, TFSpParams.PSTHwindowExtra, TFfrMult); %  
        frTFdecrBrRegTr = SpikesToFR(unitPerBrainReg.SpikesTFBinTr(2,:), sigma, TFSpParams.binSize, TFSpParams.PSTHwindowExtra, TFfrMult); %  slow TF pulse 
        frTFincrBrRegTr = SpikesToFR(unitPerBrainReg.SpikesTFBinTr(3,:), sigma, TFSpParams.binSize, TFSpParams.PSTHwindowExtra, TFfrMult); %  fast TF pulse 
        frTFSeqIncrBrRegTr = SpikesToFR(unitPerBrainReg.SpikesTFSeqSpeedUpsTr(1,:), sigma, TFSpParams.binSize, TFSpParams.PSTHwindowExtra, TFfrMult); %  2 fast TF pulses 
        frTFSeqDecrBrRegTr = SpikesToFR(unitPerBrainReg.SpikesTFSeqSlowDownsTr(1,:), sigma, TFSpParams.binSize, TFSpParams.PSTHwindowExtra, TFfrMult); % 2 slow TF pulses
        
        frTFincrBrRegTr = cellfun(@minus, frTFincrBrRegTr, cellfun(@mean, frTFBaselineBrRegTr, 'UniformOutput', 0), 'UniformOutput',0);
        frTFdecrBrRegTr = cellfun(@minus, frTFdecrBrRegTr, cellfun(@mean, frTFBaselineBrRegTr, 'UniformOutput', 0), 'UniformOutput',0);
        frTFSeqIncrBrRegTr = cellfun(@minus, frTFSeqIncrBrRegTr, cellfun(@mean, frTFBaselineBrRegTr, 'UniformOutput', 0), 'UniformOutput',0);
        frTFSeqDecrBrRegTr = cellfun(@minus, frTFSeqDecrBrRegTr, cellfun(@mean, frTFBaselineBrRegTr, 'UniformOutput', 0), 'UniformOutput',0);

        frCombCondTF = [frTFincrBrRegTr ; frTFdecrBrRegTr; frTFSeqIncrBrRegTr; frTFSeqDecrBrRegTr];
        [frMatrTFFit, frMatrTFTest, ~, tooFewTrUnitIndTF] = constructFrMatrixCrossVal(unitPerBrainReg, frCombCondTF, TFpValThresh, drawsNumb, 'minmaxV2');   % construct FR matrix of TF speedups and slowdowns for a selected brain region

        % keep only units that are present in both sets ( for example early-lick aligned and at TF pulses)
        TFindToUse = 1:size(frCombCondTF,2);
        tooFewTrUnitIndA = find(ismember(TFindToUse, intersect(TFindToUse, tooFewTrUnitInd))==1);
        [~, tooFewTrUnitIndB, ~] = intersect(TFindToUse, tooFewTrUnitIndTF);

        frMatrFit = leaveOnlyCommonUnits(frMatrFit, tooFewTrUnitIndA, tooFewTrUnitIndB);
        frMatrTest = leaveOnlyCommonUnits(frMatrTest, tooFewTrUnitIndA, tooFewTrUnitIndB);
        frMatrTFTest = leaveOnlyCommonUnits(frMatrTFTest, tooFewTrUnitIndB, tooFewTrUnitIndA);        

        frMatrFitAllBrReg{count} = frMatrFit;
        frMatrTestAllBrReg{count} = frMatrTest;
        frMatrTFtestAllBrReg{count} = frMatrTFTest;
        TFRespNonRespAllBrReg{count} = TFRespNonRespUnits;
        
        RsqTest = [];
        uFitDraws = [];
        uTestDraws = [];
        
        for d=1:drawsNumb
            frMatrFitCntr = centerFrMatr(frMatrFit(:,:,d));
            frMatrTestCntr = centerFrMatr(frMatrTest(:,:,d));
            [uFit, s, v] = svd(frMatrFitCntr);
            [uTest, ~, ~] = svd(frMatrTestCntr);
            predFrMatrTot = 0;
            
            for i=1:maxPCsToUse
                predFrMatrPCi = uFit(:,i)*s(i,i)*v(:,i)';
                predFrMatrTot = predFrMatrTot+predFrMatrPCi;
                frMatrRes = predFrMatrTot - frMatrTestCntr;
                RsqTest(d,i) = 1 - sum(frMatrRes(:).^2)/sum(frMatrTestCntr(:).^2);
            end

            uTestDraws(:,:,d) = uTest(:, 1:maxPCsToUse);
            uFitDraws(:,:,d) = uFit(:, 1:maxPCsToUse);
        end
        
        tooFewTrUnitIndAllBrReg{count} = tooFewTrUnitInd;
        RsqTestAllBrReg(:,:,count) = RsqTest;
        eigVectFitAllBrReg{count} = uFitDraws;
        eigVectTestAllBrReg{count} = uTestDraws;
    end
    
    time = toc;
    disp([BrainRegGroupNames{g} ' took ' num2str(time/60,3) ' min'])
    groupID = [groupID repmat(g,1,length(BrainRegGroups{g}))];
end

clearvars -except allUnitsSumm BrainRegNames frMatrFitAllBrReg frMatrTestAllBrReg frMatrTFtestAllBrReg TFRespNonRespAllBrReg RsqTestAllBrReg eigVectFitAllBrReg eigVectTestAllBrReg groupID tooFewTrUnitIndAllBrReg CondNumb
