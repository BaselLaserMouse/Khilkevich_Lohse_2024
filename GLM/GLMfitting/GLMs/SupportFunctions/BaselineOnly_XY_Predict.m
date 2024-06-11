startIdx = [1 (cumsum([dspec.covar(:).edim]) + 1)];
k_baseline = dmTest.dspec.idxmap.Baseline;
baseline_cols = startIdx(k_baseline) + (1:dspec.covar(k_baseline).edim) - 1;
for Tcount=1:length(testTrialIndices)
    T=testTrialIndices(Tcount);
    Temp{T}=[zeros(1,baseOnsetDur/(binSize)),ones(1,(rawData.param.baselineBins(T))-(baseOnsetDur/(binSize))-(0/binSize)), ...
        zeros(1,1000)]; % padding remainder of trial with zrs. CURRENTLY DISBLED: also not accounting for  the last 2.5 seconds of leadup upto change, as that is accoute for in antohr predictor
    Temp{T}(((rawData.trial(T).duration/(binSize))+1):end)=[] ; % cut of excesss zeros
end
baselineBinIdx=[Temp{:}];
dmTest.X(find(baselineBinIdx==0), baseline_cols) = 0;

OrigSizeTest=size(dmTest.X);

%% remove all periods with contaminants of baseline activity
% first isolate baseline
dmTest.X(find(baselineBinIdx==0), :) = [];

% then remove additional contaminators
k_BaseON = dmTest.dspec.idxmap.baseON;
k_Abort = dmTest.dspec.idxmap.Abort;
k_EarlyLick = dmTest.dspec.idxmap.airpuff;
k_Lick = dmTest.dspec.idxmap.lick;
k_Rew = dmTest.dspec.idxmap.rew;

BaseON_cols = startIdx(k_BaseON) + (1:dspec.covar(k_BaseON).edim) - 1;
Abort_cols = startIdx(k_Abort) + (1:dspec.covar(k_Abort).edim) - 1;
EarlyLick_cols = startIdx(k_EarlyLick) + (1:dspec.covar(k_EarlyLick).edim) - 1;
Lick_cols = startIdx(k_Lick) + (1:dspec.covar(k_Lick).edim) - 1;
PostLick_cols = startIdx(k_PostLick) + (1:dspec.covar(k_PostLick).edim) - 1;
Rew_cols = startIdx(k_Rew) + (1:dspec.covar(k_Rew).edim) - 1;

Contamination_cols=[Abort_cols,EarlyLick_cols,Lick_cols,PostLick_cols,Rew_cols];

ContaminatedBaseline=sum(full(dmTest.X(:, Contamination_cols)),2)>0;

dmTest.X(find(ContaminatedBaseline), :) = [];

% dmTest.X(:,baseline_cols(end)+1:end)=[]; % remove columns related to contmainated columns, to make it all a bit cleaner
% dmTest.X(:,BaseON_cols)=[]; % remove columns related to BaseON

%% make a note of what clumns have been removed, for later reconstruction  (this uses the structure from removeConstantCols.m)
% Temp=zeros(1,OrigSize(2));
% Temp([BaseON_cols Contamination_cols])=1;
% dmTest.constCols = sparse(Temp); %
clear Temp

yTest(find(baselineBinIdx==0))=[];
yTest(find(ContaminatedBaseline))=[];
y_hat_pred(find(baselineBinIdx==0))=[];
y_hat_pred(find(ContaminatedBaseline))=[];
