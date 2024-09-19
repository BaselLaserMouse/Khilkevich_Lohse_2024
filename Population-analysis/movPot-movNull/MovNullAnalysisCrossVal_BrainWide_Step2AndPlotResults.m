
clearvars -except allUnitsSumm BrainRegNames frMatrFitAllBrReg frMatrTestAllBrReg TFRespNonRespAllBrReg eigVectFitAllBrReg eigVectTestAllBrReg groupID 

% For each brain region perform the rest of decomposition of activity onto movement and movement-null subspaces, project also responses to TF pulses on these dimensions

ChangeSpParams = allUnitsSumm.ChangeSpParams;
PSTHwindow = ChangeSpParams.PSTHwindow;
binSize = ChangeSpParams.binSize;
TFSpParams = allUnitsSumm.TFSpParams;

zeroInitCond = 1; % make projections on dimensions to start at zero 
OutputdimToUse = 2; % number of movement dimensions to use
PCAdimToUse = repmat(4,1,length(BrainRegNames));
findPrepDimInNullSpace = 1;  % do rotation in movement-null subspace to find dimension that maximizes var of preparatory population
drawsNumbRandTF = 20; % number of random combinations of units, the same sample size as the number of TF responsive ones
tRegStartBeforeLickOnset = 0.1; % specifies regression window before lick onset to find movement subspace
count = 0;

timeBinsNumbPerCondTF = round((TFSpParams.PSTHwindow(2)-TFSpParams.PSTHwindow(1))/TFSpParams.binSize);
CondIndTFPlot = [];
CondNumbTF = 4;
for j=1:CondNumbTF
    CondIndTFPlot(j,:) = 1+(j-1)*timeBinsNumbPerCondTF:j*timeBinsNumbPerCondTF;
end

OrofacialNuc = {'Orofacial Mot. Nuc.'};
indOut = find(strcmp(BrainRegNames, OrofacialNuc)==1);
frMatrFitOut = frMatrFitAllBrReg{indOut};
frMatrFitOutCntrAvg = centerFrMatr(mean(frMatrFitOut,3));
[uTemplOut, ~, ~] = svd(frMatrFitOutCntrAvg);

[frProjHitsOutFitAvg, ~, ~, ~] = calcLowDProj(mean(frMatrFitOut,3), uTemplOut(:,1:OutputdimToUse), [], drawsNumbRandTF);
if zeroInitCond==1
    TimeIndToZeroMean = 1:round(0.5/binSize);
    frProjHitsOutFitAvg = frProjHitsOutFitAvg - mean(frProjHitsOutFitAvg(:,TimeIndToZeroMean),2);  
end

TimeIndToMotionOnset = 1:round(-PSTHwindow(1)/binSize);
TimeIndToMotionOnsetExtra = 1:round((-PSTHwindow(1)+1)/binSize);
for dim = 1:size(frProjHitsOutFitAvg,1)             % make the projection values to be positive
    if mean(frProjHitsOutFitAvg(dim,TimeIndToMotionOnsetExtra))<0
        uTemplOut(:,dim) = -uTemplOut(:,dim);
        frProjHitsOutFitAvg(dim,:) = -frProjHitsOutFitAvg(dim,:);
    end
end

regrWind = [];
CondNumb = 1;
frVectLength = size(frMatrFitOut,2)/CondNumb;
for i=1:CondNumb
    regrWind = [regrWind frVectLength*(i-1)+(round((-PSTHwindow(1)-tRegStartBeforeLickOnset)/binSize):frVectLength)];
end
options = optimoptions('lsqnonlin', 'MaxFunEvals',30000,'MaxIter', 300, 'display','off');

for i=1:length(BrainRegNames)
    PCAdimToUseReg = PCAdimToUse(i);
    init = zeros(OutputdimToUse,PCAdimToUseReg);

    count = count +1;
    waitbar(count/length(BrainRegNames))
    frMatrTest = frMatrTestAllBrReg{i};
    frMatrFit = frMatrFitAllBrReg{i};
    TFRespNonRespUnits{count} = TFRespNonRespAllBrReg{i};
    frMatrFitCntrAvg = centerFrMatr(mean(frMatrFit, 3));
    [uTemplSel, ~, ~] = svd(frMatrFitCntrAvg);
    [frProjHitsFitAvg, frProjHitsTFRespFitAvg, ~, ~] = calcLowDProj(mean(frMatrFit, 3), uTemplSel(:,1:PCAdimToUse), TFRespNonRespUnits{count}, drawsNumbRandTF);  
    frMatrTFtest = frMatrTFtestAllBrReg{i};

    if zeroInitCond==1
        TimeIndToZeroMean = 1:round(0.5/binSize);
        frProjHitsFitAvg = frProjHitsFitAvg - mean(frProjHitsFitAvg(:,TimeIndToZeroMean),2);  
        frProjHitsTFRespFitAvg = frProjHitsTFRespFitAvg - mean(frProjHitsTFRespFitAvg(:,TimeIndToZeroMean),2);  
    end
    
    f=@(x) x*frProjHitsFitAvg(:,regrWind) - frProjHitsOutFitAvg(:,regrWind);
    w = lsqnonlin(f, init, [],[],options);  % find best mapping onto mov-potent subspace
    wNull = null(w);
    wNullOrig = wNull'; 

    if findPrepDimInNullSpace==1  % find a rotation in mov-null space that captures max of preparatory activity 
        % calc projections to mov-null subspace
        nullProjFullAvg = wNullOrig*frProjHitsFitAvg;   % maximize projection of preparatory activity of full population
        [uTemplNullrot, sNull, ~] = svd(nullProjFullAvg(:, TimeIndToMotionOnset));
        varExplNullRot = 100*diag(sNull).^2/sum(diag(sNull.^2));
        
        wNull = uTemplNullrot'*wNullOrig;
        nullProjTFRespAvg = wNull*frProjHitsTFRespFitAvg;  
        nullProjFullAvg = wNull*frProjHitsFitAvg;
            
        for dim = 1:size(nullProjTFRespAvg,1)                   % make the projection values to be positive
            if mean(nullProjTFRespAvg(dim,TimeIndToMotionOnset))<0
                uTemplNullrot(:,dim) = -uTemplNullrot(:,dim) ; 
            end
        end
        wNull = uTemplNullrot'*wNullOrig;
        wNullOrigTF = wNull*norm(w)/norm(wNull);
    end   

    uFit = alignEigenVect(eigVectFitAllBrReg{i}(:,1:PCAdimToUseReg,:), uTemplSel(:,1:PCAdimToUseReg));
    uTest = alignEigenVect(eigVectTestAllBrReg{i}(:,1:PCAdimToUseReg,:), uTemplSel(:,1:PCAdimToUseReg));
    indOut = find(strcmp(BrainRegNames, OrofacialNuc)==1);
    uOutFit = alignEigenVect(eigVectFitAllBrReg{indOut}(:,1:OutputdimToUse,:), uTemplOut(:,1:PCAdimToUseReg));
    uOutTest = alignEigenVect(eigVectTestAllBrReg{indOut}(:,1:OutputdimToUse,:), uTemplOut(:,1:PCAdimToUseReg));
    frMatrFitOut = frMatrFitAllBrReg{indOut};
    frMatrTestOut = frMatrTestAllBrReg{indOut};

    for d=1:size(uFit,3)
        [frProjHitsFit, frProjHitsTFRespFit, frProjHitsTFNonRespFit, frProjHitsRandSelFit] = calcLowDProj(frMatrFit(:,:,d), uFit(:,:,d), TFRespNonRespUnits{count}, drawsNumbRandTF);    
        [frProjHitsTest, frProjHitsTFRespTest, frProjHitsTFNonRespTest, frProjHitsRandSelTest] = calcLowDProj(frMatrTest(:,:,d), uTest(:,:,d), TFRespNonRespUnits{count}, drawsNumbRandTF);
        [frProjHitsOutFit, ~, ~, ~] = calcLowDProj(frMatrFitOut(:,:,d), uOutFit(:,:,d), [], drawsNumbRandTF);
        [frProjHitsOutTest, ~, ~, ~] = calcLowDProj(frMatrTestOut(:,:,d), uOutTest(:,:,d), [], drawsNumbRandTF);

        [frTFProj, frTFProjTFResp, frTFProjTFNonResp, frTFProjRandSel] = calcLowDProj(frMatrTFtest(:,:,d), uTest(:,:,d), TFRespNonRespUnits{count}, drawsNumbRandTF);    

        if zeroInitCond==1
            TimeIndToZeroMean = 1:round(0.5/binSize);
            frProjHitsFit = frProjHitsFit -  mean(frProjHitsFit(:,TimeIndToZeroMean),2);
            frProjHitsTFRespFit = frProjHitsTFRespFit - mean(frProjHitsTFRespFit(:,TimeIndToZeroMean),2);
            frProjHitsTFNonRespFit = frProjHitsTFNonRespFit - mean(frProjHitsTFNonRespFit(:,TimeIndToZeroMean),2);
            frProjHitsRandSelFit = frProjHitsRandSelFit - mean(frProjHitsRandSelFit(:,TimeIndToZeroMean),2);
            frProjHitsOutFit = frProjHitsOutFit - mean(frProjHitsOutFit(:,TimeIndToZeroMean),2);

            frProjHitsTest = frProjHitsTest - mean(frProjHitsTest(:,TimeIndToZeroMean),2);
            frProjHitsTFRespTest = frProjHitsTFRespTest - mean(frProjHitsTFRespTest(:,TimeIndToZeroMean),2);
            frProjHitsTFNonRespTest = frProjHitsTFNonRespTest - mean(frProjHitsTFNonRespTest(:,TimeIndToZeroMean),2);
            frProjHitsRandSelTest = frProjHitsRandSelTest - mean(frProjHitsRandSelTest(:,TimeIndToZeroMean),2);
            frProjHitsOutTest = frProjHitsOutTest - mean(frProjHitsOutTest(:,TimeIndToZeroMean),2);    

            for TFcond = 1:size(CondIndTFPlot,1)  % zero initial condition for TF pulses 
                TFbaseInd = CondIndTFPlot(TFcond,1:round(0.5/binSize));
                TFIndFull = CondIndTFPlot(TFcond,:);
                frTFProj(:,TFIndFull) = frTFProj(:,TFIndFull) - mean(frTFProj(:,TFbaseInd),2);
                frTFProjTFResp(:,TFIndFull) = frTFProjTFResp(:,TFIndFull) - mean(frTFProjTFResp(:,TFbaseInd),2);
                frTFProjTFNonResp(:,TFIndFull) = frTFProjTFNonResp(:,TFIndFull) - mean(frTFProjTFNonResp(:,TFbaseInd),2);
                frTFProjRandSel(:,TFIndFull) = frTFProjRandSel(:,TFIndFull) - mean(frTFProjRandSel(:,TFbaseInd),2);
            end
        end

        f=@(x) x*frProjHitsFit(:,regrWind) - frProjHitsOutFit(:,regrWind);
        w = lsqnonlin(f, init, [],[],options);
        % calc projections
        movPotProjTest{count}(:,:,d) = w*frProjHitsTest;
        movPotProjTFRespTest{count}(:,:,d) = w*frProjHitsTFRespTest;
        movPotProjTFNonRespTest{count}(:,:,d) = w*frProjHitsTFNonRespTest;
        movPotProjTRandSelTest{count}(:,:,d) = w*frProjHitsRandSelTest;

        % repeat for TF pulse(s) aligned activity
        movPotProjTFTest{count}(:,:,d) = w*frTFProj;   
        movPotProjTFTestTFResp{count}(:,:,d) = w*frTFProjTFResp;
        movPotProjTFTestTFNonResp{count}(:,:,d) = w*frTFProjTFNonResp;
        movPotProjTFTestRandSel{count}(:,:,d) = w*frTFProjRandSel;    

        wNull = null(w);
        wNull = wNull';
        wNull = alignEigenVect(wNull, wNullOrig);            
        
        if findPrepDimInNullSpace==1  % find a rotation in mov-null subspace that has a dimension that captures max prep activity
            rotNull = uTemplNullrot;
            wNull = rotNull'*wNull;
        end 
        % make both operators to have the same norm; should make the comparison of projections more fair
        wNull = wNull*norm(w)/norm(wNull);

        loadingsPrepDimMovNull{count}(:,d) = uTest(:,:,d)*wNull(1,:)';
   
        nullProjTFRespTest{count}(:,:,d) = wNull*frProjHitsTFRespTest;
        nullProjTest{count}(:,:,d) = wNull*frProjHitsTest;
        nullProjTFNonRespTest{count}(:,:,d) = wNull*frProjHitsTFNonRespTest;
        nullProjTRandSelTest{count}(:,:,d) = wNull*frProjHitsRandSelTest;
        
        nullProjTFTest{count}(:,:,d) = wNullOrigTF*frTFProj;   
        nullProjTFTestTFResp{count}(:,:,d) = wNullOrigTF*frTFProjTFResp;
        nullProjTFTestTFNonResp{count}(:,:,d) = wNullOrigTF*frTFProjTFNonResp;
        nullProjTFTestRandSel{count}(:,:,d) = wNullOrigTF*frTFProjRandSel;

        movPotProjTest1d = reshape(movPotProjTest{count}(:,:,d)',1,[]);
        frProjHitsOutTest1d = reshape(frProjHitsOutTest',1,[]);
        RSqTest(count,d) = 1 - sum((frProjHitsOutTest1d(:)-movPotProjTest1d(:)).^2)/sum((frProjHitsOutTest1d(:)-mean(frProjHitsOutTest1d(:))).^2);
        frProjHitsOutTestDraws(:,:,d) = frProjHitsOutTest;
    end
end

%% show how well is the mapping to the movement subspace for each brain region 

movPotEuqDist = [];
movNullEuqDist = [];
movNullVsPotDistRat = [];
movPotTFRespEuqDist = [];
movNullTFRespEuqDist = [];
movNullVsPotTFRespDistRat = [];
movPotTFNonRespEuqDist = [];
movNullTFNonRespEuqDist = [];
movNullVsPotTFNonRespDistRat = [];
lowerConfBoundmovNullVsPot = [];
upperConfBoundmovNullVsPot = [];
nullSpaceTakeoffTime = [];

meanRsqToMovPot = mean(RSqTest,2);
conf = [];
conf(:,1) = prctile(RSqTest', 2.5);
conf(:,2) = prctile(RSqTest', 97.5);

[~, ind] = sort(meanRsqToMovPot);
ind(end) = []; % don't plot orofacial nuclei

figure
hold on
plot(meanRsqToMovPot(ind),1:length(BrainRegNames)-1, 'k', 'LineWidth', 2)
plot(conf(ind,1),1:length(BrainRegNames)-1, 'k', 'LineWidth', 1)
plot(conf(ind,2),1:length(BrainRegNames)-1, 'k', 'LineWidth', 1)

yticks([1:length(BrainRegNames)-1])
yticklabels(BrainRegNames(ind))
xlim([0 1])
ylim([0.5 length(BrainRegNames)-0.5])

%%
minTFrespUnitsNumb = 0;    % for general subspace occupancy analysis
% minTFrespUnitsNumb = 10;    % for contribution of TF responsive units

brRegIndGoodFit = find(cellfun(@sum, TFRespNonRespUnits)'>=minTFrespUnitsNumb&meanRsqToMovPot>0.8&meanRsqToMovPot<1);
brRegIndBadFit = find(meanRsqToMovPot<0.8);
BrainRegNamesnotToShow = BrainRegNames(brRegIndBadFit);

BrainRegNamesPlot = BrainRegNames(brRegIndGoodFit);
groupIDPlot = groupID(brRegIndGoodFit);

for j=1:length(brRegIndGoodFit)
    i = brRegIndGoodFit(j);
    
    movPotEuqDist(j,:,:) = sqrt(sum((movPotProjTest{i}-mean(movPotProjTest{i}(:,1:50,:),2)).^2,1));   
    movNullEuqDist(j,:,:) = sqrt(sum((nullProjTest{i}-mean(nullProjTest{i}(:,1:50,:),2)).^2,1));

    movNullVsPotDistRat(j,:,:) = (movNullEuqDist(j,:,:)-movPotEuqDist(j,:,:))./(movNullEuqDist(j,:,:)+movPotEuqDist(j,:,:));
    lowerConfBoundmovNullVsPot(j,:) = prctile(permute((movNullVsPotDistRat(j,:,:)), [3 2 1]), 2.5);
    upperConfBoundmovNullVsPot(j,:) = prctile(permute((movNullVsPotDistRat(j,:,:)), [3 2 1]), 97.5);

    noSignValTimes = find(lowerConfBoundmovNullVsPot(j,:)<0&upperConfBoundmovNullVsPot(j,:)>0);
    movNullVsPotDistRat(j,noSignValTimes,:) = 0;  % threshold by sign
    ind = min([find(movmean(lowerConfBoundmovNullVsPot(j, :)>0, [0 10])>=1, 1, 'first') find(movmean(upperConfBoundmovNullVsPot(j, :)<0, [0 10])>=1, 1, 'first')]); % sort brain regions 

    if ~isempty(ind)
        nullSpaceTakeoffTime(j) = ind;
    else
        nullSpaceTakeoffTime(j) = NaN;
    end  
        
    upperConfBoundmovMovNullEuqDist = prctile(reshape(permute(movNullEuqDist(j,1:50,:), [3 2 1]),1,[]), 97.5);
    noSignValTimes = find(mean(movNullEuqDist(j,:,:),3)<=upperConfBoundmovMovNullEuqDist);
    movNullEuqDist(j,noSignValTimes,:) = 0;    % threshold by significance

    upperConfBoundmovMovPotEuqDist = prctile(reshape(permute(movPotEuqDist(j,1:50,:), [3 2 1]),1,[]), 97.5);
    noSignValTimes = find(mean(movPotEuqDist(j,:,:),3)<=upperConfBoundmovMovPotEuqDist);
    movPotEuqDist(j,noSignValTimes,:) = 0;   % threshold by significance
end

%% Difference across abs values of loadings of TF responsive and TF non-responsive untis on 1st mov-null dim, for each brain region 

pTFrespLoadings = [];
for j=1:length(brRegIndGoodFit)
    i = brRegIndGoodFit(j);
    [~, pTFrespLoadings(j)] = ttest2(abs(mean(loadingsPrepDimMovNull{i}(TFRespNonRespUnits{i}==1,:),2)), abs(mean(loadingsPrepDimMovNull{i}(TFRespNonRespUnits{i}==0,:),2)));
end

[~, ind] = sort(pTFrespLoadings);
figure
hold on
plot(-log10(pTFrespLoadings(ind)),1:length(BrainRegNamesPlot))
yticks([1:length(BrainRegNamesPlot)])
yticklabels(BrainRegNamesPlot(ind))
plot(-log10([0.05 0.05]), [0.5 length(BrainRegNamesPlot)+0.5], '--k')

axis([0 50 0.5 length(BrainRegNamesPlot)+0.5])
xlabel('-log10 of p value')

%% Occupancy within movement subspace, movement-null subspace and relative occupancy btw them 

ChangeSpParams = allUnitsSumm.ChangeSpParams;
PSTHwindow = ChangeSpParams.PSTHwindow;
binSize = ChangeSpParams.binSize;

try
    load('C:\Users\Andrei\Dropbox\Projects\DMDM_NPX\Code\Brain_regions\colorBlindFriendly.mat')
catch
    load('/home/andreik/Dropbox/Projects/DMDM_NPX/Code/Brain_regions/colorBlindFriendly.mat')
end

colors = [];
for i=1:size(colorblind2,1)
    colors = [colors; repmat(colorblind2(i,:),sum(groupIDPlot==i),1)];
end
[~, sortInd] = sort(nullSpaceTakeoffTime); 

figure('units','normalized','outerposition',[0.1 0.1 0.25 0.8]);
ax1 = gca;
hold on
imagesc(PSTHwindow(1)+binSize:binSize:PSTHwindow(2), 1:length(BrainRegNamesPlot), mean((movNullEuqDist(sortInd,:,:))./repmat(permute(max((permute(movNullEuqDist(sortInd,:,:), [2 1 3]))),[2 1 3]),1,size(movNullEuqDist,2),1),3) )
a = customcolormap_preset('red-white-blue');
colormap(a(129:end,:));
c = colorbar;
c.Label.String = 'Peak-normalized Euclidean dist.';
c.FontSize = 14;

set(gca, 'Ydir', 'reverse')
plot([0 0], [0 100], '--k')
yticks(1:100)
for i=1:length(BrainRegNamesPlot)
     ax1.YTickLabel{i} = sprintf('\\color[rgb]{%f,%f,%f}%s', ...
     colors(sortInd(i),:), BrainRegNamesPlot{sortInd(i)});
end
xticks(-3:0.5:2)
axis([-2 1.5 0.5 length(BrainRegNamesPlot)+0.5])
caxis([0 1])
title('Mov-Null subspace')
xlabel('Time from Lick onset, s', 'FontSize', 14)

figure('units','normalized','outerposition',[0.4 0.1 0.25 0.8]);
ax2 = gca;
hold on
imagesc(PSTHwindow(1)+binSize:binSize:PSTHwindow(2), 1:length(BrainRegNamesPlot), mean(movNullVsPotDistRat(sortInd,:,:),3))
colormap(a);

c = colorbar;
c.Label.String = 'Mov. Potent <-----> Mov. Null';
c.FontSize = 14;
set(gca, 'Ydir', 'reverse')
plot([0 0], [0 100], '--k')
yticks(1:100)
for i=1:length(BrainRegNamesPlot)
     ax2.YTickLabel{i} = sprintf('\\color[rgb]{%f,%f,%f}%s', ...
     colors(sortInd(i),:), BrainRegNamesPlot{sortInd(i)});
end
xticks(-3:0.5:2)
axis([-2 1.5 0.5 length(BrainRegNamesPlot)+0.5])
caxis([-1 1])
title({'Relative occupancy of', 'Mov.-Pot vs. Mov. Null subspaces'})
xlabel('Time from Lick onset, s', 'FontSize', 14)


figure('units','normalized','outerposition',[0.7 0.1 0.25 0.8]);
ax3 = gca;
hold on
imagesc(PSTHwindow(1)+binSize:binSize:PSTHwindow(2), 1:length(BrainRegNamesPlot), mean(movPotEuqDist(sortInd,:,:)./repmat(permute(max(permute(movPotEuqDist(sortInd,:,:), [2 1 3])),[2 1 3]),1,size(movPotEuqDist,2),1),3) )

colormap(a(128:-1:1,:));
c = colorbar;
c.Label.String = 'Peak-normalized Euclidean dist.';
c.FontSize = 14;

set(gca, 'Ydir', 'reverse')
plot([0 0], [0 100], '--k')
yticks(1:100)
for i=1:length(BrainRegNamesPlot)
     ax3.YTickLabel{i} = sprintf('\\color[rgb]{%f,%f,%f}%s', ...
     colors(sortInd(i),:), BrainRegNamesPlot{sortInd(i)});
end
xticks(-3:0.5:2)
axis([-2 1.5 0.5 length(BrainRegNamesPlot)+0.5])
caxis([0 1])
title('Movement-potent subspace')


%% peak time of occupancy within movement-null subspace 

fracOfPeakThresh = 0.75;
movNullEuqDistPeakTime = [];
movNullEuqDistPeakStart = [];
movNullEuqDistPeakEnd = [];

for j=1:length(BrainRegNamesPlot)
    i = brRegIndGoodFit(j);
    movNullEuqDist = sqrt(sum(nullProjTest{i}.^2,1));   % use both dim.

    for d=1:size(movNullEuqDist,3)
        movNullEuqDistPeakTime(j,d) = PSTHwindow(1) + binSize*find(movNullEuqDist(1,:,d) == max(movNullEuqDist(1,:,d)),1,'first');
        movNullEuqDistPeakStart(j,d) = PSTHwindow(1) + binSize*find(movNullEuqDist(1,:,d) > fracOfPeakThresh*max(movNullEuqDist(1,:,d)),1,'first');
        movNullEuqDistPeakEnd(j,d) = PSTHwindow(1) + binSize*find(movNullEuqDist(1,:,d) > fracOfPeakThresh*max(movNullEuqDist(1,:,d)),1,'last');
    end
end

confmovNullEuqDistPeakTime(1,:) = prctile(permute(movNullEuqDistPeakTime(ind,:), [2 1]), 2.5);
confmovNullEuqDistPeakTime(2,:) = prctile(permute(movNullEuqDistPeakTime(ind,:), [2 1]), 97.5);
confmovNullEuqDistPeakStart(1,:) = prctile(permute(movNullEuqDistPeakStart(ind,:), [2 1]), 2.5);
confmovNullEuqDistPeakStart(2,:) = prctile(permute(movNullEuqDistPeakStart(ind,:), [2 1]), 97.5);
confmovNullEuqDistPeakEnd(1,:) = prctile(permute(movNullEuqDistPeakEnd(ind,:), [2 1]), 2.5);
confmovNullEuqDistPeakEnd(2,:) = prctile(permute(movNullEuqDistPeakEnd(ind,:), [2 1]), 97.5);

figure('units','normalized','outerposition',[0.7 0.1 0.25 0.8]);
ax3 = gca;
hold on

plot(mean(movNullEuqDistPeakTime(ind,:),2),1:length(BrainRegNamesPlot),'r', 'LineWidth', 2)
plot(confmovNullEuqDistPeakTime(1,:),1:length(BrainRegNamesPlot),'r', 'LineWidth', 1)
plot(confmovNullEuqDistPeakTime(2,:),1:length(BrainRegNamesPlot),'r', 'LineWidth', 1)
    
set(gca, 'Ydir', 'reverse')
yticks(1:100)
for i=1:length(BrainRegNamesPlot)
     ax3.YTickLabel{i} = sprintf('\\color[rgb]{%f,%f,%f}%s', ...
     colors(ind(i),:), BrainRegNamesPlot{ind(i)});
end
xticks(-3:0.5:2)
plot([0 0], [0 100], '--k')
axis([-2 1.5 0.5 0.5+length(BrainRegNamesPlot)])
title('Movement-null subspace')

%% peak time of relative occupancy btw movement-null and movement subspaces 

earliestPeakTime = -1.5;
delta = earliestPeakTime - PSTHwindow(1);
deltaInd = round(delta/binSize);

movNullRelativeOccupancyPeakTime = [];
for j=1:length(BrainRegNamesPlot)
    movNullVsPotDistRatBrReg = movNullVsPotDistRat(j,:,:);
    
    if sum(mean(movNullVsPotDistRatBrReg,3)>0)>5
        for d=1:size(movNullVsPotDistRat,3)
            movNullRelativeOccupancyPeakTime(j,d) = PSTHwindow(1) + binSize*find(movNullVsPotDistRatBrReg(1,deltaInd+1:end,d) == max(movNullVsPotDistRatBrReg(1,deltaInd+1:end,d)),1,'first')+delta;
        end
    else
         movNullRelativeOccupancyPeakTime(j,:) = nan(1,size(movNullVsPotDistRat,3));
    end
end
confmovNullRelativeOccupancyPeakTime(1,:) = prctile(permute(movNullRelativeOccupancyPeakTime(ind,:), [2 1]), 2.5);
confmovNullRelativeOccupancyPeakTime(2,:) = prctile(permute(movNullRelativeOccupancyPeakTime(ind,:), [2 1]), 97.5);

figure('units','normalized','outerposition',[0.7 0.1 0.25 0.8]);
ax3 = gca;
hold on

plot(mean(movNullRelativeOccupancyPeakTime(ind,:),2),1:length(BrainRegNamesPlot),'r', 'LineWidth', 2)
plot(confmovNullRelativeOccupancyPeakTime(1,:),1:length(BrainRegNamesPlot),'r', 'LineWidth', 1)
plot(confmovNullRelativeOccupancyPeakTime(2,:),1:length(BrainRegNamesPlot),'r', 'LineWidth', 1)
    
set(gca, 'Ydir', 'reverse')
yticks(1:100)
for i=1:length(BrainRegNamesPlot)
     ax3.YTickLabel{i} = sprintf('\\color[rgb]{%f,%f,%f}%s', ...
     colors(ind(i),:), BrainRegNamesPlot{ind(i)});
end
xticks(-3:0.5:2)
plot([0 0], [0 100], '--k')
axis([-2 1.5 0.5 0.5+length(BrainRegNamesPlot)])
title('Relative occupancy')

%% contribution of TF-responsive subpopulation within movement and movement-null subspaces 

ChangeSpParams = allUnitsSumm.ChangeSpParams;
PSTHwindow = ChangeSpParams.PSTHwindow;
binSize = ChangeSpParams.binSize;

try
    load('C:\Users\Andrei\Dropbox\Projects\DMDM_NPX\Code\Brain_regions\colorBlindFriendly.mat')
catch
    load('/home/andreik/Dropbox/Projects/DMDM_NPX/Code/Brain_regions/colorBlindFriendly.mat')
end

colors = [];
for i=1:size(colorblind2,1)
    colors = [colors; repmat(colorblind2(i,:),sum(groupIDPlot==i),1)];
end

MOind = size(nullProjTest{1},2)-(PSTHwindow(2))/binSize;
rNull= [];
rPot = [];
confMNull = [];
confMPot = [];
chanceRatSave = [];

for j=1:length(BrainRegNamesPlot)
    i = brRegIndGoodFit(j);

    signAtMOinNull = nullProjTest{i}(:,MOind,:)./abs(nullProjTest{i}(:,MOind,:));
    isTotVectAlWithMOActNul = nullProjTest{i}.*signAtMOinNull./abs(nullProjTest{i});
    
    signAtMOinPot = movPotProjTest{i}(:,MOind,:)./abs(movPotProjTest{i}(:,MOind,:));
    isTotVectAlWithMOActPot = movPotProjTest{i}.*signAtMOinPot./abs(movPotProjTest{i});
    
    chanceRat = sum(TFRespNonRespUnits{i})/length(TFRespNonRespUnits{i});
    chanceRatSave(j) = chanceRat;
    movNullEuqDist = sqrt(sum(nullProjTest{i}.^2,1));

    rPot(j,:,:) = (sum(movPotProjTest{i}./abs(movPotProjTest{i}).*movPotProjTest{i}.*movPotProjTFRespTest{i},1)./(movPotEuqDist((j),:,:).^2));
    confMPot(1,:) = prctile(permute(rPot(j,:,:), [3 2 1]), 2.5);
    confMPot(2,:) = prctile(permute(rPot(j,:,:), [3 2 1]), 97.5);
    rMPotnoSingValTimes = find((confMPot(1,:)<=chanceRat&confMPot(2,:)>0)|(confMPot(1,:)>=-chanceRat&confMPot(2,:)<0));
    rPot(j,rMPotnoSingValTimes,:) = 0;
    
    rNull(j,:,:) = (sum(nullProjTest{i}./abs(nullProjTest{i}).*nullProjTest{i}.*nullProjTFRespTest{i},1)./(movNullEuqDist.^2));
    confMNull(j,1,:) = prctile(permute(rNull(j,:,:), [3 2 1]), 2.5);
    confMNull(j,2,:) = prctile(permute(rNull(j,:,:), [3 2 1]), 97.5);
    rNullnoSingValTimes = find((confMNull(j,1,:)<=chanceRat&confMNull(j,2,:)>0)|(confMNull(j,1,:)>=-chanceRat&confMNull(j,2,:)<0)); % used
    rNull(j,rNullnoSingValTimes,:) = 0; 
end

% rPlot = rPot;
rPlot = rNull;

rNullThresh = 0;
lat = [];
minT = 1;
for i = 1:size(rPlot,1)
    dynTmp = abs(mean(rPlot(i,minT:end,:),3))>rNullThresh;
    latTmp = find(movmean(dynTmp,[0 25])>=0.8,1,'first');
    if ~isempty(latTmp)
        lat(i) = latTmp+minT;
    else
        lat(i) = 350;
    end
end
[~, plotInd] = sort(lat);

figure('units','normalized','outerposition',[0.5 0.1 0.25 0.8]);
hold on
ax1= gca;
imagesc(PSTHwindow(1)+binSize:binSize:PSTHwindow(2), 1:length(BrainRegNamesPlot), mean(rPlot(plotInd,:,:),3))
a = customcolormap_preset('red-white-blue');
colormap(a)
c = colorbar;
c.Label.String = 'TF-resp. subpopulation relative weight';
c.FontSize = 16;
set(gca, 'Ydir', 'reverse')
plot([0 0], [0 100], '--', 'color', [0.7 0.7 0.7], 'LineWidth', 2)
yticks(1:100)

for i=1:length(BrainRegNamesPlot)
     ax1.YTickLabel{i} = sprintf('\\color[rgb]{%f,%f,%f}%s', ...
     colors(plotInd(i),:), BrainRegNamesPlot{plotInd(i)});
end
xticks(-3:0.5:2)
xlabel('Time from Lick onset, s', 'FontSize', 14)
axis([-2 1.5 0.5 length(BrainRegNamesPlot)+0.5])
caxis([-1 1])

title(['Mov-Null space, aligment with act. ' num2str(tAlignBeforeMO) 'ms before lick onset'])
% title(['Mov-Pot space, aligment with act. ' num2str(tAlignBeforeMO) 'ms before lick onset'])

%% bar plot of HPW of TF pulse response for regions with TF-resp units active before or after the lick onset

load('/home/andreik/Dropbox/Projects/DMDM_NPX/Figures/Fig3/Integr/dataTFrespWidth.mat')

TFrespContribLat  =  round(PSTHwindow(1)/binSize)+lat;
RegionsIndActBeforeLick = find(TFrespContribLat<0);
RegionsIndActAfterLick = find(TFrespContribLat>0&TFrespContribLat<=150);

indTFactBeforeLick = [];
for i = 1:length(RegionsIndActBeforeLick)
    indTFactBeforeLick(i) = find(startsWith(TFresp.brNamesAll, BrainRegNamesPlot{RegionsIndActBeforeLick(i)})==1);
end
indTFactAfterLick = [];
for i = 1:length(RegionsIndActAfterLick)
    indTFactAfterLick(i) = find(startsWith(TFresp.brNamesAll, BrainRegNamesPlot{RegionsIndActAfterLick(i)})==1);
end

figure
hold on
bar(1, mean(TFresp.medianTFHPeakWAll(indTFactBeforeLick)), 0.5, 'FaceColor', 'white','EdgeColor','k', 'LineWidth', 1)
conf = bootci(2000, @mean, TFresp.medianTFHPeakWAll(indTFactBeforeLick));
errorbar(1, mean(TFresp.medianTFHPeakWAll(indTFactBeforeLick)), mean(TFresp.medianTFHPeakWAll(indTFactBeforeLick))-conf(1), conf(2)-mean(TFresp.medianTFHPeakWAll(indTFactBeforeLick)), 'Color', 'k', 'LineWidth', 2)

bar(2, mean(TFresp.medianTFHPeakWAll(indTFactAfterLick)), 0.5, 'FaceColor', 'white','EdgeColor','k', 'LineWidth', 1)
conf = bootci(2000, @mean, TFresp.medianTFHPeakWAll(indTFactAfterLick));
errorbar(2, mean(TFresp.medianTFHPeakWAll(indTFactAfterLick)), mean(TFresp.medianTFHPeakWAll(indTFactAfterLick))-conf(1), conf(2)-mean(TFresp.medianTFHPeakWAll(indTFactAfterLick)), 'Color', 'k', 'LineWidth', 2)

scatter(ones(1,length(indTFactBeforeLick))+0.1,  TFresp.medianTFHPeakWAll(indTFactBeforeLick), 100, colors(RegionsIndActBeforeLick,:), 'filled') 
scatter(2*ones(1,length(indTFactAfterLick))+0.1,  TFresp.medianTFHPeakWAll(indTFactAfterLick), 100, colors(RegionsIndActAfterLick,:), 'filled') 
xlim([0.5 2.5])
ylabel('Fast TF pulse response half-peak width (ms)')

pval = ranksum(TFresp.medianTFHPeakWAll(indTFactBeforeLick), TFresp.medianTFHPeakWAll(indTFactAfterLick));
title(['Wilcoxon p= ' num2str(pval,2)])

%% metrics of TF pulse response projections 

TFSpParams = allUnitsSumm.TFSpParams;
CondNumbTF = 4;
timeBinsNumbPerCondTF = round((TFSpParams.PSTHwindow(2)-TFSpParams.PSTHwindow(1))/TFSpParams.binSize);
CondIndTFPlot = [];
    
for j=1:CondNumbTF
    CondIndTFPlot(j,:) = 1+(j-1)*timeBinsNumbPerCondTF:j*timeBinsNumbPerCondTF;
end

pulseStartInd = 1;
onsetInd = 51;
indPlot1PulseEnd = 125;
indPlot2PulseEnd = 150;

deltaAroundPulse = 0.05/binSize;
deltaFromFirstPulse = 0.05/binSize;


TFProjCosAngle = [];   % first 2 dim mov-null, 2nd 2 - mov-pot
TFProjCosAngleConf = [];

max1FastPulseProj = [];
max2FastPulseProj = [];
max1SlowPulseProj = [];
max2SlowPulseProj = [];
 
pVal = [];
drawsNumb = size(movPotProjTest{1},3);
deltaP = 1/drawsNumb;

for j=1:length(BrainRegNamesPlot)
    i = brRegIndGoodFit(j);
    euclDist = permute(sqrt(sum(movPotProjTFTest{i}(:,CondIndTFPlot(1, pulseStartInd:indPlot1PulseEnd),:).^2,1) + sum(nullProjTFTest{i}(:,CondIndTFPlot(1, pulseStartInd:indPlot1PulseEnd),:).^2,1)), [2 3 1]); % for projection of responses to 1 fast TF pulse

    TFFastPulseMovPotProj = permute(movPotProjTFTest{i}(:,CondIndTFPlot(1, pulseStartInd:indPlot1PulseEnd),:), [2 3 1]);  % fast TF pulse response, full subspaces
    TFFastPulseMovNullProj = permute(nullProjTFTest{i}(:,CondIndTFPlot(1, pulseStartInd:indPlot1PulseEnd),:), [2 3 1]);
    
    TFFastPulseMovNull1DimProj = permute(nullProjTFTest{i}(1,CondIndTFPlot(1, pulseStartInd:indPlot1PulseEnd),:), [2 3 1]);   % only preparatory dimension in mov-null subspace 
    TFSlowPulseMovNull1DimProj = permute(nullProjTFTest{i}(1,CondIndTFPlot(2, pulseStartInd:indPlot1PulseEnd),:), [2 3 1]);   
    TF2FastPulseMovNullDimProj = permute(nullProjTFTest{i}(1,CondIndTFPlot(3, pulseStartInd:indPlot2PulseEnd),:), [2 3 1]);
    TF2SlowPulseMovNull1DimProj = permute(nullProjTFTest{i}(1,CondIndTFPlot(4, pulseStartInd:indPlot2PulseEnd),:), [2 3 1]);   
    
    TFFastPulseMovNull1DimProj = TFFastPulseMovNull1DimProj(onsetInd:end, :);
    TF2FastPulseMovNullDimProj = TF2FastPulseMovNullDimProj(onsetInd:end, :);
    TFSlowPulseMovNull1DimProj = TFSlowPulseMovNull1DimProj(onsetInd:end, :);
    TF2SlowPulseMovNull1DimProj = TF2SlowPulseMovNull1DimProj(onsetInd:end, :);
    
    max1FastvsSlowPulseProjTime = find(abs(mean(TFFastPulseMovNull1DimProj,2)-mean(TFSlowPulseMovNull1DimProj,2)) == max(abs(mean(TFFastPulseMovNull1DimProj,2)-mean(TFSlowPulseMovNull1DimProj,2))), 1, 'first');
    if max1FastvsSlowPulseProjTime>=(indPlot1PulseEnd-onsetInd-deltaAroundPulse)
        max1FastvsSlowPulseProjTime = (indPlot1PulseEnd-onsetInd-deltaAroundPulse);
    end
    max2FastvsSlowPulseProjTime = max1FastvsSlowPulseProjTime + deltaFromFirstPulse;

    for d=1:size(euclDist,2) % draws
        maxEuclDistTime = find(euclDist(:,d) == max(euclDist(:,d)), 1, 'first');

        for k=1:size(TFFastPulseMovNullProj,3) % looks at trajectory in full subspaces for the alignment analysis
            TFProjCosAngle(j,k,d) = (TFFastPulseMovNullProj(maxEuclDistTime,d,k)/euclDist(maxEuclDistTime,d));
        end
        for k=1:size(TFFastPulseMovPotProj,3)   
            TFProjCosAngle(j,2+k,d) = (TFFastPulseMovPotProj(maxEuclDistTime,d,k)/euclDist(maxEuclDistTime,d));
        end
        
        indTmp = find(abs(TFFastPulseMovNull1DimProj(max1FastvsSlowPulseProjTime-deltaAroundPulse:max1FastvsSlowPulseProjTime+deltaAroundPulse,d)) == max(abs(TFFastPulseMovNull1DimProj(max1FastvsSlowPulseProjTime-deltaAroundPulse:max1FastvsSlowPulseProjTime+deltaAroundPulse,d))));
        max1FastPulseProj(j,d) = (TFFastPulseMovNull1DimProj(max1FastvsSlowPulseProjTime-deltaAroundPulse+indTmp,d));
        
        indTmp = find(abs(TF2FastPulseMovNullDimProj(max2FastvsSlowPulseProjTime-deltaAroundPulse:max2FastvsSlowPulseProjTime+deltaAroundPulse,d)) == max(abs(TF2FastPulseMovNullDimProj(max2FastvsSlowPulseProjTime-deltaAroundPulse:max2FastvsSlowPulseProjTime+deltaAroundPulse,d))));
        max2FastPulseProj(j,d) = (TF2FastPulseMovNullDimProj(max2FastvsSlowPulseProjTime-deltaAroundPulse+indTmp,d));
        
        indTmp = find(abs(TFSlowPulseMovNull1DimProj(max1FastvsSlowPulseProjTime-deltaAroundPulse:max1FastvsSlowPulseProjTime+deltaAroundPulse,d)) == max(abs(TFSlowPulseMovNull1DimProj(max1FastvsSlowPulseProjTime-deltaAroundPulse:max1FastvsSlowPulseProjTime+deltaAroundPulse,d))));
        max1SlowPulseProj(j,d) = (TFSlowPulseMovNull1DimProj(max1FastvsSlowPulseProjTime-deltaAroundPulse+indTmp,d));

        indTmp = find(abs(TF2SlowPulseMovNull1DimProj(max2FastvsSlowPulseProjTime-deltaAroundPulse:max2FastvsSlowPulseProjTime+deltaAroundPulse,d)) == max(abs(TF2SlowPulseMovNull1DimProj(max2FastvsSlowPulseProjTime-deltaAroundPulse:max2FastvsSlowPulseProjTime+deltaAroundPulse,d))));
        max2SlowPulseProj(j,d) = (TF2SlowPulseMovNull1DimProj(max2FastvsSlowPulseProjTime-deltaAroundPulse+indTmp,d));
    end 
    
    for k=1:size(TFProjCosAngle,2)
        TFProjCosAngleConf(j,k,1) = prctile(TFProjCosAngle(j,k,:), 2.5);
        TFProjCosAngleConf(j,k,2) = prctile(TFProjCosAngle(j,k,:), 97.5);
    end
    
    for k=1:size(TFProjCosAngle,2)
        pValTemp = deltaP;
        found = 0;
        while pValTemp<=1&found==0
            if (prctile(TFProjCosAngle(j,k,:), 100*pValTemp/2)>0)||(prctile(TFProjCosAngle(j,k,:), 100-100*pValTemp/2)<0)
                found = 1;
            else
                pValTemp = pValTemp + deltaP;   %p-values of alignment of fast TF pulse with movement-potent and movement-null dimensions
            end
        end
        pVal(j,k) = pValTemp;
    end
end
%% alignment of fast TF pulse with mov-null and mov dimensions

plotInd = 1:length(BrainRegNamesPlot);
try
    load('/home/andreik/Dropbox/Projects/DMDM_NPX/Code/Brain_regions/colorBlindFriendly.mat')
catch
    load('C:/Users/Andrei/Dropbox/Projects/DMDM_NPX/Code/Brain_regions/colorBlindFriendly.mat')
end

colors = [];
for i=1:size(colorblind2,1)
    colors = [colors; repmat(colorblind2(i,:),sum(groupIDPlot==i),1)];
end

TFProjCosAnglePlot = mean(TFProjCosAngle,3);
indNotSign = TFProjCosAngleConf(:,:,1)<0&TFProjCosAngleConf(:,:,2)>0;
TFProjCosAngleThresh = TFProjCosAnglePlot;
TFProjCosAngleThresh(indNotSign) = 0;
TFProjCosAnglePlot = TFProjCosAngleThresh;

figure('units','normalized','outerposition',[0.1 0.1 0.13 0.8]);
hold on
ax1= gca;
a = customcolormap_preset('red-white-blue');
colormap(a);
c = colorbar;
c.Label.String = 'Cosine';
c.FontSize = 16;
set(gca, 'Ydir', 'reverse')
imagesc(1:4, 1:length(BrainRegNamesPlot), TFProjCosAnglePlot)

plot([0 0], [0 length(BrainRegNamesPlot)], '--', 'color', [0.7 0.7 0.7], 'LineWidth', 2)
yticks(1:length(BrainRegNamesPlot))
for i=1:length(BrainRegNamesPlot)
     ax1.YTickLabel{i} = sprintf('\\color[rgb]{%f,%f,%f}%s', ...
     colors(plotInd(i),:), BrainRegNamesPlot{plotInd(i)});
end

caxis([-1 1])
xticks(1:4)
xticklabels({'Movement-null dim. 1', 'Movement-null dim 2', 'Movement dim. 1', 'Movement dim. 2'})
xtickangle(45)
axis([0.5 4.5 0.5 length(BrainRegNamesPlot)+0.5])
%% plot for combined across brain region group analysis
BrainRegGroupNames = {'VisualAreasEarly', 'VisualAreasHigherOrder', 'Midbrain', 'Thalamus','FrontAndMotCortex', 'BasalGanglia', 'Cerebellum', 'Hippocampus'};

dimIndToPlot = 1;
figure
hold on
for i=1:length(BrainRegNamesPlot )
    scatter(i, TFProjCosAnglePlot(i,dimIndToPlot), 80,  colorblind2(i, :), 'filled')
    errorbar(i, TFProjCosAnglePlot(i,dimIndToPlot), TFProjCosAnglePlot(i,dimIndToPlot)-TFProjCosAngleConf(i,dimIndToPlot,1), TFProjCosAngleConf(i,dimIndToPlot,2)-TFProjCosAnglePlot(i,dimIndToPlot), 'color', colorblind2(i, :), 'LineWidth', 1)
end
plot([0.5 8.5], [0 0], '--k', 'LineWidth', 1)
xlim([0.5 8.5])
ylim([-0.6 1])
yticks([-1:0.5:1])
xticks([1:length(BrainRegGroupNames)])
xticklabels(BrainRegGroupNames)
xtickangle(45)

%% combined within brain region group

BrainRegGroupNames = {'VisualAreasEarly', 'VisualAreasHigherOrder', 'Midbrain', 'Thalamus','FrontAndMotCortex', 'BasalGanglia', 'Cerebellum', 'Hippocampus'};
TFProjCosAngleComb = [];
for i=1:length(BrainRegGroupNames)
   ind = find(groupIDPlot==i);
   TFProjCosAngleComb(i,:) = mean(TFProjCosAngle(ind,:,:),[3 1]);
   for j=1:size(TFProjCosAngleComb(i,:),2)
       TFProjCosAngleCombConf(i,j,1) = prctile(permute(mean(TFProjCosAngle(ind,j,:),1), [3 1 2]), 2.5);
       TFProjCosAngleCombConf(i,j,2) = prctile(permute(mean(TFProjCosAngle(ind,j,:),1), [3 1 2]), 97.5);
   end
end

dimIndToPlot = 3;
figure
hold on
for i=1:length(BrainRegGroupNames )
    scatter(i, TFProjCosAngleComb(i,dimIndToPlot), 80,  colorblind2(i, :), 'filled')
    errorbar(i, TFProjCosAngleComb(i,dimIndToPlot), TFProjCosAngleComb(i,dimIndToPlot)-TFProjCosAngleCombConf(i,dimIndToPlot,1), TFProjCosAngleCombConf(i,dimIndToPlot,2)-TFProjCosAngleComb(i,dimIndToPlot), 'color', colorblind2(i, :), 'LineWidth', 1)
end
plot([0 10], [0 0], '--k', 'LineWidth', 1)


xticks([1:length(BrainRegGroupNames)])
xticklabels(BrainRegGroupNames)
xtickangle(45)

%% plot scaling of pulse projection onto the movement-null dim. per brain regions group

conf1SlowtP = [prctile(max1SlowPulseProj', 2.5) ; prctile(max1SlowPulseProj', 97.5)];
conf2SlowtP = [prctile(max2SlowPulseProj', 2.5) ; prctile(max2SlowPulseProj', 97.5)];
conf1FastP = [prctile(max1FastPulseProj', 2.5) ; prctile(max1FastPulseProj', 97.5)];
conf2FastP = [prctile(max2FastPulseProj', 2.5) ; prctile(max2FastPulseProj', 97.5)];

pValTFRespScaling = [];

figure('units','normalized','outerposition',[0.1 0.1 0.5 0.8]);
for i = 1:size(max1FastPulseProj,1)
    subplot(7,4,i)
    hold on

    errorbar([-2 -1 1 2], [mean(max2SlowPulseProj(i,:),2) mean(max1SlowPulseProj(i,:),2) mean(max1FastPulseProj(i,:),2) mean(max2FastPulseProj(i,:),2)], [mean(max2SlowPulseProj(i,:),2)-conf2SlowtP(1,i)' mean(max1SlowPulseProj(i,:),2)-conf1SlowtP(1,i)' mean(max1FastPulseProj(i,:),2)-conf1FastP(1,i)' mean(max2FastPulseProj(i,:),2)-conf2FastP(1,i)'],...
    [conf2SlowtP(2,i)'-mean(max2SlowPulseProj(i,:),2) conf1SlowtP(2,i)'-mean(max1SlowPulseProj(i,:),2) conf1FastP(2,i)'-mean(max1FastPulseProj(i,:),2) conf2FastP(2,i)'-mean(max2FastPulseProj(i,:),2)],'color', colorblind2(groupIDPlot(i),:), 'LineWidth', 1)
    plot([-3 3], [0 0], '--k', 'LineWidth', 1)
    xlim([-2.1 2.1])
    title(BrainRegNamesPlot(i))
    yl = ylim;
    ylMax = ceil(10*(max(abs(yl))))/10;
    ylim([-ylMax ylMax])

    xticks([-2 -1 1 2])
    xticklabels([]);
    
    pValTFRespScaling(i).name = BrainRegNamesPlot(i);   % summary structure with p-values
    diffBtw2Vs1PulseProj = [];
    for d=1:100
        diffBtw2Vs1PulseProj = [diffBtw2Vs1PulseProj [max2SlowPulseProj(i,:) - max1SlowPulseProj(i,randperm(length(max1SlowPulseProj(i,:)),length(max1SlowPulseProj(i,:))))]];
    end
    pValTFRespScaling(i).p2vs1SlowTF = getPvalDiffFromZeroBootstr(diffBtw2Vs1PulseProj, deltaP);
    
    pValTFRespScaling(i).p1SlowTF = getPvalDiffFromZeroBootstr(max1SlowPulseProj(i,:), deltaP);
    pValTFRespScaling(i).p1FastTF = getPvalDiffFromZeroBootstr(max1FastPulseProj(i,:), deltaP);
    
    diffBtw2Vs1PulseProj = [];
    for d=1:100
        diffBtw2Vs1PulseProj = [diffBtw2Vs1PulseProj [max2FastPulseProj(i,:) - max1FastPulseProj(i,randperm(length(max1FastPulseProj(i,:)),length(max1FastPulseProj(i,:))))]];
    end
    pValTFRespScaling(i).p2vs1FastTF = getPvalDiffFromZeroBootstr(diffBtw2Vs1PulseProj, deltaP);
end

%% same but combined across regions within brain regions group
BrainRegGroupNames = {'VisualAreasEarly', 'VisualAreasHigherOrder', 'Midbrain', 'Thalamus','FrontAndMotCortex', 'BasalGanglia', 'Cerebellum', 'Hippocampus'};

figure('units','normalized','outerposition',[0.1 0.3 0.5 0.5])
meanSave = [];
confSave = [];

for i = 1:length(unique(groupIDPlot))
    subplot(2,4,i)
    hold on

    ind = find(groupIDPlot==i);
    max2SlowPulseProjComb = [];
    max1SlowPulseProjComb = [];
    max1FastPulseProjComb = [];
    max2FastPulseProjComb = [];

    for j=1:length(ind)
        max2SlowPulseProjComb = [max2SlowPulseProjComb max2SlowPulseProj(ind(j),:)/mean(max1FastPulseProj(ind(j),:),2)];    % normalized by fast TF pulse response projection
        max1SlowPulseProjComb = [max1SlowPulseProjComb max1SlowPulseProj(ind(j),:)/mean(max1FastPulseProj(ind(j),:),2)];    % normalized by fast TF pulse response projection
        max1FastPulseProjComb = [max1FastPulseProjComb max1FastPulseProj(ind(j),:)/mean(max1FastPulseProj(ind(j),:),2)];
        max2FastPulseProjComb = [max2FastPulseProjComb max2FastPulseProj(ind(j),:)/mean(max1FastPulseProj(ind(j),:),2)];
    end
    
    conf2SlowtPulseComb = [prctile(max2SlowPulseProjComb', 2.5) ; prctile(max2SlowPulseProjComb', 97.5)];
    conf1SlowtPulseComb = [prctile(max1SlowPulseProjComb', 2.5) ; prctile(max1SlowPulseProjComb', 97.5)];
    conf1FastPulseComb = [prctile(max1FastPulseProjComb', 2.5) ; prctile(max1FastPulseProjComb', 97.5)];
    conf2FastPulseComb = [prctile(max2FastPulseProjComb', 2.5) ; prctile(max2FastPulseProjComb', 97.5)];
    
    errorbar([-2 -1 1 2], [mean(max2SlowPulseProjComb,2) mean(max1SlowPulseProjComb,2) mean(max1FastPulseProjComb,2) mean(max2FastPulseProjComb,2)], [mean(max2SlowPulseProjComb,2)-conf2SlowtPulseComb(1,:)' mean(max1SlowPulseProjComb,2)-conf1SlowtPulseComb(1,:)' mean(max1FastPulseProjComb,2)-conf1FastPulseComb(1,:)' mean(max2FastPulseProjComb,2)-conf2FastPulseComb(1,:)'],...
    [conf2SlowtPulseComb(2,:)'-mean(max2SlowPulseProjComb,2) conf1SlowtPulseComb(2,:)'-mean(max1SlowPulseProjComb,2) conf1FastPulseComb(2,:)'-mean(max1FastPulseProjComb,2) conf2FastPulseComb(2,:)'-mean(max2FastPulseProjComb,2)], 'color', colorblind2(i,:), 'LineWidth', 2)
    xlim([-2.1 2.1])
    plot([-3 3], [0 0], '--k')
    yticks([-6:2:6])
    ylim([-4 4])
    
    diffBtw2Vs1FastPulseProj = [];
    for d=1:100
        diffBtw2Vs1FastPulseProj = [diffBtw2Vs1FastPulseProj [max2FastPulseProjComb - max1FastPulseProjComb(randperm(length(max1FastPulseProjComb),length(max1FastPulseProjComb)))]];
    end

    pVal = 0.004;
    found = 0;
    while pVal<=1&found==0
        if prctile(diffBtw2Vs1FastPulseProj, 100*pVal/2)>0
            found = 1;
        else
            pVal = pVal + 0.004;
        end
    end
    
    title([BrainRegGroupNames{i} ', p=' num2str(pVal,2)])   
    meanSave(i,1) = mean(max2FastPulseProjComb,2);
    confSave(i,:) = conf2FastPulseComb;
end



%% plot summary of response projections to TF pulses

TFPulseRespMovNullProj = [mean(max2SlowPulseProj,2) mean(max1SlowPulseProj,2) mean(max1FastPulseProj,2) mean(max2FastPulseProj,2)];
TFPulseRespMovNullProj = TFPulseRespMovNullProj./TFPulseRespMovNullProj(:,3);

conf2SlowtP = [prctile(max2SlowPulseProj', 2.5) ; prctile(max2SlowPulseProj', 97.5)];
conf1SlowtP = [prctile(max1SlowPulseProj', 2.5) ; prctile(max1SlowPulseProj', 97.5)];
conf1FastP = [prctile(max1FastPulseProj', 2.5) ; prctile(max1FastPulseProj', 97.5)];
conf2FastP = [prctile(max2FastPulseProj', 2.5) ; prctile(max2FastPulseProj', 97.5)];

TFPulseRespMovNullProj(conf2SlowtP(1,:)<0&conf2SlowtP(2,:)>0, 1) = 0; % don't plot nonsignificant responses
TFPulseRespMovNullProj(conf1SlowtP(1,:)<0&conf1SlowtP(2,:)>0, 2) = 0; % don't plot nonsignificant responses
TFPulseRespMovNullProj(conf1FastP(1,:)<0&conf1FastP(2,:)>0, 3) = 0; % don't plot nonsignificant responses
TFPulseRespMovNullProj(conf2FastP(1,:)<0&conf2FastP(2,:)>0, 4) = 0; % don't plot nonsignificant responses
    
figure('units','normalized','outerposition',[0.1 0.1 0.2 0.8]);
hold on
ax1= gca;
a = customcolormap_preset('red-white-blue');
colormap(a);
c = colorbar;
c.Label.String = 'Normalized TF pulse response projection onto movement-null dimension';
c.FontSize = 16;
set(gca, 'Ydir', 'reverse')
imagesc(1:4, 1:length(BrainRegNamesPlot), TFPulseRespMovNullProj)

plotInd = 1:length(BrainRegNamesPlot);
plot([0 0], [0 length(BrainRegNamesPlot)], '--', 'color', [0.7 0.7 0.7], 'LineWidth', 2)
yticks(1:length(BrainRegNamesPlot))
for i=1:length(BrainRegNamesPlot)
     ax1.YTickLabel{i} = sprintf('\\color[rgb]{%f,%f,%f}%s', ...
     colors(plotInd(i),:), BrainRegNamesPlot{plotInd(i)});
end

caxis([-3.2 3.2])
xticks(1:4)
xticklabels([])

axis([0.5 4.5 0.5 length(BrainRegNamesPlot)+0.5])

























