function [frMatrFit, frMatrTest, TFRespNonRespUnits, tooFewTr] = constructFrMatrixCrossValTF(unitPerBrainReg, frBrRegTr, TFpVaThresh, drawsNumb, varargin)

% if isempty(varargin)
%     skipUnitsInd = [];
% else
%     skipUnitsInd = varargin{1}; % optional argument is intended to skip selected units from usage in constructing the firing rate matrices 
% end

% frBrRegTr cell array, conditionsXUnits
avgFR = unitPerBrainReg.avgFR;
signUnitsInd = find(unitPerBrainReg.TFpValues<TFpVaThresh&unitPerBrainReg.GLM_rPulseTF05>0.2);
TFRespNonRespUnits = zeros(1, length(unitPerBrainReg.TFpValues));
TFRespNonRespUnits(signUnitsInd) = 1;

trFracForFit = 0;
minTrNumbPerGr = 10;
TrNumbPerCond = cellfun(@(x) size(x,1), frBrRegTr);
tooFewTr = find(sum(TrNumbPerCond<minTrNumbPerGr,1)>0|sum(cellfun(@(x) sum(isnan(x(:,1))), frBrRegTr),1)>0); % find units where number of trials is too low on any condition
frBrRegTr(:,tooFewTr) = [];
TFRespNonRespUnits(tooFewTr) = [];

TrNumbPerCond(:,tooFewTr) = [];
lowestTrNumbPerCond = min(TrNumbPerCond(:));

frAvgMatr = cell2mat(cellfun(@(x) mean(x,1), frBrRegTr, 'UniformOutput', false)');  % concatenated in time conditions, if any

if ~isempty(varargin)
    if length(varargin)<2
        frRange = (max(frAvgMatr,[],2)-min(frAvgMatr,[],2));
    elseif length(varargin)==2
        frRange = varargin{2};
        frRange(tooFewTr) = [];
    end
%     frRange(frRange==0) = 1;
    
    for i=1:size(frBrRegTr,2) %units
        for j=1:size(frBrRegTr,1) %conditions
           if strcmp(varargin{1}, 'min-max')==1
               frBrRegTr{j,i} = frBrRegTr{j,i}/sqrt(frRange(i));
           elseif strcmp(varargin{1}, 'minmaxV2')==1
               frBrRegTr{j,i} = frBrRegTr{j,i}/(7+frRange(i));   
           elseif strcmp(varargin{1}, 'soft-norm')==1
               frBrRegTr{j,i} = frBrRegTr{j,i}/(5+avgFR(i));  % soft-norm
           end
        end
    end
end

parfor d=1:drawsNumb
    frMatrDrawFit = [];
    frMatrDrawTest = [];
        
    for i=1:size(frBrRegTr,1)   % trials groups
        frMatrTrGrFit = [];
        frMatrTrGrTest = [];

        for j=1:size(frBrRegTr,2) % units
            frTrUnit = frBrRegTr{i,j};
            
                TrNumb = size(frTrUnit,1);
                FitTrNumb = round(trFracForFit*TrNumb);
                TrVect = 1:TrNumb;
                fitTrials = randperm(TrNumb, FitTrNumb);
                testTrials = TrVect(~ismember(TrVect, fitTrials));

%                 TrNumb = size(frTrUnit,1);
%                 FitTrNumb = min([floor(lowestTrNumbPerCond*trFracForFit) round(trFracForFit*TrNumb)]);
%                 TrVect = 1:TrNumb;
%                 fitTrials = randperm(TrNumb, FitTrNumb);
%                 testTrials = TrVect(~ismember(TrVect, fitTrials));
%                 testTrials = testTrials(randperm(length(testTrials), FitTrNumb));
                
            frMatrTrGrFit(j,:) = mean(frTrUnit(fitTrials,:),1);
            frMatrTrGrTest(j,:) = mean(frTrUnit(testTrials,:),1);
        end
        
        frMatrDrawFit = [frMatrDrawFit frMatrTrGrFit];
        frMatrDrawTest = [frMatrDrawTest  frMatrTrGrTest];
    end  
    
    frMatrFit(:,:,d) = frMatrDrawFit;
    frMatrTest(:,:,d) = frMatrDrawTest;
end
    

end

