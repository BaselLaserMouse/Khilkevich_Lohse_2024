function [LickTrigOut]=LickTrigAvg(EarlyLick,RT,St1TrialVector)

%% Input: 
% - EarlyLick is the indexes of all the early lick trials, 
% - RT, are the time of lick from stim start, 
% - St1Trialvector are the TF value of all frames (assuming 60Hz refresh rate) from baseline stim start

%% Output
% LickTrigOut.edges=edges;
% LickTrigOut.LickHistory=LickHistory; % history length
% LickTrigOut.LickIdx=LickIdx; % frame when the lick happened
% LickTrigOut.PreLickIdx=PreLickIdx; % frames idx preceding the when the lick happened
% LickTrigOut.PreLickStim=PreLickStim; % stimuli preceding each lick
% LickTrigOut.LTA=LTA; % lick trigered averegae
% LickTrigOut.LTA95CI=LTA95CI; % 95 % parametric onfidence intervasl

% Michael Lohse 2020

LickHistory=60; % 60 is is one second (16.66666 * 60)

EarlyLick_RT=RT(find(EarlyLick));

edges=0:0.016666666666:25; %16.66666 ms long frames (60Hz refresh rate)

%% Potentially take subset requiring a certain amount of time to have passed
% EarlyLick_RT=EarlyLick_RT(EarlyLick_RT>2);
% St1TrialVector=St1TrialVector(EarlyLick_RT>2,:);

%% Potentially convert to speed changes resolution
% edges=0:0.05:25;
% Temp=St1TrialVector;
% clear St1TrialVector
% St1TrialVector=Temp(:,1:3:end);

PreLickStim=nan(LickHistory,length(EarlyLick_RT));

for T=1:length(EarlyLick_RT)
    
    LickIdx(:,T)=histc(EarlyLick_RT(T),edges);
    
    PreLickIdx(:,T)=find(LickIdx(:,T))-(LickHistory-1):find(LickIdx(:,T));
    
    PreLickStim(find(PreLickIdx(:,T)>0),T)=St1TrialVector(T,PreLickIdx(PreLickIdx(:,T)>0,T));
end

LTA=nanmean((PreLickStim)');
LTA95CI=(nanstd(PreLickStim')./sqrt(length(PreLickStim))).*2;

LickTrigOut.edges=edges;
LickTrigOut.LickHistory=LickHistory;
LickTrigOut.LickIdx=LickIdx;
LickTrigOut.PreLickIdx=PreLickIdx;
LickTrigOut.PreLickStim=PreLickStim;
LickTrigOut.PreLickStim=PreLickStim;
LickTrigOut.LTA=LTA;
LickTrigOut.LTA95CI=LTA95CI;

figure(300001)
shadedErrorBar(([1:LickHistory]-LickHistory)*16.6666666,LTA,LTA95CI,'lineprops',{'b','linewidth',2});
xlabel('time from lick (ms)')
title('Lick-Triggered Average')


