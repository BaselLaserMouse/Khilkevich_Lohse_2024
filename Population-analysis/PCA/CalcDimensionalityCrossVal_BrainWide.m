
% do PCA of hit lick aligned activity for each brain region, show a fraction of cross-validated variance captured by each PC   

ChangeSpParams = allUnitsSumm.ChangeSpParams;
drawsNumb = 1000;
maxPCsToUse = 10;
TFpValThresh = 0.01;

[BrainRegGroups, BrainRegGroupNames] = defineBrainRegGroupsV2;
BrRegCount = 0;
BrainRegNames = [];
groupID = [];

for g=1:length(BrainRegGroups)
    brRegGroup = BrainRegGroups{g};
    
    tic
    for k=1:length(brRegGroup)
        BrRegCount = BrRegCount+1;
        
        brRegOfIntr = brRegGroup{k};
        BrainRegNames{BrRegCount} = BrainRegNamesLegendFriendly(brRegOfIntr);
        unitPerBrainReg = GroupDataPerBrainRegionDimRedCrossVal(allUnitsSumm, brRegOfIntr);
        frHitsWeakChangeBrRegTr = SpikesToFR(unitPerBrainReg.SpikesHitTrs(1,:), sigma, ChangeSpParams.binSize, ChangeSpParams.PSTHwindowExtra); % use activity on hit trials during change (aligned to lick onsets); 1.25 and 1.3 Hz
        [frMatrFit, frMatrTest, ~, ~] = constructFrMatrixCrossVal(unitPerBrainReg, frHitsWeakChangeBrRegTr, TFpValThresh, drawsNumb, 'minmaxV2');

        RsqTest = [];
        parfor d=1:drawsNumb
            frMatrFitCntr = centerFrMatr(frMatrFit(:,:,d));
            frMatrTestCntr = centerFrMatr(frMatrTest(:,:,d));
            [uFit, s, v] = svd(frMatrFitCntr);
            [uTest, ~, ~] = svd(frMatrTestCntr);
            predFrMatrTot = 0;
            for i=1:maxPCsToUse
                predFrMatrPCi = uFit(:,i)*s(i,i)*v(:,i)';   % try to predict test FR matrix from svd components of the fit FR matrix
                predFrMatrTot = predFrMatrTot+predFrMatrPCi;

                frMatrRes = predFrMatrTot - frMatrTestCntr;
                RsqTest(d,i) = 1 - sum(frMatrRes(:).^2)/sum(frMatrTestCntr(:).^2);
            end
        end
        RsqTestAllBrReg(:,:,BrRegCount) = RsqTest;
    end

    time = toc;
    disp([BrainRegGroupNames{g} ' took ' num2str(time/60,3) ' min'])
    groupID = [groupID repmat(g,1,length(BrainRegGroups{g}))];
end

clearvars -except allUnitsSumm BrainRegNames RsqTestAllBrReg groupID

%%
maxPCsToUse = size(RsqTestAllBrReg,2);

try
    load('C:\Users\Andrei\Documents\DMDM\Code\NPX-analysis\analysis\Brain_regions\colorblind_colormap.mat')
catch
    load('/home/andreik/Dropbox/Projects/DMDM_NPX/Code/Brain_regions/colorblind_colormap.mat')
end

colors = [];
for i=1:size(colorblind2,1)
    colors = [colors; repmat(colorblind2(i,:),sum(groupID==i),1)];
end

[~, ind] = sort(max(meanRsqTest'), 'descend'); % sort brain regions

figure('units','normalized','outerposition',[0.15 0.15 0.35 0.8]);
ax1 = subplot(1,2,1);
hold on
imagesc(1:size(meanRsqTest,2), 1:length(ind), meanRsqTest(ind,:))
a = customcolormap_preset('red-white-blue');
colormap(a(129:end,:));
c = colorbar;
c.Label.String = 'Cumulative cross-validated R^2';
set(gca, 'Ydir', 'reverse')
yticks(1:100)
yticks(1:100)
for i=1:length(BrainRegNames)
     ax1.YTickLabel{i} = sprintf('\\color[rgb]{%f,%f,%f}%s', ...
     colors(ind(i),:), BrainRegNames{ind(i)});
end
xticks(1:maxPCsToUse)
xlabel('PC number')
axis([0.5 6.5 0.5 length(ind)+0.5])
