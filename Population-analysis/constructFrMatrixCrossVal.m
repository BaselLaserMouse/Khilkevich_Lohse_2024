function [frMatrFit, frMatrTest, TFRespNonRespUnits, tooFewTr] = constructFrMatrixCrossVal(unitPerBrainReg, frBrRegTr, TFpVaThresh, drawsNumb, varargin)

% frBrRegTr cell array, conditionsXUnits
%varargin{1} - normalization type
%varargin{2} - supply firing rate range (if projecting onto dimentions
%defined by a different firing rate matrix from which the firing rate range should be)

avgFR = unitPerBrainReg.avgFR;
signUnitsInd = find(unitPerBrainReg.TFpValues<TFpVaThresh&unitPerBrainReg.GLM_rPulseTF05>0.2);
TFRespNonRespUnits = zeros(1, length(unitPerBrainReg.TFpValues));
TFRespNonRespUnits(signUnitsInd) = 1;

minTrNumbPerGr = 10;
TrNumbPerCond = cellfun(@(x) size(x,1), frBrRegTr);
tooFewTr = find(sum(TrNumbPerCond<minTrNumbPerGr,1)>0|sum(cellfun(@(x) sum(isnan(x(:,1))), frBrRegTr),1)>0); % find units where number of trials is too low on any condition
frBrRegTr(:,tooFewTr) = [];
TFRespNonRespUnits(tooFewTr) = [];
TrNumbPerCond(:,tooFewTr) = [];

frAvgMatr = cell2mat(cellfun(@(x) mean(x,1), frBrRegTr, 'UniformOutput', false)');  % concatenated in time conditions, if any
trFracForFit = 0.5;

if ~isempty(varargin)
    
    if length(varargin)>=2
        if isempty(varargin{2})==1
            frRange = (max(frAvgMatr,[],2)-min(frAvgMatr,[],2));
        else
            frRange = varargin{2};
            frRange(tooFewTr) = [];
        end
    else
        frRange = (max(frAvgMatr,[],2)-min(frAvgMatr,[],2));
    end        
    
    if ~isempty(varargin{1})
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
    
    if length(varargin)==3
        if isempty(varargin{3})==0
            trFracForFit = varargin{3};
        end
    end
end

timeDimSize = 0;
for i=1:size(frBrRegTr,1) 
    timeDimSize = timeDimSize + size(frBrRegTr{i,1},2);
end

frMatrFit = zeros(size(frBrRegTr,2), timeDimSize, drawsNumb);
frMatrTest = zeros(size(frBrRegTr,2), timeDimSize, drawsNumb);

parfor d=1:drawsNumb  % construct fit and test firing rate matrices from non-overlaping 50% of trials for all repeats 
    frMatrDrawFit = [];
    frMatrDrawTest = [];
        
    for i=1:size(frBrRegTr,1)   % trials groups
        frMatrTrGrFit = zeros(size(frBrRegTr,2),size(frBrRegTr{i,1},2));
        frMatrTrGrTest = zeros(size(frBrRegTr,2),size(frBrRegTr{i,1},2));
                
        for j=1:size(frBrRegTr,2) % units
            frTrUnit = frBrRegTr{i,j};
                
            TrNumb = size(frTrUnit,1);
            FitTrNumb = round(trFracForFit*TrNumb);
            TrVect = 1:TrNumb;
            if trFracForFit==0
                fitTrials = datasample(1:TrNumb, FitTrNumb);
            else
                fitTrials = randperm(TrNumb, FitTrNumb);
            end
            testTrials = TrVect(~ismember(TrVect, fitTrials));

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

