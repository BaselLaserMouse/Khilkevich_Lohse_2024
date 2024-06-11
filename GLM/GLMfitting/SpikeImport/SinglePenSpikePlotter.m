% Import data for looking at simple event-aligned PSTHs and rasters
%% ML 2020
clear
close all

set(0,'DefaultFigureRenderer','painters') % set renderer.

%% Find folder with AllenCCF dependecies

AllenCCFcodeFolder='/home/mlohse/tfcd_npx_basicanalysis/SpikeImport/allenCCF'
AllenCCFannotateFolder='/home/mlohse/Documents/AllenCCFdata'

%% Establish probe insertion parameters
ProbePos=[-3000,2000]; % relativ to bregma (Rostro-caudal,Medio-lateral)
Angles=[0;90]; %  rotation, angle from dorsal skull line

%% Is there more than one condition (i.e. do you need to plot curves?)
multicondition=0;
if multicondition==1 % if mutliple conditions,  specify which trials belong to what 
   SpecifiedConditions=[1,1,2,2,3,3,4,4]; % currently placeholder, specify what you need 
end

%% select what event type to align to: 
% 2. Baseline ON, 3. Change ON, , 5. Lick ON,
EventTypeSelect=2;

%for exp=1 % single probe

%% Select experiment to run
exp=1
DataFolders={
    '/mnt/mlohse/winstor/swc/mrsic_flogel/public/projects/MiLo_20201201_DMDM_Circuit/LGN_to_V1_AxonSilencingPilot/ML_1118169_optopilot1/Processed data/ML_1118169_optopilot1_S01_V1/Kilosort&Phy/ML_1118169_optopilot1_S01_V1_g0_imec0/' ...
    };

folderSorted=DataFolders{exp}; % folder with Kilosorted data
disp(sprintf('Processing data from folder: %s', folderSorted))
cd(folderSorted)

sp = loadKSdir(folderSorted);
%sp = loadKS_PhyCurated_dir(folderSorted);

%% Construct event-aligned PSTHs
AllEventTimes=FindEventsfromNPX(folderSorted); % 1. XXX 2. StimONm 3. ChangeON, 4. XXX, 5. Lick ON

%% Parameters of plotting
PSTHwindow = [-0.5 3]; % look at spike times from 0.3 sec before each event to 1 sec after
if multicondition==1
    trialGroups=SpecifiedConditions;
else
    trialGroups = ones(size(AllEventTimes{EventTypeSelect})); % conditions % curertnly onl one condition
end

% % Run AllenCCF to see where the neurons are
% cd(AllenCCFannotateFolder)
% tv = readNPY('template_volume_10um.npy'); % grey-scale "background signal intensity"
% av = readNPY('annotation_volume_10um_by_index.npy'); % the number at each pixel labels the area, see note below
% cd(AllenCCFcodeFolder)
% st = loadStructureTree('structure_tree_safe_2017.csv'); % a table of what all the labels mean
% 
% allen_ccf_npxForPSTHplots(tv,av,st,ProbePos,Angles);
% 
%% plot PSTHs for scroll through
psthViewer2(sp.st, sp.clu, AllEventTimes{EventTypeSelect}, PSTHwindow, trialGroups,sp.ycoords);
set(gcf, 'Position',[1 300 700 800])

% 
% % end



