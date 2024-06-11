function [Beh]=QuickPerformancev2(MouseFolder,FullFolder,RunLogisModel)
%% v2 uses glmnet and implements the regression with lasso, ridge or elnet

%% Run session analyses
cd(MouseFolder)

if FullFolder ==1
    fname=dir('*trials.json');
    for A=1:length(fname)
        AllTrialData{A} = jsondecode(fileread(fname(A).name)); % loads in part 1, if here are w parts, that needs to be accounted for.
        SessionLenRaw(A)=length(AllTrialData{A});
        Temp=AllTrialData{A};
        Temp2=[Temp{:}];
        
        for T=1:length(Temp2);
            Abort(T)=strcmp(Temp2(T).trialoutcome,'abort');
        end
        SessionLen(A)=length(find(Abort==0));
        clear Abort Temp Temp2
    end
    
    clear fname%
    TrialData=cat(1,AllTrialData{:});
    
else
    % Have user browse for a file, from a specified "starting folder."
    % For convenience in browsing, set a starting folder from which to browse.
    if ~exist(MouseFolder, 'dir')
        % If that folder doesn't exist, just start in the current folder.
        MouseFolder = pwd;
    end
    % Get the name of the file that the user wants to use.
    defaultFileName = fullfile(MouseFolder, '*.json');
    [baseFileName, folder] = uigetfile(defaultFileName, 'Select a file');
    if baseFileName == 0
        % User clicked the Cancel button.
        return;
    end
    fullFileName = fullfile(folder, baseFileName)
    TrialData=jsondecode(fileread(baseFileName))
    SessionLen(1)=length(TrialData)

end
fsm=[TrialData{:}] % if the json gives cells

clearvars -except fsm RunLogisModel FullFolder MouseFolder SessionLen

for T=1:length(fsm);
    Beh.Raw.Corr(T)=strcmp(fsm(T).trialoutcome,'Hit');
    Beh.Raw.EarlyLick(T)=strcmp(fsm(T).trialoutcome,'FA');
    Beh.Raw.Miss(T)=strcmp(fsm(T).trialoutcome,'Miss');
    Beh.Raw.Abort(T)=strcmp(fsm(T).trialoutcome,'abort');
    Beh.Raw.TempBlock(T)=strcmp(fsm(T).hazardblock,'late');

    if Beh.Raw.Corr(T)
        Beh.Raw.RT(T)=fsm(T).reactiontimes.RT
    elseif Beh.Raw.EarlyLick(T)
        Beh.Raw.RT(T)=fsm(T).reactiontimes.FA
    elseif Beh.Raw.Miss(T)
        Beh.Raw.RT(T)=fsm(T).reactiontimes.Miss
    elseif Beh.Raw.Abort(T)
        Beh.Raw.RT(T)=fsm(T).reactiontimes.abort
    end
    
    Beh.Raw.St1TrialVector(T,:)=fsm(T).St1TrialVector;
    Beh.Raw.BaseT(T)=fsm(T).stimT;

end

Beh.Total.Corr=Beh.Raw.Corr(Beh.Raw.Abort==0);
Beh.Total.EarlyLick=Beh.Raw.EarlyLick(Beh.Raw.Abort==0);
Beh.Total.Miss=Beh.Raw.Miss(Beh.Raw.Abort==0);
Beh.Total.TempBlock=Beh.Raw.TempBlock(Beh.Raw.Abort==0);
Beh.Total.RT=Beh.Raw.RT(Beh.Raw.Abort==0);
Beh.Total.BaseT=Beh.Raw.BaseT(Beh.Raw.Abort==0);
Beh.Total.St1TrialVector=Beh.Raw.St1TrialVector(Beh.Raw.Abort==0,:);


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

[LickTrigOut]=LickTrigAvg(Beh.Total.EarlyLick,Beh.Total.RT,Beh.Total.St1TrialVector)

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
    
    Beh.Late.CondRT95CI(c)= std(Beh.Late.CondCorr_RT{c})./sqrt(length(Beh.Late.CondCorr_RT{c}))*2

    Beh.Late.PerfNoEarly(c)=mean(Beh.Late.CondCorr{c}(Beh.Late.CondEL{c}==0)); % performs in all trials without early licks
    Beh.Late.PerfTotal(c)=mean(Beh.Late.CondCorr{c}); % performs in all trials without early licks
    
    Beh.Late.ELrate(c)=mean(Beh.Late.CondEL{c});
    Beh.Late.Missrate(c)=mean(Beh.Late.CondMiss{c});
    
    Beh.Late.CondRT(c)= mean(Beh.Late.CondCorr_RT{c})
end

PlotBasicBehaviour(Beh)


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
  X=[log(Stim2TF(1+History:end)'),TempExpect,curBaseT,RewHistory,EarlyLickHistory,ones(length(EarlyLickHistory),1)*-1]*-1;

else
X=[log(Stim2TF(1+History:end)'),TempExpect,curBaseT,RewHistory,EarlyLickHistory];
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

[CorrModelFitAccuracy,ELModelFitAccuracy,MissModelFitAccuracy,OverallModelFitAccuracy,CorrModelPredAccuracy,ELModelPredAccuracy,MissModelPredAccuracy,OverallModelPredAccuracy,B,DEV,STATS,pihat,dlow,dhi,pred,predlow,predhi,trainId,testId,CorrFit,ELFit,CorrPred,ELPred,c]=RunLogisBehModv2(X,Y,kfolds,reK);

%LL = STATS.beta - 1.96.*STATS.se;
%UL = STATS.beta + 1.96.*STATS.se;

figure
hold on
subplot(2,2,1)
plot(STATS.beta{1}(:,end),'linewidth',1.5)
hold on
plot(STATS.beta{2}(:,end),'linewidth',1.5)
plot(STATS.beta{3}(:,end),'linewidth',1.5)
%plot(B,'linewidth',2)
%line([1 length(B)],[0 0],'linestyle',':','linewidth',1.5,'color','r')
%ylabel('beta')
%hold on
%plot(1:length(LL),LL,'linestyle','--');hold on;plot(1:length(UL),UL,'linestyle','--')
%box off
%set(gca,'FontSize',11)
%set(gca,'xtick',1:6, 'xticklabel',{'Intercept','StimTF','Block','BaseT','RewHis','EL Hist'})
%pause(.25)
subplot(2,2,3)
%hold on
%plot(STATS.t,'linewidth',2)
%line([1 6],[1.96 1.96],'linestyle','--','linewidth',1)
%line([1 6],[-1.96 -1.96],'linestyle','--','linewidth',1)

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
