function [Expt]=SpikeImportBasic(Session,ProbeNo,Window,BinSize,Smoothing)

% v2 import all good clusters
% Import data for structure for subsequent analysis. Starts by impoting for
% individual expeimetns and then ultimately will move on to allocate based on region
% recorded

%TO DO
%fix  spiketimes drifts, so that spikes are corrected according to external clock pulse

% ML 2020

%clear
%close all

%set(0,'DefaultFigureRenderer','painters') % set renderer.

%{'/mnt/data/mlohse/catgt_AK_1108135_S06_V1_g0/AK_1108135_S06_V1_g0_imec0'}; % experiment to include

Expt.Window=Window;%[-1 3]; % Trial Expt(e).Window (spike times extracted around event)


Expt.BinSize=BinSize; Expt.edges=[Expt.Window(1):Expt.BinSize:Expt.Window(2)]; % 1 ms

PSTH_Smooth = Smoothing; % ms - gaussian full width

for e=1%:length(DataFolders) % experiment (penetration/or simulanouspenetrations)
    clearvars -except e Session ProbeNo Expt DataFolders BinSize StimBinSize edgesStim PSTH_Smooth Smoothing

    
    %% Construct event-aligned PSTHs
    ExpName=Session.behav_data.SessionSettings.token;
    % find event times
    disp('Finding eventTimes')
    
    Expt(e).AllEventTimes=FindEventsfromNPXv3(Session.NI_events);
    
    Expt.nTrials=length(Expt(e).AllEventTimes{2});
    
        % Find Session and Trial Data
    disp('Finding session and trial data')
   [Expt(e).HitTrials, Expt(e).RT,Expt(e).BaseTFvals,Expt(e).BaseOri,Expt(e).BaseTime,Expt(e).FastPulseTimes,Expt(e).SlowPulseTimes]=FindSessionDatav3(Session.behav_data); % fodler with ephys data and amount of runs (usually only one, but in case there was a restart this can be changed) for this session
    
    NumCluTotal=length(unique(Session.NPX_probes(ProbeNo).clu)); % number of cluster in current penetration
    NumClu=length(Session.NPX_probes(ProbeNo).cluster_id_KS_good); % number of cluster in current penetration

    % Currently based on KS allocation: Add on phy clusters
    disp([num2str(NumCluTotal) ' Total clusters in current penetration'])
    disp([num2str(NumClu) ' Good clusters in current penetration'])

    for CluCounter=1:NumClu%[4,5,6,7,8,9,10,11,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,51,52,53,59,201,202,212,215] % loop though all clusters

        curClu=Session.NPX_probes(ProbeNo).cluster_id_KS_good(CluCounter);
        disp(['Processing Cluster ' num2str(curClu) ' - ' num2str(CluCounter) '/' num2str(NumClu) ' Good Clusters' ' - ExptId: ' ExpName ])
        
        ST=Session.NPX_probes(ProbeNo).st(find(Session.NPX_probes(ProbeNo).clu==curClu));  %extract cluster specific spike trains
        
        % align spikes to important events and create trial structure
        
        [~,Expt(e).Clu(CluCounter).eventGLMtrialST]=alignedPSTH(ST,Expt(e).AllEventTimes{2},[0 30],Expt.BinSize, Expt.nTrials,Smoothing,'gaussian'); % Spiketimes aligned to 1 second prior to stim onset for event GLM
        
        [Expt(e).Clu(CluCounter).StimONAligned.meanPSTH,Expt(e).Clu(CluCounter).StimONAligned.TrialST,Expt(e).Clu(CluCounter).StimONAligned.TrialPSTH]=alignedPSTH(ST,Expt(e).AllEventTimes{2},Expt.Window,Expt.BinSize, Expt.nTrials,Smoothing,'gaussian');
        
        [Expt(e).Clu(CluCounter).ChangeONAligned.meanPSTH,Expt(e).Clu(CluCounter).ChangeONAligned.TrialST,Expt(e).Clu(CluCounter).ChangeONAligned.TrialPSTH]=alignedPSTH(ST,Expt(e).AllEventTimes{3},Expt.Window,Expt.BinSize, Expt.nTrials,Smoothing,'gaussian');
         
        [Expt(e).Clu(CluCounter).LickAligned.meanPSTH,Expt(e).Clu(CluCounter).LickAligned.TrialST,Expt(e).Clu(CluCounter).LickAligned.TrialPSTH]=alignedPSTH(ST,Expt(e).AllEventTimes{1},Expt.Window,Expt.BinSize, Expt.nTrials,Smoothing,'gaussian');

        
        clear ST
         
         
    end
end
