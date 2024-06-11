%% Make tiled baseline
%% set baseline columns to zero outside baseline
startIdx = [1 (cumsum([dspec.covar(:).edim]) + 1)];
k_baseline = dm.dspec.idxmap.Baseline;
baseline_cols = startIdx(k_baseline) + (1:dspec.covar(k_baseline).edim) - 1;
for Tcount=1:nTrialsTrain
    T=trainId(Tcount);
    Temp{T}=[zeros(1,baseOnsetDur/(binSize)),ones(1,(rawData.param.baselineBins(T))-(baseOnsetDur/(binSize))-(200/binSize)), ... %% 200 because tile binning is 200 and can therefore lead to overlap with other predictors
        zeros(1,1000)]; % padding remainder of trial with zrs. CURRENTLY DISBLED: also not accounting for  the last 2.5 seconds of leadup upto change, as that is accoute for in antohr predictor
    Temp{T}(((rawData.trial(T).duration/(binSize))+1):end)=[] ; % cut of excesss zeros
end
baselineBinIdx=[Temp{:}];
dm.X(find(baselineBinIdx==0), baseline_cols) = 0;
