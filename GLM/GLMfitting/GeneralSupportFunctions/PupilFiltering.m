function [PupilFiltered_smoothed]=PupilFiltering(RawPupilData)
% preprocess dlc pupil size ouput
PupilNoCrazyOutliers=RawPupilData;
PupilNoCrazyOutliers(PupilNoCrazyOutliers>20000)=NaN; % remove any outrages values from misestimation of DLC

SinglePointCeilOuliersId=(PupilNoCrazyOutliers(1:end-1)-PupilNoCrazyOutliers(2:end))>1000; % remove any outrages sudden bursts in single frames from misestimation of DLC
SinglePointFloorOuliersId=(PupilNoCrazyOutliers(1:end-1)-PupilNoCrazyOutliers(2:end))<-1000; % remove any outrages sudden bursts in single frames from misestimation of DLC

PupilNoCrazyOutliers(SinglePointCeilOuliersId)=NaN;
PupilNoCrazyOutliers(SinglePointFloorOuliersId)=NaN;

% close to minimum exclusion (this happens when eye is occluded)
DataFloor = prctile(PupilNoCrazyOutliers(1:90000),0.5); % find he 0.5% percentile of the first 30 minutes to find the floor of the data
PupilNoCrazyOutliers(PupilNoCrazyOutliers<DataFloor)=NaN;

meanPupil45minutes=nanmean(PupilNoCrazyOutliers(1:90000));
stdPupil45minutes=nanstd(PupilNoCrazyOutliers(1:90000));

normPupil=(PupilNoCrazyOutliers-meanPupil45minutes)./stdPupil45minutes;
 
% if too many nans in an epioch the signal is considered to unstable and the whole epch is set to zero
nansearch=isnan(normPupil); % find places with too unstable pupil measurments
InclEpochIdx=smooth(nansearch,15000)<0.1;% inclduded epochs % only include epochs where more tan 90% of frames are valid
normPupil(InclEpochIdx==0)=0; % set all ecxluded epochs to zero

normPupil(normPupil>5)=0; % remove outliers based on zsscored signal

% smoooth
PupilFiltered_smoothed=(smoothdata(normPupil,'movmedian',50));

% remove last outliers from zscored and filtered signal
PupilFiltered_smoothed(PupilFiltered_smoothed>5)=0;

% insert 0 into normPupil where no values exist
PupilFiltered_smoothed(isnan(PupilFiltered_smoothed))=0;
