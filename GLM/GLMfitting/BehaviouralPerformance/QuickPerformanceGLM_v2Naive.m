function [Beh]=QuickPerformanceGLM_v2Naive(fsm,MotionOnsets,AllEventTimes);
% v2 includes hidden early licks from aborts in its early lick

%% Run session analyses

for T=1:length(fsm);
    Beh.Raw.Corr(T)=strcmp(fsm(T).trialoutcome,'Hit');
    Beh.Raw.EarlyLick(T)=strcmp(fsm(T).trialoutcome,'FA');
    %Beh.Raw.HiddenEarlyLick(T)=fsm(T).IsAbortWithFA;
    Beh.Raw.Miss(T)=strcmp(fsm(T).trialoutcome,'Miss');
    Beh.Raw.Abort(T)=strcmp(fsm(T).trialoutcome,'abort');
    Beh.Raw.TempBlock(T)=strcmp(fsm(T).hazardblock,'late');
    
%     if fsm(T).IsAbortWithFA % if hidden early lick
%         Beh.Raw.Abort(T)=0;
%         Beh.Raw.EarlyLick(T)=1;
%     end
    %% All tis changs meaning in Naive runs, because all active interaction with the trial itself is disabled
%     if ~isnan(MotionOnsets(T))
        if Beh.Raw.Corr(T)
            Beh.Raw.RT(:,T)=MotionOnsets(:,T);
        elseif Beh.Raw.EarlyLick(T)
            Beh.Raw.RT(:,T)=MotionOnsets(:,T);
        %elseif Beh.Raw.HiddenEarlyLick(T)
        %    Beh.Raw.RT(T)=MotionOnsets(T);
        elseif Beh.Raw.Miss(T)
            Beh.Raw.RT(:,T)=MotionOnsets(:,T);%fsm(T).reactiontimes.Miss;
        elseif Beh.Raw.Abort(T)
            Beh.Raw.RT(:,T)=MotionOnsets(:,T);
        end
        %     else % when motion onset is unabae to be estimated from video
        %         if Beh.Raw.Corr(T)
        %             Beh.Raw.RT(T)=fsm(T).reactiontimes.RT;
        %         elseif Beh.Raw.EarlyLick(T)
        %             Beh.Raw.RT(T)=fsm(T).reactiontimes.FA;
        %             if isnan(Beh.Raw.RT(T)) % if it is a hidden early lick
        %                 Beh.Raw.RT(T)=fsm(T).reactiontimes.abort;
        %             end
        %         elseif Beh.Raw.Miss(T)
        %             Beh.Raw.RT(T)=fsm(T).reactiontimes.Miss;
        %         elseif Beh.Raw.Abort(T)
        %             Beh.Raw.RT(T)=fsm(T).reactiontimes.abort;
        %         end
%     else % when motion onset is unabae to be estimated from video
%         Beh.Raw.RT(T)=NaN;
%     end
    
    %Beh.Raw.St1TrialVector(T,:)=fsm(T).St1TrialVector;
    %Beh.Raw.St2TrialVector(T,:)=fsm(T).St2TrialVector;
    Beh.Raw.TF{T}=nan(1500,1);
    Beh.Raw.TF{T}(1:length(fsm(T).TF(fsm(T).TF>0)))=fsm(T).TF(fsm(T).TF>0);
    Beh.Raw.changeTF{T}=fsm(T).Stim2TF;
    Beh.Raw.Ori{T}=fsm(T).Stim1Ori;
    Beh.Raw.phase{T}=fsm(T).phase;
    
    if Beh.Raw.Corr(T)
        Beh.Raw.BaseT(T)=AllEventTimes{3}(T)-AllEventTimes{2}(T);
    elseif Beh.Raw.Miss(T)
        Beh.Raw.BaseT(T)=AllEventTimes{3}(T)-AllEventTimes{2}(T);
    else
        Beh.Raw.BaseT(T)=fsm(T).stimT; % if no change happened (Early lick, or abort), insert when it was supposed to happen
    end

end



Beh.Total.Corr=Beh.Raw.Corr(Beh.Raw.Abort==0);
Beh.Total.EarlyLick=Beh.Raw.EarlyLick(Beh.Raw.Abort==0);
%Beh.Total.HiddenEarlyLick=Beh.Raw.HiddenEarlyLick(Beh.Raw.Abort==0);
Beh.Total.Miss=Beh.Raw.Miss(Beh.Raw.Abort==0);
Beh.Total.TempBlock=Beh.Raw.TempBlock(Beh.Raw.Abort==0);
Beh.Total.RT=Beh.Raw.RT(Beh.Raw.Abort==0);
Beh.Total.BaseT=Beh.Raw.BaseT(Beh.Raw.Abort==0);
%Beh.Total.St1TrialVector=Beh.Raw.St1TrialVector(Beh.Raw.Abort==0,:);
%Beh.Total.St2TrialVector=Beh.Raw.St2TrialVector(Beh.Raw.Abort==0,:);
Beh.Total.TF=cat(2,Beh.Raw.TF{Beh.Raw.Abort==0});


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

%[LickTrigOut]=LickTrigAvg(Beh.Total.EarlyLick,Beh.Total.RT,Beh.Total.TF');


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
    
    Beh.Early.CondRT(c)= mean(Beh.Early.CondCorr_RT{c});
    Beh.Early.CondRT95CI(c)= std(Beh.Early.CondCorr_RT{c})./sqrt(length(Beh.Early.CondCorr_RT{c}))*1.96;

    
    % late block
    Beh.Late.condIdx{c}=find(Stim2TF(Beh.Total.TempBlock==1)==Beh.conds(c));
    Beh.Late.CondCorr{c}=Beh.Late.Corr(Beh.Late.condIdx{c});
    Beh.Late.CondEL{c}=Beh.Late.EarlyLick(Beh.Late.condIdx{c});
    Beh.Late.CondMiss{c}=Beh.Late.Miss(Beh.Late.condIdx{c});
    Beh.Late.CondCorr_RT{c}=Beh.Late.RT([Stim2TF(Beh.Total.TempBlock==1)==Beh.conds(c) & Beh.Total.Corr(Beh.Total.TempBlock==1)]);
    
    Beh.Late.CondRT95CI(c)= std(Beh.Late.CondCorr_RT{c})./sqrt(length(Beh.Late.CondCorr_RT{c}))*1.96;

    Beh.Late.PerfNoEarly(c)=mean(Beh.Late.CondCorr{c}(Beh.Late.CondEL{c}==0)); % performs in all trials without early licks
    Beh.Late.PerfTotal(c)=mean(Beh.Late.CondCorr{c}); % performs in all trials without early licks
    
    Beh.Late.ELrate(c)=mean(Beh.Late.CondEL{c});
    Beh.Late.Missrate(c)=mean(Beh.Late.CondMiss{c});
    
    Beh.Late.CondRT(c)= mean(Beh.Late.CondCorr_RT{c});
end

%PlotBasicBehaviour(Beh);
