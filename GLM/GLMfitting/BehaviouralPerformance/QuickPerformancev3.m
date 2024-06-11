function [Beh]=QuickPerformanceGLM(fsm,RunLogisModel);

%% v1 uses mnrfit for fitting and prediciton

%% Run session analyses

clearvars -except fsm RunLogisModel FullFolder MouseFolder SessionLen

for T=1:length(fsm);
    Beh.Raw.Corr(T)=strcmp(fsm(T).trialoutcome,'Hit');
    Beh.Raw.EarlyLick(T)=strcmp(fsm(T).trialoutcome,'FA');
    Beh.Raw.Miss(T)=strcmp(fsm(T).trialoutcome,'Miss');
    Beh.Raw.Abort(T)=strcmp(fsm(T).trialoutcome,'abort');
    Beh.Raw.TempBlock(T)=strcmp(fsm(T).hazardblock,'late');

  
    if Beh.Raw.Corr(T)
        Beh.Raw.RT(T)=fsm(T).reactiontimes.RT;
    elseif Beh.Raw.EarlyLick(T)
        Beh.Raw.RT(T)=fsm(T).reactiontimes.FA;
    elseif Beh.Raw.Miss(T)
        Beh.Raw.RT(T)=fsm(T).reactiontimes.Miss;
    elseif Beh.Raw.Abort(T)
        Beh.Raw.RT(T)=fsm(T).reactiontimes.abort;
    end
    
    %Beh.Raw.St1TrialVector(T,:)=fsm(T).St1TrialVector;
    %Beh.Raw.St2TrialVector(T,:)=fsm(T).St2TrialVector;
    Beh.Raw.TF{T}=fsm(T).TF;
    Beh.Raw.changeTF{T}=fsm(T).Stim2TF;
    Beh.Raw.Ori{T}=fsm(T).Stim1Ori;
    Beh.Raw.phase{T}=fsm(T).phase;
    Beh.Raw.BaseT(T)=fsm(T).stimT;

end



Beh.Total.Corr=Beh.Raw.Corr(Beh.Raw.Abort==0);
Beh.Total.EarlyLick=Beh.Raw.EarlyLick(Beh.Raw.Abort==0);
Beh.Total.Miss=Beh.Raw.Miss(Beh.Raw.Abort==0);
Beh.Total.TempBlock=Beh.Raw.TempBlock(Beh.Raw.Abort==0);
Beh.Total.RT=Beh.Raw.RT(Beh.Raw.Abort==0);
Beh.Total.BaseT=Beh.Raw.BaseT(Beh.Raw.Abort==0);
%Beh.Total.St1TrialVector=Beh.Raw.St1TrialVector(Beh.Raw.Abort==0,:);
%Beh.Total.St2TrialVector=Beh.Raw.St2TrialVector(Beh.Raw.Abort==0,:);
Beh.Total.TF(T,:)=Beh.Raw.TF{Beh.Raw.Abort==0};


Beh.Early.Corr=Beh.Total.Corr(Beh.Total.TempBlock==0);
Beh.Early.EarlyLick=Beh.Total.EarlyLick(Beh.Total.TempBlock==0);
Beh.Early.Miss=Beh.Total.Miss(Beh.Total.TempBlock==0);
Beh.Early.RT=Beh.Total.RT(Beh.Total.TempBlock==0);
Beh.Early.EL_RT=Beh.Total.RT([Beh.Total.TempBlock==0 & Beh.Total.EarlyLick]);
Beh.Early.Corr_RT=Beh.Total.RT([Beh.Total.TempBlock==0 & Beh.Total.Corr]);

Beh.Late.Corr=Beh.Total.Corr(Beh.Total.TempBlock==1);
Beh.Late.EarlyLick=Beh.Total.EarlyLick(Beh.Total.TempBlock==1);
Beh.Late.Miss=Beh.Total.Miss(Beh.Total.TempBlock==1);
Beh.Late.RT=Beh.Total.RT(Beh.Total.TempBlock==1);
Beh.Late.EL_RT=Beh.Total.RT([Beh.Total.TempBlock==1 & Beh.Total.EarlyLick]);
Beh.Late.Corr_RT=Beh.Total.RT([Beh.Total.TempBlock==1 & Beh.Total.Corr]);

Beh.conds=unique([fsm.Stim2TF]);
Stim2TF_Raw=[fsm.Stim2TF];

Stim2TF=Stim2TF_Raw(Beh.Raw.Abort==0);

for c=1:length(Beh.conds)
    Beh.Total.condIdx{c}=find(Stim2TF(1:length(Beh.Total.Corr))==Beh.conds(c));
    Beh.Total.CondCorr{c}=Beh.Total.Corr(Beh.Total.condIdx{c});
    Beh.Total.CondEL{c}=Beh.Total.EarlyLick(Beh.Total.condIdx{c});
    Beh.Total.CondMiss{c}=Beh.Total.Miss(Beh.Total.condIdx{c});
    
    Beh.Total.PerfNoEarly(c)=mean(Beh.Total.CondCorr{c}(Beh.Total.CondEL{c}==0)); % performs in all trials without early licks
    Beh.Total.PerfTotal(c)=mean(Beh.Total.CondCorr{c}); % performs in all trials without early licks
    
    Beh.Total.ELrate(c)=mean(Beh.Total.CondEL{c});
    Beh.Total.Missrate(c)=mean(Beh.Total.CondMiss{c});
end

[LickTrigOut]=LickTrigAvg(Beh.Total.EarlyLick,Beh.Total.RT,Beh.Total.St1TrialVector);


% parse out early and late blocks
for c=1:length(Beh.conds)
    
    %early block
    Beh.Early.condIdx{c}=find(Stim2TF(Beh.Total.TempBlock==0)==Beh.conds(c));
    Beh.Early.CondCorr{c}=Beh.Early.Corr(Beh.Early.condIdx{c});
    Beh.Early.CondEL{c}=Beh.Early.EarlyLick(Beh.Early.condIdx{c});
    Beh.Early.CondMiss{c}=Beh.Early.Miss(Beh.Early.condIdx{c});
    Beh.Early.CondCorr_RT{c}=Beh.Early.RT([Stim2TF(Beh.Total.TempBlock==0)==Beh.conds(c) & Beh.Total.Corr(Beh.Total.TempBlock==0)]);

    Beh.Early.PerfNoEarly(c)=mean(Beh.Early.CondCorr{c}(Beh.Early.CondEL{c}==0)); % performs in all trials without early licks
    Beh.Early.PerfTotal(c)=mean(Beh.Early.CondCorr{c}); % performs in all trials without early licks
    
    Beh.Early.ELrate(c)=mean(Beh.Early.CondEL{c});
    Beh.Early.Missrate(c)=mean(Beh.Early.CondMiss{c});
    
    Beh.Early.CondRT(c)= mean(Beh.Early.CondCorr_RT{c})
    Beh.Early.CondRT95CI(c)= std(Beh.Early.CondCorr_RT{c})./sqrt(length(Beh.Early.CondCorr_RT{c}))*2

    
    % late block
    Beh.Late.condIdx{c}=find(Stim2TF(Beh.Total.TempBlock==1)==Beh.conds(c));
    Beh.Late.CondCorr{c}=Beh.Late.Corr(Beh.Late.condIdx{c});
    Beh.Late.CondEL{c}=Beh.Late.EarlyLick(Beh.Late.condIdx{c});
    Beh.Late.CondMiss{c}=Beh.Late.Miss(Beh.Late.condIdx{c});
    Beh.Late.CondCorr_RT{c}=Beh.Late.RT([Stim2TF(Beh.Total.TempBlock==1)==Beh.conds(c) & Beh.Total.Corr(Beh.Total.TempBlock==1)]);
    
    Beh.Late.CondRT95CI(c)= std(Beh.Late.CondCorr_RT{c})./sqrt(length(Beh.Late.CondCorr_RT{c}))*2;

    Beh.Late.PerfNoEarly(c)=mean(Beh.Late.CondCorr{c}(Beh.Late.CondEL{c}==0)); % performs in all trials without early licks
    Beh.Late.PerfTotal(c)=mean(Beh.Late.CondCorr{c}); % performs in all trials without early licks
    
    Beh.Late.ELrate(c)=mean(Beh.Late.CondEL{c});
    Beh.Late.Missrate(c)=mean(Beh.Late.CondMiss{c});
    
    Beh.Late.CondRT(c)= mean(Beh.Late.CondCorr_RT{c})
end

PlotBasicBehaviour(Beh);


%% logistic regrssion behaviour model (unde rdevelopment)
if RunLogisModel ==1

History=1

EarlyLickHistory=Beh.Total.EarlyLick(1:end-History)';

StimHistory=Stim2TF(1:end-History)';

RewHistory=Beh.Total.Corr(1:end-History)';

MissHistory=Beh.Total.Miss(1:end-History)';

TempExpect=((Beh.Total.TempBlock(1+History:end)')*2)-1 ;

curBaseT=Beh.Total.BaseT(1+History:end)';

%% make session vectors

for S=1:length(SessionLen)
SessionTemp{S}=zeros(SessionLen(S),1)+S;
end
SessionConcat=cat(1,SessionTemp{:});
for S=1:length(SessionLen)
Session{S}=SessionConcat==S;
end
Sessions=cat(2,Session{:});

%% create design matrix

if FullFolder==1
  %X=[log(Stim2TF(1+History:end)'),TempExpect,curBaseT,RewHistory,EarlyLickHistory,Sessions(1+History:end,:)]*-1;
  X=[log(Stim2TF(1+History:end)'),TempExpect,curBaseT,RewHistory,EarlyLickHistory]*-1;

else
X=[log(Stim2TF(1+History:end)'),TempExpect,curBaseT,RewHistory,EarlyLickHistory]*-1;
end
%X=[Stim2TF(1+History:end)',TempExpect,curBaseT]*-1%,MissHistory]
%X(find(Beh.Total.EarlyLick(1+History:end)),1)=1;

X=zscore(X);

X(find(Beh.Total.EarlyLick(1+History:end)),1)=0;

figure
imagesc(X)
title('Design matrix')
set(gca,'xtick',1:6, 'xticklabel',{'Intercept','StimTF','Block','BaseT','RewHis','EL Hist'})

Xlen=length(X);

Y1=Beh.Total.Corr(1+History:end)'.*1;
Y2=Beh.Total.EarlyLick(1+History:end)'.*2;
Y3=Beh.Total.Miss(1+History:end)'.*3;
%Y4=Beh.Total.Abort(1+History:end).*-2

Ydouble=[Y1+Y2];
checkY=[Y1+Y2+Y3];
Y=Ydouble;
kfolds=5;
reK=25;% number of times to repartion kfolds

[CorrModelFitAccuracy,ELModelFitAccuracy,MissModelFitAccuracy,OverallModelFitAccuracy,CorrModelPredAccuracy,ELModelPredAccuracy,MissModelPredAccuracy,OverallModelPredAccuracy,B,DEV,STATS,pihat,dlow,dhi,pred,predlow,predhi,trainId,testId,CorrFit,ELFit,CorrPred,ELPred,c]=RunLogisBehMod(X,Y,kfolds,reK);

LL = STATS.beta - 1.96.*STATS.se;
UL = STATS.beta + 1.96.*STATS.se;

figure
hold on
subplot(2,2,1)
plot(B,'linewidth',2)
line([1 length(B)],[0 0],'linestyle',':','linewidth',1.5,'color','r')
ylabel('beta')
hold on
plot(1:length(LL),LL,'linestyle','--');hold on;plot(1:length(UL),UL,'linestyle','--')
box off
set(gca,'FontSize',11)
set(gca,'xtick',1:6, 'xticklabel',{'Intercept','StimTF','Block','BaseT','RewHis','EL Hist'})
pause(.25)
subplot(2,2,3)
hold on
plot(STATS.t,'linewidth',2)
line([1 6],[1.96 1.96],'linestyle','--','linewidth',1)
line([1 6],[-1.96 -1.96],'linestyle','--','linewidth',1)

ylabel('t-stat')
box off
set(gca,'FontSize',11)
set(gca,'xtick',1:6, 'xticklabel',{'Intercept','StimTF','Block','BaseT','RewHis','EL Hist'})

subplot(2,2,2)
boxplot([CorrModelFitAccuracy,ELModelFitAccuracy,MissModelFitAccuracy,OverallModelFitAccuracy],[ones(1,kfolds*reK),ones(1,kfolds*reK)*2,ones(1,kfolds*reK)*3,ones(1,kfolds*reK)*4],'plotstyle','compact')
hold on
line([0 5],[.33 .33],'linestyle','--','linewidth',2)
set(gca,'FontSize',11)
title('CV: Fit')
ylim([0 1])
set(gca,'xtick',1:4, 'xticklabel',{'Corr','EL','Miss','Full'})
ylabel('Accuracy')
box off
pause(.25)

subplot(2,2,4)
boxplot([CorrModelPredAccuracy,ELModelPredAccuracy,MissModelPredAccuracy,OverallModelPredAccuracy],[ones(1,kfolds*reK),ones(1,kfolds*reK)*2,ones(1,kfolds*reK)*3,ones(1,kfolds*reK)*4],'plotstyle','compact')
line([0 5],[.33 .33],'linestyle','--','linewidth',2)
set(gca,'FontSize',11)
title('CV: Prediction')
ylabel('Accuracy')
box off
ylim([0 1])
set(gca,'xtick',1:4, 'xticklabel',{'Corr','EL','Miss','Full'})

end
