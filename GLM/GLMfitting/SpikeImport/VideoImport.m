function [Video]=VideoImport(Session,Window,BinSize,Smoothing)

% v4 event times are from baseline onset

% v3 import seslected good clusters for more efficient batch script

% v2 import all good clusters
% Import data for structure for subsequent analysis. Starts by impoting for
% individual expeimetns and then ultimately will move on to allocate based on region
% recorded

% ML 2022

%clear
%close all

%set(0,'DefaultFigureRenderer','painters') % set renderer.

%{'/mnt/data/mlohse/catgt_AK_1108135_S06_V1_g0/AK_1108135_S06_V1_g0_imec0'}; % experiment to include

Expt.Window=Window;%[-1 3]; % Trial Expt(e).Window (spike times extracted around event)


Expt.BinSize=BinSize; Expt.edges=[Expt.Window(1):Expt.BinSize:Expt.Window(2)]; % 1 ms

PSTH_Smooth = Smoothing; % ms - gaussian full width

for e=1%:length(DataFolders) % experiment (penetration/or simulanouspenetrations)
    clearvars -except GoodClustersToInclude e Session ProbeNo Expt DataFolders BinSize StimBinSize edgesStim PSTH_Smooth Smoothing
    
    
    %% Construct event-aligned motion data
    ExpName=Session.behav_data.SessionSettings.token;
    % find event times
    disp('Finding eventTimes')
    
    Expt(e).AllEventTimes=FindEventsfromNPXv4(Session.NI_events);
    
    Expt.nTrials=length(Expt(e).AllEventTimes{2});
    



end
