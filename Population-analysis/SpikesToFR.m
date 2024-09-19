function frTrAllUnits = SpikesToFR(spikesTr, sigma, tBin, psthExtra, varargin)

    if isempty(varargin)||isempty(varargin{1})       
        scale = 1;  % spike count multiplier, used to save TF pulse response spike counts as int8/int16
    else
        scale = varargin{1};
    end
    
    gaussHw = 4*sigma;
    x = -gaussHw:tBin:gaussHw;
    gaussWindow = normpdf(x, 0, sigma);
    gaussWindow  = gaussWindow./sum(gaussWindow);

    for i=1:size(spikesTr,1)        
        for j=1:size(spikesTr,2)    % units
            frTrUnit = double(spikesTr{i,j})/tBin;
            frTrUnit = conv2(frTrUnit, gaussWindow, 'same');
            frTrUnit(:, [1:psthExtra/tBin end-psthExtra/tBin+1:end]) = [];
            frTrUnit = frTrUnit/scale;
            frTrAllUnits{i,j} = frTrUnit;
        end
    end
    
end

