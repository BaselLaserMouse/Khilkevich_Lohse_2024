% Import data for structure for baseline stimulus GLM analysis. Importsing for
% individual expeimetns. a cpling filters are only estimate within simulatnously recorded units 

%TO DO
%fix  spiketimes drifts, so that spikes are corrected according to external clock pulse

% ML 2020

set(0,'DefaultFigureRenderer','painters') % set renderer.

DataFolders={
    '/mnt/data/mlohse/catgt_AK_1108135_S06_V1_g0/AK_1108135_S06_V1_g0_imec0' ...
    }; % experiment to include

Expt.Window=[onsetTime 22];% For GLM start the window at 1 (to remove onset reponses) and let it last the duration of th longest baseline (22 seconds?)

Expt.BinSize=0.001; Expt.edges=[Expt.Window(1):Expt.BinSize:Expt.Window(2)]; % 1 ms
StimBinSize=0.05; edgesStim=[Expt.Window(1):StimBinSize:Expt.Window(2)]; % 1 ms

qual_thresh=3; % threshold for which units to include based on manual quality rating in phy (including the selected number)

for e=1:length(DataFolders) % experiment (penetration/or simulanouspenetrations)
    clearvars -except e Expt DataFolders BinSize StimBinSize edgesStim PSTH_Smooth onsetTime qual_thresh
    
    folderSorted=DataFolders{e}; % folder with Kilosorted data
    disp(sprintf('Processing data from folder: %s', folderSorted))
    cd(folderSorted)
    ExpName=extractAfter(folderSorted,'g0/');
    sp = loadKS_PhyCurated_dir(folderSorted,qual_thresh);
    Expt(e).qual_thresh=qual_thresh;
    
    %% Construct event-aligned PSTHs
    
    % find event times
    disp('Finding eventTimes')
    %  Expt(e).AllEventTimes=FindEventsfromNPX(folderSorted);
    %% temp event load
    cd('/mnt/mlohse/winstor/swc/mrsic_flogel/public/projects/AnKh_20200820_NPX_DMDM/Naive controls data/1108135/Processed data/AK_1108135_S06_V1/Nidaq/')
    load('NIdaq_events.mat')
    %Expt(e).AllEventTimes{2}=NIdaq_events.Baseline_ON.rise_t;
    for T=1:length(NIdaq_events.frame_times_tr.time)
        Expt(e).AllEventTimes{2}(T)=(NIdaq_events.frame_times_tr.time{T}(1)); % get timings from photodiode
    end
    
    % Find Session and Trial Data
    disp('Finding session and trial data')
    [Expt(e).HitTrials, Expt(e).RT,Expt(e).BaseTFvalsAll,Expt(e).BaseOri,Expt(e).BaseTime,Expt(e).FastPulseTimes,Expt(e).SlowPulseTimes, Expt(e).TrialData,Expt(e).SessionSettings,Expt(e).ComputerSettings]=FindSessionData(folderSorted,2); % Currenly set to two:  fodler with ephys data and amount of runs (usually only one, but in case there was a restart this can be changed) for this session
  
    NumClu=length(unique(sp.clu)); % number of cluster in current penetration
    GoodClus=unique(sp.clu); % clusters with quality rating 

    % Currently based on KS allocation: Add on phy clusters
    disp([num2str(NumClu) ' Good clusters in current penetration'])
    
    %% Find indexes of trials with different characteristics (correct, incorrect, change size etc, so i can crate indexes of trials for extating PSTHs)
    
    Expt(e).TrialsType=[]; % these will have numbers based on type
    
    % Allocate brain region a cluster belongs to
    Expt(e).CluRegion=[]; % we an either make a list of numbers corresonding to regions, or simply add allen region abbreviation
    
    for curClu=1:NumClu % loop though all clusters
        disp(['Processing Cluster ' num2str(curClu) ' - ExptId: ' ExpName ])
        
        ST=sp.st(find(sp.clu==GoodClus(curClu)));  %extract cluster specific spike trains % for memory efficiency this isnot stored in the import for GLM extration
        
        % align spikes to important events and create trial structure
        for T=1:length(Expt(e).AllEventTimes{2}) % number of trials   
            StimTemp=ST-Expt(e).AllEventTimes{2}(T);
            Expt(e).Clu(curClu).StimONAligned.TrialST{T}=StimTemp(find(StimTemp>Expt(e).Window(1) & StimTemp<Expt(e).Window(2))); % spike times aligned to trial event
            Expt(e).Clu(curClu).StimONAligned.TrialPSTH(T,:)=histc(Expt(e).Clu(curClu).StimONAligned.TrialST{T}, Expt.edges);%./Expt(e).BinSize;  % Single trial psths at 1 ms resolution - in sp/s
            Expt(e).Clu(curClu).StimONAligned.TrialPSTHStimEdge(T,:)=histc(Expt(e).Clu(curClu).StimONAligned.TrialST{T}, edgesStim);%./StimBinSize; % % Single trial psths with bins being the size of individual stim pulses in sp/s
            clear StimTemp
        end
        clear ST
    end 
end
