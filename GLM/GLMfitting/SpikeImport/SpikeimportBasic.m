function [Expt]=SpikeImportBasic(Session,ProbeNo,Window,BinSize,Smoothing)

% Import data for structure for subsequent analysis. Starts by impoting for
% individual expeimetns and then ultimately will move on to allocate based on region
% recorded

%TO DO
%fix  spiketimes drifts, so that spikes are corrected according to external clock pulse

% ML 2020

%clear
%close all

%set(0,'DefaultFigureRenderer','painters') % set renderer.

DataFolders=Folders
%{'/mnt/data/mlohse/catgt_AK_1108135_S06_V1_g0/AK_1108135_S06_V1_g0_imec0'}; % experiment to include

Expt.Window=Window%[-1 3]; % Trial Expt(e).Window (spike times extracted around event)


Expt.BinSize=BinSize; Expt.edges=[Expt.Window(1):Expt.BinSize:Expt.Window(2)]; % 1 ms

PSTH_Smooth = Smoothing; % ms - gaussian full width

for e=1:length(DataFolders) % experiment (penetration/or simulanouspenetrations)
    clearvars -except e Expt DataFolders BinSize StimBinSize edgesStim PSTH_Smooth Smoothing
    
    folderSorted=DataFolders{e}; % folder with Kilosorted data
    cd([folderSorted '/Kilosort&Phy'])
    Temp=dir([folderSorted '/Kilosort&Phy'])
    % imec 0
        ExpName=Temp(3).name

    % imec 1
   % ExpName=Temp(4).name
    clear Temp
    ephysDataFolder=ExpName;
    disp(sprintf('Processing data from folder: %s', folderSorted))
    sp = loadKSdir(ephysDataFolder);
    
    %% Construct event-aligned PSTHs
    
    % find event times
    disp('Finding eventTimes')
    %Expt(e).AllEventTimes=FindEventsfromNPX(NidaqFolder);
    Expt(e).AllEventTimes=FindEventsfromNPXv2(folderSorted);
    Expt.nTrials=length(Expt(e).AllEventTimes{2})
    
        % Find Session and Trial Data
    disp('Finding session and trial data')
    BehavFolder=[folderSorted '/Session']
    cd(BehavFolder)
    [Expt(e).HitTrials, Expt(e).RT,Expt(e).BaseTFvals,Expt(e).BaseOri,Expt(e).BaseTime,Expt(e).FastPulseTimes,Expt(e).SlowPulseTimes, Expt(e).TrialData,Expt(e).SessionSettings,Expt(e).ComputerSettings]=FindSessionDatav2(BehavFolder,1); % fodler with ephys data and amount of runs (usually only one, but in case there was a restart this can be changed) for this session
    
    NumClu=length(unique(sp.clu)); % number of cluster in current penetration
    % Currently based on KS allocation: Add on phy clusters
    disp([num2str(NumClu) ' Clusters in current penetration'])
    
    for curClu=[570 635]1:101%NumClu % loop though all clusters
        disp(['Processing Cluster ' num2str(curClu) ' - ExptId: ' ExpName ])
        
        ST=sp.st(find(sp.clu==curClu));  %extract cluster specific spike trains
        
        % align spikes to important events and create trial structure
        
        [~,Expt(e).Clu(curClu).eventGLMtrialST]=alignedPSTH(ST,Expt(e).AllEventTimes{2},[0 30],Expt.BinSize, Expt.nTrials,Smoothing,'gaussian'); % Spiketimes aligned to 1 second prior to stim onset for event GLM
        
        [Expt(e).Clu(curClu).StimONAligned.meanPSTH,Expt(e).Clu(curClu).StimONAligned.TrialST,Expt(e).Clu(curClu).StimONAligned.TrialPSTH]=alignedPSTH(ST,Expt(e).AllEventTimes{2},Expt.Window,Expt.BinSize, Expt.nTrials,Smoothing,'gaussian');
        
        [Expt(e).Clu(curClu).ChangeONAligned.meanPSTH,Expt(e).Clu(curClu).ChangeONAligned.TrialST,Expt(e).Clu(curClu).ChangeONAligned.TrialPSTH]=alignedPSTH(ST,Expt(e).AllEventTimes{3},Expt.Window,Expt.BinSize, Expt.nTrials,Smoothing,'gaussian');
         
        [Expt(e).Clu(curClu).LickAligned.meanPSTH,Expt(e).Clu(curClu).LickAligned.TrialST,Expt(e).Clu(curClu).LickAligned.TrialPSTH]=alignedPSTH(ST,Expt(e).AllEventTimes{1},Expt.Window,Expt.BinSize, Expt.nTrials,Smoothing,'gaussian');

        
        clear ST
         
         
    end
end
