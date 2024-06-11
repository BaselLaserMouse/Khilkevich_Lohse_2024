function [EphysData,BehavData,VideoData,HitTrials,nTrialsHit,nTrials]=loadEventGLMDatav4Naive(Session,ProbeNo,GoodClustersToInclude)

% includes video extaction
% V3 For selection of subeset of neurons fr batch script


%% restructure motion onsetto match Trained data format
for T=1:length(Session.NI_events.Baseline_ON.rise_t)
    
    % find trial specific motion onset times
    clear LickTimeIdx
    LickTimeIdx=find(Session.NI_events.initLickTimes > Session.NI_events.Baseline_ON.rise_t(T) & Session.NI_events.initLickTimes < Session.NI_events.Change_ON.fall_t(T));
    
    if isempty(LickTimeIdx)
        Session.Video.MotionOnsetTimes(T,1:3)=NaN;
    elseif length(LickTimeIdx)==1
        Session.Video.MotionOnsetTimes(T,1:3)=[Session.NI_events.initLickTimes(LickTimeIdx),NaN,NaN]; % get piezo lick times
    elseif length(LickTimeIdx)==2
        Session.Video.MotionOnsetTimes(T,1:3)=[Session.NI_events.initLickTimes(LickTimeIdx)',NaN]; % get piezo lick times
    elseif length(LickTimeIdx)==3
        Session.Video.MotionOnsetTimes(T,1:3)=Session.NI_events.initLickTimes(LickTimeIdx)'; % get piezo lick times
    end
end

VideoData.MotionOnsetsAbsolute=Session.Video.MotionOnsetTimes;
VideoData.FaceEnergy=Session.Video.motionEnergy.face;
VideoData.FaceEnergyFiltered=smoothdata(Session.Video.motionEnergy.face,'movmedian',10);
try
    VideoData.FaceEnergyTimes=Session.NI_events.Front_cam.rise_t(1:length(VideoData.FaceEnergy));
catch
    VideoData.FaceEnergyTimes=Session.NI_events.Front_cam.rise_t;
    VideoData.FaceEnergy=Session.Video.motionEnergy.face(1:VideoData.FaceEnergyTimes);
end

VideoData.Pupil=Session.Video.pupilArea;
try
    VideoData.PupilTimes=Session.NI_events.Eye_cam.rise_t(1:length(VideoData.Pupil));
catch
    VideoData.PupilTimes=Session.NI_events.Eye_cam.rise_t;
    VideoData.Pupil=Session.Video.pupilArea(1:length(VideoData.PupilTimes));
end
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
EphysData=SpikeimportBasicv4Naive(Session,ProbeNo,[-1.5 4],0.001,1,GoodClustersToInclude);
VideoData.MotionOnsets=Session.Video.MotionOnsetTimes'-EphysData.AllEventTimes{2};

EphysData.RunningSpeedtimeAxis=Session.NI_events.RunningSpeed.timeAxis;
EphysData.RunningSpeed=Session.NI_events.RunningSpeed.Speed;

disp('extracting behaviour')
BehavData=QuickPerformanceGLM_v2Naive(Session.behav_data.trials_data_exp,VideoData.MotionOnsets,EphysData.AllEventTimes);

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

