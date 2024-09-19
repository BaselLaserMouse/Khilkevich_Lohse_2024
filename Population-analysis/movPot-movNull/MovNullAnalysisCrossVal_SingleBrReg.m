% main script to perform a decomposition of activity of selected brain region onto movement and movement-null subspaces 

ChangeSpParams = allUnitsSumm.ChangeSpParams;
EarlyLickSpParams = allUnitsSumm.EarlyLickSpParams;
PSTHwindow = ChangeSpParams.PSTHwindow;
binSize = ChangeSpParams.binSize;
TFSpParams = allUnitsSumm.TFSpParams;
TFfrMult = TFSpParams.spAvgMult;
PSTHwindowTF = TFSpParams.PSTHwindow;
allowIntercept = 0;

OutputdimToUse = 2; % number of movement dimensions to use
PCAdimToUse = 4;    % number of PCs to use from a selected brain region
zeroInitCond = 1;   % make projections on dimensions to start at zero 
findPrepdimInNullSpace = 1; % do rotation in movement-null subspace to find dimension that maximizes var of preparatory population

drawsNumb = 500; % number of cross-validation repeats 
drawsNumbRandTF = 10; % number of random combinations of units, the same sample size as the number of TF responsive ones, gets eefectively multiplied by drawsNumb
tRegStartBeforeLickOnset = 0.1; % specifies regression window before lick onset to find movement subspace
sigma = 0.03; % sd of gaussian in s for smoothing fr
TFpValThresh = 0.01; 
ZeroInitCondBaseDur = 0.5;

brRegOfIntr = {'MOs'}; 

unitsActBrainReg = GroupDataPerBrainRegionDimRedCrossVal(allUnitsSumm, brRegOfIntr);
% activity of selected brain region on hit trials, aligned to lick onsets
frHitsWeakChangeBrRegTr = SpikesToFR(unitsActBrainReg.SpikesHitTrs(1,:), sigma, ChangeSpParams.binSize, ChangeSpParams.PSTHwindowExtra); % use activity on hit trials during change; 1.25 and 1.3 Hz
frHitsModChangeBrRegTr = SpikesToFR(unitsActBrainReg.SpikesHitTrs(2,:), sigma, ChangeSpParams.binSize, ChangeSpParams.PSTHwindowExtra);  % 1.5 Hz
frHitsStrongChangeBrRegTr = SpikesToFR(unitsActBrainReg.SpikesHitTrs(3,:), sigma, ChangeSpParams.binSize, ChangeSpParams.PSTHwindowExtra); % 2 and 4 Hz
frEarlyLickBrRegTr = SpikesToFR(unitsActBrainReg.SpikesELTrs, sigma, EarlyLickSpParams.binSize, EarlyLickSpParams.PSTHwindowExtra); % fast early lick trials

frCombCond = [ frHitsWeakChangeBrRegTr ];
% frCombCond = [frHitsWeakChangeBrRegTr; frHitsModChangeBrRegTr; frHitsStrongChangeBrRegTr];

[frMatrFit, frMatrTest, TFRespNonRespUnits, tooFewTrUnitInd] = constructFrMatrixCrossVal(unitsActBrainReg, frCombCond, TFpValThresh, drawsNumb, 'minmaxV2');
CondNumb = size(frCombCond,1);

% responses to TF pulses 
frTFBaselineBrRegTr = SpikesToFR(unitsActBrainReg.SpikesTFBinTr(1,:), sigma, TFSpParams.binSize, TFSpParams.PSTHwindowExtra, TFfrMult); 
frTFdecrBrRegTr = SpikesToFR(unitsActBrainReg.SpikesTFBinTr(2,:), sigma, TFSpParams.binSize, TFSpParams.PSTHwindowExtra, TFfrMult); % slow TF pulse 
frTFincrBrRegTr = SpikesToFR(unitsActBrainReg.SpikesTFBinTr(3,:), sigma, TFSpParams.binSize, TFSpParams.PSTHwindowExtra, TFfrMult); % fast TF pulse
frTFincrBrRegTr = cellfun(@minus, frTFincrBrRegTr, cellfun(@mean, frTFBaselineBrRegTr, 'UniformOutput', 0), 'UniformOutput',0);     
frTFdecrBrRegTr = cellfun(@minus, frTFdecrBrRegTr, cellfun(@mean, frTFBaselineBrRegTr, 'UniformOutput', 0), 'UniformOutput',0);

frTFSeqDecrBrRegTr = SpikesToFR(unitsActBrainReg.SpikesTFSeqSlowDownsTr(1,:), sigma, TFSpParams.binSize, TFSpParams.PSTHwindowExtra, TFfrMult); % 2 slow TF pulses
frTFSeqIncrBrRegTr = SpikesToFR(unitsActBrainReg.SpikesTFSeqSpeedUpsTr(1,:), sigma, TFSpParams.binSize, TFSpParams.PSTHwindowExtra, TFfrMult); % 2 fast TF pulses
frTFSeqDecrBrRegTr = cellfun(@minus, frTFSeqDecrBrRegTr, cellfun(@mean, frTFBaselineBrRegTr, 'UniformOutput', 0), 'UniformOutput',0);
frTFSeqIncrBrRegTr = cellfun(@minus, frTFSeqIncrBrRegTr, cellfun(@mean, frTFBaselineBrRegTr, 'UniformOutput', 0), 'UniformOutput',0);

frCombCondTF = [frTFincrBrRegTr ; frTFdecrBrRegTr ; frTFSeqIncrBrRegTr; frTFSeqDecrBrRegTr];  % concatenate conditions in time
CondNumbTF = size(frCombCondTF,1);

frAvgMatr = cell2mat(cellfun(@(x) mean(x,1), frCombCond, 'UniformOutput', false)'); 
frRange = (max(frAvgMatr,[],2)-min(frAvgMatr,[],2));   

[frMatrTFFit, frMatrTFTest, ~, tooFewTrUnitIndTF] = constructFrMatrixCrossVal(unitsActBrainReg, frCombCondTF, TFpValThresh, drawsNumb, 'minmaxV2');   % construct fr matrix at TF speedups and slowdowns for a selected brain region

% the same for orofacial motor nuclei
OroFacialNucForDimRedAn = {'Orofacial Mot. Nuc.'};
unitsActOrofacNuc = GroupDataPerBrainRegionDimRedCrossVal(allUnitsSumm, OroFacialNucForDimRedAn);
                    
frHitsWeakChangeOutTr = SpikesToFR(unitsActOrofacNuc.SpikesHitTrs(1,:), sigma, ChangeSpParams.binSize, ChangeSpParams.PSTHwindowExtra); % use activity on hit trials during change; 1.25 and 1.3 Hz
frHitsModChangeOutTr = SpikesToFR(unitsActOrofacNuc.SpikesHitTrs(2,:), sigma, ChangeSpParams.binSize, ChangeSpParams.PSTHwindowExtra);  % 1.5 Hz
frHitsStrongChangeOutTr = SpikesToFR(unitsActOrofacNuc.SpikesHitTrs(3,:), sigma, ChangeSpParams.binSize, ChangeSpParams.PSTHwindowExtra); % 2 and 4 Hz
frOutCombCond = [frHitsWeakChangeOutTr ];

[frMatrFitOut, frMatrTestOut, ~, ~] = constructFrMatrixCrossVal(unitsActOrofacNuc, frOutCombCond, TFpValThresh, drawsNumb, 'minmaxV2');

% keep only units that are present in both sets (for example early-lick aligned and at TF pulses)
TFindToUse = 1:size(frCombCondTF,2);
tooFewTrUnitIndA = find(ismember(TFindToUse, intersect(TFindToUse, tooFewTrUnitInd))==1);
[~, tooFewTrUnitIndB, ~] = intersect(TFindToUse, tooFewTrUnitIndTF);

frMatrFit = leaveOnlyCommonUnits(frMatrFit, tooFewTrUnitIndA, tooFewTrUnitIndB);
frMatrTest = leaveOnlyCommonUnits(frMatrTest, tooFewTrUnitIndA, tooFewTrUnitIndB);
frMatrTFTest = leaveOnlyCommonUnits(frMatrTFTest, tooFewTrUnitIndB, tooFewTrUnitIndA);
TFRespNonRespUnits = leaveOnlyCommonUnits(TFRespNonRespUnits, tooFewTrUnitIndA, tooFewTrUnitIndB);

regrWind = [];
frVectLength = size(frMatrFitOut,2)/CondNumb;
for i=1:CondNumb
    regrWind = [regrWind frVectLength*(i-1)+(round((-PSTHwindow(1)-tRegStartBeforeLickOnset)/binSize):frVectLength)];
end

% movement-potent/movenment-null space analysis
options = optimoptions('lsqnonlin', 'MaxFunEvals', 30000, 'MaxIter', 300, 'display','off');
if allowIntercept==0
    init = zeros(OutputdimToUse, PCAdimToUse);
elseif allowIntercept==1
    init = zeros(OutputdimToUse, PCAdimToUse+1);
end

movPotProjTest = [];
movPotProjTFRespTest = [];
movPotProjTFNonRespTest = [];
movPotProjTRandSelTest = [];
frProjHitsOutTestDraws = [];
nullProjTFRespTest = [];
nullProjTest = [];
nullProjTFNonRespTest = [];
nullProjTRandSelTest = [];
varExplNullRot = [];
RSqTest = [];

movPotProj_TFfr = [];
movPotProj_TFfrTFResp = [];
movPotProj_TFfrTFNonResp = [];
movPotProj_TFfrRandSel = [];
nullProj_TFfrTFResp = [];
nullProj_TFfr = [];
nullProj_TFfrTFNonResp = [];
nullProj_TFfrTRandSel = [];
loadingsPrepDimMovNull = [];
loadingsDim2MovNull = [];
loadingsDim1MovPot = [];
loadingsDim2MovPot = [];

timeBinsNumbPerCond = round((PSTHwindow(2)-PSTHwindow(1))/binSize);
CondIndPlot = [];
for j=1:CondNumb
    CondIndPlot(j,:) = 1+(j-1)*timeBinsNumbPerCond:j*timeBinsNumbPerCond;
end

timeBinsNumbPerCondTF = round((TFSpParams.PSTHwindow(2)-TFSpParams.PSTHwindow(1))/TFSpParams.binSize);
CondIndTFPlot = [];
for j=1:CondNumbTF
    CondIndTFPlot(j,:) = 1+(j-1)*timeBinsNumbPerCondTF:j*timeBinsNumbPerCondTF;
end

TFRespHPeakW = unitsActBrainReg.TFRespHPeakW;
TFRespHPeakW(tooFewTrUnitIndA) = [];

for d=1:drawsNumb
     
     if d==1 % use eigenvector from the average across all draws as a template to realign for other draws 
        frMatrFitOutCntrAvg = centerFrMatr(mean(frMatrFitOut,3));
        [uTemplOut, ~, ~] = svd(frMatrFitOutCntrAvg);      % do PCA on orofacial motor nuclei activity
        frMatrFitCntrAvg = centerFrMatr(mean(frMatrFit, 3));
        [uTemplSel, ~, ~] = svd(frMatrFitCntrAvg);         % and PCA on target brain region activity
        
        [frProjHitsOutFitAvg, ~, ~, ~] = calcLowDProj(mean(frMatrFitOut,3), uTemplOut(:,1:OutputdimToUse), [], drawsNumbRandTF); 
        [frProjHitsFitAvg, frProjHitsTFRespFitAvg, ~, ~] = calcLowDProj(mean(frMatrFit, 3), uTemplSel(:,1:PCAdimToUse), TFRespNonRespUnits, drawsNumbRandTF);  % find projections on PCs from full population and a contribution of TF respoonsive units 

        if zeroInitCond==1  % zero initial condition (values of projections at [-2 -1.5s] from lick onset)
            TimeIndToZeroMean = 1:round(ZeroInitCondBaseDur/binSize);
            frProjHitsOutFitAvg = frProjHitsOutFitAvg - mean(frProjHitsOutFitAvg(:,TimeIndToZeroMean),2);  
            frProjHitsFitAvg = frProjHitsFitAvg - mean(frProjHitsFitAvg(:,TimeIndToZeroMean),2);  
            frProjHitsTFRespFitAvg = frProjHitsTFRespFitAvg - mean(frProjHitsTFRespFitAvg(:,TimeIndToZeroMean),2);  
        end
        
        TimeIndToMotionOnset = 1:round(-PSTHwindow(1)/binSize);
        TimeIndToMotionOnsetExtra = 1:round((-PSTHwindow(1)+ZeroInitCondBaseDur)/binSize);
        
        for dim = 1:size(frProjHitsOutFitAvg,1)             % make the projetion values to be positive
            if mean(frProjHitsOutFitAvg(dim,TimeIndToMotionOnsetExtra))<0
                uTemplOut(:,dim) = -uTemplOut(:,dim);
                frProjHitsOutFitAvg(dim,:) = -frProjHitsOutFitAvg(dim,:);
            end
        end
        if allowIntercept==1
            f=@(x) x(:,1:end-1)*frProjHitsFitAvg(:,regrWind) - frProjHitsOutFitAvg(:,regrWind) + x(:,end);
        else
            f=@(x) x*frProjHitsFitAvg(:,regrWind) - frProjHitsOutFitAvg(:,regrWind);
        end
        
        w = lsqnonlin(f, init, [],[],options);  % find best mapping onto mov-potent subspace
        if allowIntercept==1
            wOrig = w(:,1:end-1);
        else
            wOrig = w;
        end
        wNull = null(wOrig); %find mov-null subspace
        wNullOrig = wNull'; 
        wNullOrig = wNullOrig*norm(wOrig)/norm(wNullOrig); %make norms of both operators to be the same 
    
        if findPrepdimInNullSpace==1  % find a rotation in mov-null subspace to get a dimension within that subspace that captures max of preparatory activity of full population 
            % calc projections to mov-null subspace
            nullProjFullAvg = wNullOrig*frProjHitsFitAvg;  
            [uTemplNullrot, sNull, ~] = svd(nullProjFullAvg(:, reshape(CondIndPlot(:,TimeIndToMotionOnset)',1,[])));  % maximize projection of preparatory activity of full population
            varExplNullRot = 100*diag(sNull).^2/sum(diag(sNull.^2));

            wNull = uTemplNullrot'*wNullOrig;
            nullProjTFRespAvg = wNull*frProjHitsTFRespFitAvg;  
            nullProjFullAvg = wNull*frProjHitsFitAvg;
            
            for dim = 1:size(nullProjTFRespAvg,1)                   % make the projection values to be positive
                if mean(nullProjTFRespAvg(dim,TimeIndToMotionOnset))<0
                    uTemplNullrot(:,dim) = -uTemplNullrot(:,dim) ; 
                end
            end
        end    
     end    

    % repeat the process for each draw:

    % do PCA on orofacial nuclei activity
    frMatrFitOutCntr = centerFrMatr(frMatrFitOut(:,:,d));
    frMatrTestOutCntr = centerFrMatr(frMatrTestOut(:,:,d));
    [uOutFit, ~, ~] = svd(frMatrFitOutCntr);
    [uOutTest, ~, ~] = svd(frMatrTestOutCntr);    
    
    uOutFit = alignEigenVect(uOutFit(:, 1:OutputdimToUse), uTemplOut(:, 1:OutputdimToUse));
    uOutTest = alignEigenVect(uOutTest(:, 1:OutputdimToUse), uTemplOut(:, 1:OutputdimToUse));
    
    % do PCA on selected brain region activity
    frMatrFitCntr = centerFrMatr(frMatrFit(:,:,d));
    frMatrTestCntr = centerFrMatr(frMatrTest(:,:,d));
    [uFit, ~, ~] = svd(frMatrFitCntr);
    [uTest, ~, ~] = svd(frMatrTestCntr);    
 
    uFit = alignEigenVect(uFit(:, 1:PCAdimToUse), uTemplSel(:, 1:PCAdimToUse));
    uTest = alignEigenVect(uTest(:, 1:PCAdimToUse), uTemplSel(:, 1:PCAdimToUse));    
    
    % find lowD projections 
    [frProjHitsFit, frProjHitsTFRespFit, frProjHitsTFNonRespFit, frProjHitsRandSelFit] = calcLowDProj(frMatrFit(:,:,d), uFit(:,1:PCAdimToUse), TFRespNonRespUnits, drawsNumbRandTF);    
    [frProjHitsTest, frProjHitsTFRespTest, frProjHitsTFNonRespTest, frProjHitsRandSelTest] = calcLowDProj(frMatrTest(:,:,d), uTest(:,1:PCAdimToUse), TFRespNonRespUnits, drawsNumbRandTF);
    [frProjHitsOutFit, ~, ~, ~] = calcLowDProj(frMatrFitOut(:,:,d), uOutFit(:,1:OutputdimToUse), [], drawsNumbRandTF);
    [frProjHitsOutTest, ~, ~, ~] = calcLowDProj(frMatrTestOut(:,:,d), uOutTest(:,1:OutputdimToUse), [], drawsNumbRandTF);
    
    [frTFProj, frTFProjTFResp, frTFProjTFNonResp, frTFProjRandSel] = calcLowDProj(frMatrTFTest(:,:,d), uTemplSel(:,1:PCAdimToUse), TFRespNonRespUnits, drawsNumbRandTF);        % project responses to TF pulses onto PCs of hit lick aligned activity 

    if  zeroInitCond==1 % 
        TimeIndToZeroMean = reshape(CondIndPlot(:,1:round(ZeroInitCondBaseDur/binSize))',1,[]);
        TimeIndToZeroMeanTF = reshape(CondIndTFPlot(:,1:round(ZeroInitCondBaseDur/binSize))',1,[]);
        
        initStateProjAll = mean(frProjHitsFit(:,TimeIndToZeroMean),2);
        frProjHitsFit = frProjHitsFit - initStateProjAll;
        frProjHitsTFRespFit = frProjHitsTFRespFit - mean(frProjHitsTFRespFit(:,TimeIndToZeroMean),2);
        frProjHitsTFNonRespFit = frProjHitsTFNonRespFit - mean(frProjHitsTFNonRespFit(:,TimeIndToZeroMean),2);
        frProjHitsRandSelFit = frProjHitsRandSelFit - mean(frProjHitsRandSelFit(:,TimeIndToZeroMean),2);
        frProjHitsOutFit = frProjHitsOutFit - mean(frProjHitsOutFit(:,TimeIndToZeroMean),2);
        
        frProjHitsTest = frProjHitsTest - mean(frProjHitsTest(:,TimeIndToZeroMean),2);
        frProjHitsTFRespTest = frProjHitsTFRespTest - mean(frProjHitsTFRespTest(:,TimeIndToZeroMean),2);
        frProjHitsTFNonRespTest = frProjHitsTFNonRespTest - mean(frProjHitsTFNonRespTest(:,TimeIndToZeroMean),2);
        frProjHitsRandSelTest = frProjHitsRandSelTest - mean(frProjHitsRandSelTest(:,TimeIndToZeroMean),2);
        frProjHitsOutTest = frProjHitsOutTest - mean(frProjHitsOutTest(:,TimeIndToZeroMean),2);  

        for TFcond = 1:size(CondIndTFPlot,1)  % zero initial condition for each TF pulse type 
            TFbaseInd = CondIndTFPlot(TFcond,1:round(ZeroInitCondBaseDur/binSize));
            TFIndFull = CondIndTFPlot(TFcond,:);
            frTFProj(:,TFIndFull) = frTFProj(:,TFIndFull) - mean(frTFProj(:,TFbaseInd),2);
            frTFProjTFResp(:,TFIndFull) = frTFProjTFResp(:,TFIndFull) - mean(frTFProjTFResp(:,TFbaseInd),2);
            frTFProjTFNonResp(:,TFIndFull) = frTFProjTFNonResp(:,TFIndFull) - mean(frTFProjTFNonResp(:,TFbaseInd),2);
            frTFProjRandSel(:,TFIndFull) = frTFProjRandSel(:,TFIndFull) - mean(frTFProjRandSel(:,TFbaseInd),2);
        end
    end
    
        if allowIntercept==1
            f=@(x) x(:,1:end-1)*frProjHitsFit(:,regrWind) - frProjHitsOutFit(:,regrWind) + x(:,end);
        else
            f=@(x) x*frProjHitsFit(:,regrWind) - frProjHitsOutFit(:,regrWind);
        end
        w = lsqnonlin(f, init, [],[],options);  % find best mapping onto mov-potent subspace

        if allowIntercept==1
            intercept = w(:,end);
            w = w(:,1:end-1);
        else
            intercept = zeros(size(w,1),1);
        end
        
    w = alignEigenVect(w, wOrig);            
    
    movPotProjTest(:,:,d) = w*frProjHitsTest+intercept;   % calc projections to  mov-potent subspace
    movPotProjTFRespTest(:,:,d) = w*frProjHitsTFRespTest+intercept;
    movPotProjTFNonRespTest(:,:,d) = w*frProjHitsTFNonRespTest+intercept;
    movPotProjTRandSelTest(:,:,d) = w*frProjHitsRandSelTest+intercept;
    
    % repeat for TF pulse(s) aligned activity
    movPotProj_TFfr(:,:,d) = wOrig*frTFProj;  
    movPotProj_TFfrTFResp(:,:,d) = wOrig*frTFProjTFResp;
    movPotProj_TFfrTFNonResp(:,:,d) = wOrig*frTFProjTFNonResp;
    movPotProj_TFfrRandSel(:,:,d) = wOrig*frTFProjRandSel;   
    
    loadingsDim1MovPot(:,d) = uTest*w(1,:)';
    try
        loadingsDim2MovPot(:,d) = uTest*w(2,:)';
    end
    wNull = null(w); 
    wNull = wNull';           
    wNull = alignEigenVect(wNull, wNullOrig);            
    
    nullProjTFResp = wNull*frProjHitsTFRespTest;
    if findPrepdimInNullSpace==1  % find a rotation in mov-null subspace that has a dimension that captures max of TF-pop variance 
        % [rotNull, sNull, ~] = svd(nullProjTFResp);
        % rotNull = alignEigenVect(rotNull, uTemplNullrot);   
        rotNull = uTemplNullrot;
        wNull = rotNull'*wNull;
        wNullTF = rotNull'*wNullOrig;
    end    
    
    % make both operators to have the same norm; should make the comparison across projections more fair
    wNull = wNull*norm(w)/norm(wNull);
    loadingsPrepDimMovNull(:,d) = uTest*wNull(1,:)';
    try
        loadingsDim2MovNull(:,d) = uTest*wNull(2,:)';
    end
    
    % calc projections to mov-null subspace
    nullProjTest(:,:,d) = wNull*frProjHitsTest;
    nullProjTFRespTest(:,:,d) = wNull*frProjHitsTFRespTest;
    nullProjTFNonRespTest(:,:,d) = wNull*frProjHitsTFNonRespTest;
    nullProjTRandSelTest(:,:,d) = wNull*frProjHitsRandSelTest;
    
    % repeat for TF pulse(s) aligned activity 
    nullProj_TFfr(:,:,d) = wNullTF*frTFProj;
    nullProj_TFfrTFResp(:,:,d) = wNullTF*frTFProjTFResp;
    nullProj_TFfrTFNonResp(:,:,d) = wNullTF*frTFProjTFNonResp;
    nullProj_TFfrTRandSel(:,:,d) = wNullTF*frTFProjRandSel;    

    movPotProjTest1d = reshape(movPotProjTest(:,:,d)',1,[]);
    frProjHitsOutTest1d = reshape(frProjHitsOutTest',1,[]);
    RSqTest(d) = 1 - sum((frProjHitsOutTest1d-movPotProjTest1d).^2)/sum((frProjHitsOutTest1d-mean(frProjHitsOutTest1d)).^2);
    frProjHitsOutTestDraws(:,:,d) = frProjHitsOutTest;
end

%%  Plot distribution of loadings of 1st mov-null dimension for TF responsive and TF-non-responsive units 

figure('units','normalized','outerposition',[0.15 0.3 0.2 0.35]);
range = max(abs(loadingsPrepDimMovNull(:)));
bin = range/10;
bins = -range+0.5*bin:bin:range-bin*0.5;

hold on
histogram(mean(loadingsPrepDimMovNull(TFRespNonRespUnits==1,:),2), bins, 'DisplayStyle', 'stairs', 'Normalization', 'probability', 'EdgeColor', 'b', 'LineWidth', 2)
histogram(mean(loadingsPrepDimMovNull(TFRespNonRespUnits==0,:),2), bins, 'DisplayStyle', 'stairs', 'Normalization', 'probability', 'EdgeColor', 'r', 'LineWidth', 2)
legend('TF-resp.', 'TF-nonresp.', 'autoupdate', 'off')
legend box off
yl = ylim;
plot([0 0], yl, '--k', 'LineWidth', 1)
xlabel('Loadings of TF-dim.')
 
sgtitle(BrainRegNamesLegendFriendly(brRegOfIntr), 'FontWeight', 'bold', 'FontSize', 14)

[~, p] = ttest2(abs(mean(loadingsPrepDimMovNull(TFRespNonRespUnits==1,:),2)), abs(mean(loadingsPrepDimMovNull(TFRespNonRespUnits==0,:),2)));

%% Plot projections to mov-pot and mov-null dimensions
PlotRowsNumb = 2;
colors = [[0.3010 0.7450 0.9330];
    [0.8500 0.3250 0.0980];
    [0 0.4470 0.7410];
    [0.6350 0.0780 0.1840];
];

if PlotRowsNumb ==1
    figure('units','normalized','outerposition',[0.05 0.35 0.9 0.4]);
elseif PlotRowsNumb==2
    figure('units','normalized','outerposition',[0 0.15 1 0.6]);
end

plots = [];
conf = [];
% plot projections on mov-pot space
for i=1:PlotRowsNumb
    subplot(PlotRowsNumb,5,1+(i-1)*5)
    hold on

    for j=1:CondNumb
        plots(1) = plot(PSTHwindow(1)+binSize:binSize:PSTHwindow(2), mean(frProjHitsOutTestDraws(i,CondIndPlot(j,:),:),3), 'color', [0 0.8 0], 'LineWidth', 2);
        conf(1,:) = prctile(permute((frProjHitsOutTestDraws(i,CondIndPlot(j,:),:)), [3 2 1]), 2.5);
        conf(2,:) = prctile(permute((frProjHitsOutTestDraws(i,CondIndPlot(j,:),:)), [3 2 1]), 97.5);
        ciplot(conf(1,:), conf(2,:), PSTHwindow(1)+binSize:binSize:PSTHwindow(2), [0 0.8 0], 0.3)

        plots(4) = plot(PSTHwindow(1)+binSize:binSize:PSTHwindow(2), mean(movPotProjTFNonRespTest(i,CondIndPlot(j,:),:),3), 'color', colors(2,:), 'LineWidth', 2);
        conf(1,:) = prctile(permute((movPotProjTFNonRespTest(i,CondIndPlot(j,:),:)), [3 2 1]), 2.5);
        conf(2,:) = prctile(permute((movPotProjTFNonRespTest(i,CondIndPlot(j,:),:)), [3 2 1]), 97.5); 
        ciplot(conf(1,:), conf(2,:), PSTHwindow(1)+binSize:binSize:PSTHwindow(2), colors(2,:), 0.3)
        
        plots(2) = plot(PSTHwindow(1)+binSize:binSize:PSTHwindow(2), mean(movPotProjTest(i,CondIndPlot(j,:),:),3), 'k', 'LineWidth', 2);
        conf(1,:) = prctile(permute((movPotProjTest(i,CondIndPlot(j,:),:)), [3 2 1]), 2.5);
        conf(2,:) = prctile(permute((movPotProjTest(i,CondIndPlot(j,:),:)), [3 2 1]), 97.5); 
        ciplot(conf(1,:), conf(2,:), PSTHwindow(1)+binSize:binSize:PSTHwindow(2), 'k', 0.3)
                
        plots(5) = plot(PSTHwindow(1)+binSize:binSize:PSTHwindow(2), mean(movPotProjTRandSelTest(i,CondIndPlot(j,:),:),3), 'color',[0.7 0.7 0.7], 'LineWidth', 2);
        conf(1,:) = prctile(permute((movPotProjTRandSelTest(i,CondIndPlot(j,:),:)), [3 2 1]), 2.5);
        conf(2,:) = prctile(permute((movPotProjTRandSelTest(i,CondIndPlot(j,:),:)), [3 2 1]), 97.5); 
        ciplot(conf(1,:), conf(2,:), PSTHwindow(1)+binSize:binSize:PSTHwindow(2), [0.7 0.7 0.7], 0.3)

        plots(3) = plot(PSTHwindow(1)+binSize:binSize:PSTHwindow(2), mean(movPotProjTFRespTest(i,CondIndPlot(j,:),:),3), 'color', colors(1,:), 'LineWidth', 2);
        conf(1,:) = prctile(permute((movPotProjTFRespTest(i,CondIndPlot(j,:),:)), [3 2 1]), 2.5);
        conf(2,:) = prctile(permute((movPotProjTFRespTest(i,CondIndPlot(j,:),:)), [3 2 1]), 97.5); 
        ciplot(conf(1,:), conf(2,:), PSTHwindow(1)+binSize:binSize:PSTHwindow(2), colors(1,:), 0.3)        
     end
    
    yl = ylim;
    plot([0 0], [yl(1) yl(2)], '--k')
    ciplot([yl(1), yl(1)], [yl(2) yl(2)], [PSTHwindow(1)+regrWind(1)*binSize PSTHwindow(1)+regrWind( round(length(regrWind)/CondNumb) )*binSize], [0.8 0.8 0.8], 0.4)
    if i==1
        title(['R^2 = ' num2str(mean(RSqTest),3)])
    end
    if i==1
        legend(plots, {'Orofacial nuclei', 'Full mov-pot.', 'TF-resp.', 'TF non-resp.', 'randon sample'},'autoupdate', 'off', 'Location', 'best')
        legend box off
    end

    xlabel('Time from Lick onset, s', 'FontSize', 14)
    ylabel(['Projection on movement dim. ' num2str(i) ', a.u.'], 'FontSize', 14, 'Color',  [0 0.8 0])
    axis([-2 1.5 yl])
end

for i=1:PlotRowsNumb
    subplot(PlotRowsNumb,5,2+(i-1)*5)
    hold on
    
    for j=1:CondNumb
        plot(PSTHwindow(1)+binSize:binSize:PSTHwindow(2), mean(nullProjTFNonRespTest(i,CondIndPlot(j,:),:),3), 'color', colors(2,:), 'LineWidth', 2);
        conf(1,:) = prctile(permute((nullProjTFNonRespTest(i,CondIndPlot(j,:),:)), [3 2 1]), 2.5);
        conf(2,:) = prctile(permute((nullProjTFNonRespTest(i,CondIndPlot(j,:),:)), [3 2 1]), 97.5); 
        ciplot(conf(1,:), conf(2,:), PSTHwindow(1)+binSize:binSize:PSTHwindow(2), colors(2,:), 0.3) 
        
        pl = plot(PSTHwindow(1)+binSize:binSize:PSTHwindow(2), mean(nullProjTest(i,CondIndPlot(j,:),:),3), 'k', 'LineWidth', 2);
        conf(1,:) = prctile(permute((nullProjTest(i,CondIndPlot(j,:),:)), [3 2 1]), 2.5);
        conf(2,:) = prctile(permute((nullProjTest(i,CondIndPlot(j,:),:)), [3 2 1]), 97.5); 
        ciplot(conf(1,:), conf(2,:), PSTHwindow(1)+binSize:binSize:PSTHwindow(2), 'k', 0.3) 
        
        plot(PSTHwindow(1)+binSize:binSize:PSTHwindow(2), mean(nullProjTFRespTest(i,CondIndPlot(j,:),:),3), 'color', colors(1,:), 'LineWidth', 2);    
        conf(1,:) = prctile(permute((nullProjTFRespTest(i,CondIndPlot(j,:),:)), [3 2 1]), 2.5);
        conf(2,:) = prctile(permute((nullProjTFRespTest(i,CondIndPlot(j,:),:)), [3 2 1]), 97.5); 
        ciplot(conf(1,:), conf(2,:), PSTHwindow(1)+binSize:binSize:PSTHwindow(2), colors(1,:), 0.3) 

        plot(PSTHwindow(1)+binSize:binSize:PSTHwindow(2), mean(nullProjTRandSelTest(i,CondIndPlot(j,:),:),3), 'color',[0.7 0.7 0.7], 'LineWidth', 2);
        conf(1,:) = prctile(permute((nullProjTRandSelTest(i,CondIndPlot(j,:),:)), [3 2 1]), 2.5);
        conf(2,:) = prctile(permute((nullProjTRandSelTest(i,CondIndPlot(j,:),:)), [3 2 1]), 97.5); 
        ciplot(conf(1,:), conf(2,:), PSTHwindow(1)+binSize:binSize:PSTHwindow(2), [0.7 0.7 0.7], 0.3) 
    end
    
    try
        title([ num2str(varExplNullRot(i),3) '% of variance'  ])
    end
        chanceRat = sum(TFRespNonRespUnits)/length(TFRespNonRespUnits);
    if i ==1
        legend(pl, [ num2str(100*chanceRat,3) '% of TF-responsive units'  ], 'autoupdate', 'off')
        legend box off
    end
    yl1 = ylim;
    plot([0 0], [yl1(1) yl1(2)], '--k')
    axis([-2 1.5 yl1])

    xlabel('Time from Lick onset, s', 'FontSize', 14)
    ylabel(['Projection on movement-null dim. ' num2str(i) ', a.u.' ], 'FontSize', 14)
end

% 2D state-space trajectory
comb = [1 1];
CBTickSpacing = 0.5; %s     
for i=1:size(comb,1)
    subplot(PlotRowsNumb,5,3)
    hold on
    for j=1:CondNumb
        MOind = -PSTHwindow(1)/binSize+CondIndPlot(j,1);
    
        scatter(mean(movPotProjTest(comb(i,1),CondIndPlot(j,:),:),3), mean(nullProjTest(comb(i,2),CondIndPlot(j,:),:),3), 10, 'k', 'filled')
        scatter(mean(movPotProjTest(comb(i,1),MOind,:),3),mean(nullProjTest(comb(i,2),MOind,:),3), 100, 'k',  'filled')    
        
        scatter(mean(movPotProjTFRespTest(comb(i,1),CondIndPlot(j,:),:),3), mean(nullProjTFRespTest(comb(i,2),CondIndPlot(j,:),:),3), 10, colors(1,:), 'filled')
        scatter(mean(movPotProjTFRespTest(comb(i,1),MOind,:),3),mean(nullProjTFRespTest(comb(i,2),MOind,:),3), 100, colors(1,:),  'filled')
        
        scatter(mean(movPotProjTFNonRespTest(comb(i,1),CondIndPlot(j,:),:),3), mean(nullProjTFNonRespTest(comb(i,2),CondIndPlot(j,:),:),3), 10, colors(2,:), 'filled')
        scatter(mean(movPotProjTFNonRespTest(comb(i,1),MOind,:),3),mean(nullProjTFNonRespTest(comb(i,2),MOind,:),3), 100,  colors(2,:),  'filled')
    end
    xlabel(['Projection on movement dim. ' num2str(comb(i,1))], 'FontSize', 14)
    ylabel(['Projection on movement-null dim. ' num2str(comb(i,2)) ], 'FontSize', 14)
    
    axMin = min([xlim ylim]);
    axMax = max([xlim ylim]);
    axis([axMin axMax axMin axMax])
end
colors = lines(6);

movPotEuqDist = sqrt(sum(movPotProjTest.^2,1));
movNullEuqDist = sqrt(sum(nullProjTest.^2,1));
movNullVsPotDistRat = (movNullEuqDist-movPotEuqDist)./(movNullEuqDist+movPotEuqDist);

% relatve susbspace occupancy 
subplot(PlotRowsNumb,5,4)
hold on
for j=1:CondNumb
    conf = [];
    plot(PSTHwindow(1)+binSize:binSize:PSTHwindow(2),mean(movNullVsPotDistRat(1,CondIndPlot(j,:),:),3),'k', 'LineWidth', 2)
    conf(1,:) = prctile(permute(movNullVsPotDistRat(1,CondIndPlot(j,:),:), [3 2 1]), 2.5);
    conf(2,:) = prctile(permute(movNullVsPotDistRat(1,CondIndPlot(j,:),:), [3 2 1]), 97.5); 
    ciplot(conf(1,:), conf(2,:), PSTHwindow(1)+binSize:binSize:PSTHwindow(2), 'k', 0.3)
end
plot([0 0], [-1 1], '--k')
plot([-2 2], [0 0], '--k')

axis([-2 1.5 -1 1])

ylabel({'Relative occupancy between movevement-null', 'and movement subpspaces'}, 'FontSize', 14)
xlabel('Time from Lick onset, s', 'FontSize', 14)
yticks(-1:0.5:1)

% Plot relative contribution of TF-responsive subpopulation to movement-null and movement subspaces
 
rNull = sum(nullProjTest./abs(nullProjTest).*nullProjTest.*nullProjTFRespTest,1)./(movNullEuqDist.^2);
rPot = sum(movPotProjTest./abs(movPotProjTest).*movPotProjTest.*movPotProjTFRespTest,1)./( movPotEuqDist.^2);
chanceRat = sum(TFRespNonRespUnits)/length(TFRespNonRespUnits);

pl = [];
subplot(PlotRowsNumb,5,5)
hold on

conf = [];
pl(2) = plot(PSTHwindow(1)+binSize:binSize:PSTHwindow(2), mean((rPot),3), 'color',  colors(2,:), 'LineWidth', 2);
conf(1,:) = prctile(permute(rPot, [3 2 1]), 2.5);
conf(2,:) = prctile(permute(rPot, [3 2 1]), 97.5); 
ciplot(conf(1,:), conf(2,:), PSTHwindow(1)+binSize:binSize:PSTHwindow(2), colors(2,:), 0.3)

conf = [];
pl(1) = plot(PSTHwindow(1)+binSize:binSize:PSTHwindow(2), mean((rNull),3), 'color',  colors(1,:), 'LineWidth', 2);
conf(1,:) = prctile(permute(rNull, [3 2 1]), 2.5);
conf(2,:) = prctile(permute(rNull, [3 2 1]), 97.5); 
ciplot(conf(1,:), conf(2,:), PSTHwindow(1)+binSize:binSize:PSTHwindow(2), colors(1,:), 0.3)
yl = ylim;

plot([-2.5 1.5], [0 0], '--k')
plot([0 0], [-10 10], '--k')
xl = xlim;
plot(xl, [chanceRat chanceRat], '--', 'LineWidth', 1, 'color', [0.7 0.7 0.7])

legend(pl, {'Movement-null subspace', 'Movement subspace'},'autoupdate', 'off', 'Location', 'best', 'FontSize', 14)
legend box off
ylabel({'TF-subpopulation weight'}, 'FontSize', 14)
xlabel('Time from Lick onset, s', 'FontSize', 14)
sgtitle(brRegOfIntr, 'FontWeight', 'bold', 'FontSize', 14)
axis([-2 1.5 -1 1])

sgtitle(BrainRegNamesLegendFriendly(brRegOfIntr), 'FontWeight', 'bold', 'FontSize', 14)

%% projections of responses to TF pulses onto movement and movement-null dimensions 

colors = lines(10);
colors = [ colors([1, 3, 6],:) ; [0.6,0.6,0.2]];

figure('units','normalized','outerposition',[0.05 0.15 0.4 0.7]);
plots = [];
conf = [];
tickSpacing = 0.1;

% plot projections on mov-null subspace
plotCount = OutputdimToUse;
CondNumbTF = 4;
for i=1:2 % 2 first out-null dim
    subplot(2,2,i+plotCount)
    hold on
    set(gca,'LineWidth',2)
    pleg = [];
    for j=1:CondNumbTF

        pleg(j) = plot(PSTHwindowTF(1)+binSize:binSize:PSTHwindowTF(2), mean(nullProj_TFfr(i,CondIndTFPlot(j,:),:),3), 'color', colors(j,:), 'LineWidth', 2);
        conf(1,:) = prctile(permute((nullProj_TFfr(i,CondIndTFPlot(j,:),:)), [3 2 1]), 2.5);
        conf(2,:) = prctile(permute((nullProj_TFfr(i,CondIndTFPlot(j,:),:)), [3 2 1]), 97.5); 
        ciplot(conf(1,:), conf(2,:), PSTHwindowTF(1)+binSize:binSize:PSTHwindowTF(2), colors(j,:), 0.3)
    end
    if i==1
        yl1 = ylim;
        xl1 = xlim;
        legend(pleg, {'Fast pulse', 'Slow pulse', 'Two fast pulses', 'Two slow pulses'}, 'Autoupdate','off')
        legend box off
    end
    plot([0 0], [yl1(1) yl1(2)], '--k', 'LineWidth', 2)
    plot([xl1(1) xl1(2)], [0 0], '--k', 'LineWidth', 2)
    axis([PSTHwindowTF(1) PSTHwindowTF(2) yl1])

    xlabel('Time from pulse onset, s', 'FontSize', 18)
    ylabel(['Proj. on movement-null dim' num2str(i) ], 'FontSize', 18)
    yticks([-1:tickSpacing:1])
end

% plot projections on mov-pot subspace
for i=1:OutputdimToUse
    subplot(2,2,i)
    hold on
    set(gca,'LineWidth',2)
    pleg = [];
    for j=1:CondNumbTF
        pleg(j) = plot(PSTHwindowTF(1)+binSize:binSize:PSTHwindowTF(2), mean(movPotProj_TFfr(i,CondIndTFPlot(j,:),:),3), 'color', colors(j,:), 'LineWidth', 2);
        conf(1,:) = prctile(permute((movPotProj_TFfr(i,CondIndTFPlot(j,:),:)), [3 2 1]), 2.5);
        conf(2,:) = prctile(permute((movPotProj_TFfr(i,CondIndTFPlot(j,:),:)), [3 2 1]), 97.5); 
        ciplot(conf(1,:), conf(2,:), PSTHwindowTF(1)+binSize:binSize:PSTHwindowTF(2), colors(j,:), 0.3)
    end
     if i==1
        legend(pleg, {'Fast pulse', 'Slow pulse', 'Two fast pulses', 'Two slow pulses'}, 'Autoupdate','off')
        legend box off
     end
    
    yl = yl1;
    plot([0 0], [yl(1) yl(2)], '--k', 'LineWidth', 2)
    plot([xl1(1) xl1(2)], [0 0], '--k', 'LineWidth', 2)

    xlabel('Time from pulse onset, s', 'FontSize', 18)
    ylabel(['Proj. on movement dim' num2str(i)], 'FontSize', 18)
    axis([PSTHwindowTF(1) PSTHwindowTF(2) yl])
    yticks([-1:tickSpacing:1])
end

sgtitle(BrainRegNamesLegendFriendly(brRegOfIntr), 'FontWeight', 'bold', 'FontSize', 18)

%% the same for pulses in 2D state space
colors = lines(7);
colors = [ colors([1, 3, 6],:); [0.6,0.6,0.2]];
figure('units','normalized','outerposition',[0.15 0.25 0.3 0.4]);
hold on
tickSpacing = 0.15;
pulseStartInd = 41;
indPlotEnd = 101;

avgFastPulseMovPotProj = mean(movPotProj_TFfr(1,CondIndTFPlot(1, pulseStartInd:indPlotEnd),:),3);
avgSlowPulseMovPotProj = mean(movPotProj_TFfr(1,CondIndTFPlot(2, pulseStartInd:indPlotEnd),:),3);
avgFastPulseMovNullProj = mean(nullProj_TFfr(1,CondIndTFPlot(1, pulseStartInd:indPlotEnd),:),3);
avgSlowPulseMovNullProj = mean(nullProj_TFfr(1,CondIndTFPlot(2, pulseStartInd:indPlotEnd),:),3);

avg2FastPulseMovPotProj = mean(movPotProj_TFfr(1,CondIndTFPlot(3, pulseStartInd:indPlotEnd),:),3);
avg2FastPulseMovNullProj = mean(nullProj_TFfr(1,CondIndTFPlot(3, pulseStartInd:indPlotEnd),:),3);
avg2SlowPulseMovPotProj = mean(movPotProj_TFfr(1,CondIndTFPlot(4, pulseStartInd:indPlotEnd),:),3);
avg2SlowtPulseMovNullProj = mean(nullProj_TFfr(1,CondIndTFPlot(4, pulseStartInd:indPlotEnd),:),3);
pleg = [];
for i=1:CondNumbTF
    pleg(i) = plot(mean(movPotProj_TFfr(1,CondIndTFPlot(i, pulseStartInd:indPlotEnd),:),3), mean(nullProj_TFfr(1,CondIndTFPlot(i, pulseStartInd:indPlotEnd),:),3),'color', colors(i,:),'LineWidth', 2);
end

xl = xlim;
yl = ylim; 
xticks(-0.9:tickSpacing:2)
yticks(-0.9:tickSpacing:2)
axis([-0.15001 0.35 -0.15001 0.35])
axis square
xlabel(['Proj. on movement dim.' num2str(1)], 'FontSize', 18)
ylabel(['Proj. on movement-null dim.' num2str(1)], 'FontSize', 18)
set(gca,'LineWidth',2)
legend(pleg, {'Fast pulse', 'Slow pulse', 'Two fast pulses', 'Two slow pulses'}, 'Autoupdate','off')
legend box off

