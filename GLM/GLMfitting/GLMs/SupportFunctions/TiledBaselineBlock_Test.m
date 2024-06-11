%% Make baseline specific to blocks

%% set baseline columns to zero outside baseline - early block
startIdx = [1 (cumsum([dspec.covar(:).edim]) + 1)];
k_baseline = dmTest.dspec.idxmap.BaselineEarly;
baseline_cols = startIdx(k_baseline) + (1:dspec.covar(k_baseline).edim) - 1;
for Tcount=1:length(testTrialIndices)
    T=testTrialIndices(Tcount);
    Temp{T}=[zeros(1,baseOnsetDur/(binSize)),ones(1,(rawData.param.baselineBins(T))-(baseOnsetDur/(binSize))-(200/binSize)), ...
        zeros(1,1000)]; % padding remainder of trial with zrs. CURRENTLY DISBLED: also not accounting for  the last 2.5 seconds of leadup upto change, as that is accoute for in antohr predictor
    Temp{T}(((rawData.trial(T).duration/(binSize))+1):end)=[] ; % cut of excesss zeros
end
baselineBinIdx=[Temp{:}];
dmTest.X(find(baselineBinIdx==0), baseline_cols) = 0;
clear startIdx k_baseline baseline_cols baselineBinIdx Temp T Tcount

%% set baseline columns to zero outside baseline - late block
startIdx = [1 (cumsum([dspec.covar(:).edim]) + 1)];
k_baseline = dmTest.dspec.idxmap.BaselineLate;
baseline_cols = startIdx(k_baseline) + (1:dspec.covar(k_baseline).edim) - 1;
for Tcount=1:length(testTrialIndices)
    T=testTrialIndices(Tcount);
    Temp{T}=[zeros(1,baseOnsetDur/(binSize)),ones(1,(rawData.param.baselineBins(T))-(baseOnsetDur/(binSize))-(200/binSize)), ...
        zeros(1,1000)]; % padding remainder of trial with zrs. CURRENTLY DISBLED: also not accounting for  the last 2.5 seconds of leadup upto change, as that is accoute for in antohr predictor
    Temp{T}(((rawData.trial(T).duration/(binSize))+1):end)=[] ; % cut of excesss zeros
end
baselineBinIdx=[Temp{:}];
dmTest.X(find(baselineBinIdx==0), baseline_cols) = 0;
clear startIdx baselineBinIdx Temp T Tcount