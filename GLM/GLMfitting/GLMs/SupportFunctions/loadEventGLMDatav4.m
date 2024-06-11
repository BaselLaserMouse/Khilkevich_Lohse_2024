function [EphysData,BehavData,VideoData,HitTrials,nTrialsHit,nTrials]=loadEventGLMDatav4(Session,ProbeNo,GoodClustersToInclude)

% includes video extaction
% V3 For selection of subeset of neurons fr batch script


disp('extracting video')

VideoData.MotionOnsetsAbsolute=Session.Video.MotionOnsetTimes;

try
    VideoData.FaceEnergy=Session.Video.motionEnergy.face;
    VideoData.FaceEnergyFiltered=smoothdata(Session.Video.motionEnergy.face,'movmedian',10);
    VideoData.FaceEnergyTimes=Session.NI_events.Front_cam.rise_t(1:length(VideoData.FaceEnergy));
catch %if front camera was corrupted use side camera
    VideoData.FaceEnergy=Session.Video.motionEnergy.mouth;
    VideoData.FaceEnergyFiltered=smoothdata(Session.Video.motionEnergy.mouth,'movmedian',5);
    VideoData.FaceEnergyTimes=Session.NI_events.Eye_cam.rise_t;
end
VideoData.Pupil=Session.Video.pupilArea;
VideoData.PupilTimes=Session.NI_events.Eye_cam.rise_t;

%lengthPupilData=length(VideoData.Pupil);

%[~,pupilSortIdx]=sort(VideoData.Pupil);
%FivePercIdx=round(length(pupilSortIdx)*0.05);
%NinetyFivePercIdx=round(length(pupilSortIdx)*0.95);
%VideoData.PupilFiltered=VideoData.Pupil;
%VideoData.PupilFiltered(pupilSortIdx([1:FivePercIdx NinetyFivePercIdx:end]))=[];

% preproces pupildata
VideoData.PupilFiltered_smoothed=PupilFiltering(VideoData.Pupil);
VideoData.PupilTimesFiltered=VideoData.PupilTimes;

%figure;plot(VideoData.PupilTimes./60,VideoData.PupilFiltered_smoothed)
  
disp('extracting ephys')
EphysData=SpikeimportBasicv4(Session,ProbeNo,[-1.5 4],0.001,1,GoodClustersToInclude);
VideoData.MotionOnsets=Session.Video.MotionOnsetTimes-EphysData.AllEventTimes{2};

EphysData.RunningSpeedtimeAxis=Session.NI_events.RunningSpeed.timeAxis;
EphysData.RunningSpeed=Session.NI_events.RunningSpeed.Speed;

disp('extracting behaviour')
BehavData=QuickPerformanceGLM_v2(Session.behav_data.trials_data_exp,VideoData.MotionOnsets,EphysData.AllEventTimes);

HitTrials=find(BehavData.Raw.Corr);
nTrialsHit=length(HitTrials);
nTrials=length(BehavData.Raw.Corr);


%% obolete code
%lengthPupilData=length(VideoData.Pupil);

%[~,pupilSortIdx]=sort(VideoData.Pupil);
%FivePercIdx=round(length(pupilSortIdx)*0.05);
%NinetyFivePercIdx=round(length(pupilSortIdx)*0.95);
%VideoData.PupilFiltered=VideoData.Pupil;
%VideoData.PupilFiltered(pupilSortIdx([1:FivePercIdx NinetyFivePercIdx:end]))=[];


%nanIdx=isnan(VideoData.PupilFiltered)
%VideoData.PupilFiltered(nanIdx)=[];

%VideoData.PupilTimesFiltered(pupilSortIdx([1:FivePercIdx NinetyFivePercIdx:end]))=[];

%nanIdx=isnan(VideoData.PupilFiltered)
%VideoData.PupilFiltered(nanIdx)=[];
%VideoData.PupilTimesFiltered(pupilSortIdx([1:FivePercIdx NinetyFivePercIdx:end]))=[];

