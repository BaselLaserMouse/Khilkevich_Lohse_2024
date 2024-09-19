function unitPerBrainReg = GroupDataPerBrainRegionDimRedCrossVal(allUnitsSumm, brRegList, varargin)

%for hits lick during change
ChangeParams = allUnitsSumm.ChangeSpParams;
ChangeMagn = ChangeParams.ChangeMagn;

if isempty(varargin)
    brainRegions = {allUnitsSumm.Units.brainRegionCombFull};
else
    brainRegions = {allUnitsSumm.Units.brainRegionExtraLabel};
end

brRegInd = [];

for i=1:length(brRegList)
    brRegInd = [brRegInd find(strcmp(brainRegions, brRegList{i})==1) ];
end

avgFR = [allUnitsSumm.Units(brRegInd).avgFR];
brRegInd(avgFR<0.5) = [];

SpikesHitTrs = reshape([allUnitsSumm.ChangeSp(brRegInd).SpikesHitTrs], length(ChangeMagn), length(brRegInd)); % units activity on hit lick trials, aligned to lick onset
SpikesHitTrs = permute(SpikesHitTrs, [2 1]);
SpikesMissTrs = reshape([allUnitsSumm.ChangeSp(brRegInd).SpikesMissTrs], length(ChangeMagn), length(brRegInd));
SpikesMissTrs = permute(SpikesMissTrs, [2 1]);
    
SpikesELTrs = reshape({allUnitsSumm.EarlyLickSp(brRegInd).SpikesELTrs}, 1, length(brRegInd));
SpikesNoELTrs = reshape({allUnitsSumm.EarlyLickSp(brRegInd).SpikesNoELTrs}, 1, length(brRegInd));
SpikesAbortsTrs = reshape({allUnitsSumm.AbortsSp(brRegInd).SpikesAbortsTr}, 1, length(brRegInd));

TFSpParams = allUnitsSumm.TFSpParams;
SpikesTFBinTr = reshape([allUnitsSumm.TFSp(brRegInd).SpikesTFBinTr], size(TFSpParams.TFbins,1), length(brRegInd));
SpikesTFSeqSpeedUpsTr = reshape([allUnitsSumm.TFSp(brRegInd).SpikesTFSeqSpeedUpsTr], size(TFSpParams.TFSeqDelayBTWpulses,2), length(brRegInd));
SpikesTFSeqSlowDownsTr = reshape([allUnitsSumm.TFSp(brRegInd).SpikesTFSeqSlowDownsTr], size(TFSpParams.TFSeqDelayBTWpulses,2), length(brRegInd));
 
UseMisses = 1;
GrInd = 1:3;    % 1.25&1.3Hz, 1.5Hz, 2&4hz

TFpValues = [allUnitsSumm.TF(brRegInd).GLM_pResidPulseTF05];
GLM_rPulseTF05 = mean([allUnitsSumm.TF(brRegInd).GLM_rPulseTF05], 1);

avgFR = [allUnitsSumm.Units(brRegInd).avgFR];
TFRespHPeakW = [allUnitsSumm.TF(brRegInd).TFRespHPeakW];

unitPerBrainReg.TFpValues = TFpValues;
unitPerBrainReg.avgFR = avgFR;
unitPerBrainReg.GLM_rPulseTF05 = GLM_rPulseTF05;


for j=1:length(GrInd)
    unitPerBrainReg.SpikesHitTrs(j,:) = SpikesHitTrs(:,GrInd(j));
    if UseMisses==1
        unitPerBrainReg.SpikesMissTrs(j,:) = SpikesMissTrs(:,GrInd(j));
    end
end
   
unitPerBrainReg.TFRespHPeakW = TFRespHPeakW;
unitPerBrainReg.SpikesELTrs = SpikesELTrs;
unitPerBrainReg.SpikesNoELTrs = SpikesNoELTrs;
unitPerBrainReg.SpikesAbortsTrs = SpikesAbortsTrs;

unitPerBrainReg.SpikesTFBinTr = SpikesTFBinTr;
unitPerBrainReg.SpikesTFSeqSpeedUpsTr = SpikesTFSeqSpeedUpsTr;
unitPerBrainReg.SpikesTFSeqSlowDownsTr = SpikesTFSeqSlowDownsTr;

end






