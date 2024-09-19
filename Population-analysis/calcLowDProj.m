function [frProjLowD, frProjLowDTFResp, frProjLowDTFNonResp, frProjHitsRandSelFit] = calcLowDProj(frMatr, u, TFRespNonRespUnits, drawsRandTF, varargin)

    if ~isempty(varargin)       % if projecting on dimensions found from a specific condition, subtract means of that condition 
        frMatr = frMatr - repmat(varargin{1}{2}, 1, size(frMatr,2)); % mean across each neuron 
    else
        frMatr = centerFrMatr(frMatr,2);
    end
    
    frProjLowD = u'*frMatr;

    if ~isempty(TFRespNonRespUnits)
        uTFResp = u';
        uTFResp(:,TFRespNonRespUnits==0) = 0; % set loadings of nonTF responsive untis to 0
        uTFNonResp = u';
        uTFNonResp(:,TFRespNonRespUnits==1) = 0; % set loadings of TF responsive untis to 0

        frProjLowDTFResp = uTFResp*frMatr;
        frProjLowDTFNonResp = uTFNonResp*frMatr;

        frProjLowDRandSelDraw = zeros(size(frProjLowD,1), size(frProjLowD,2), drawsRandTF);
        for d2=1:drawsRandTF % pick random combinations of units, the same sample as number of TF responsive ones
            randSelInd=randperm(length(TFRespNonRespUnits), sum(TFRespNonRespUnits) );
            uRandSel = zeros(size(u,2), size(u,1));
            uRandSel(:,randSelInd) = u(randSelInd,:)'; 
            frProjLowDRandSelDraw(:,:,d2) = uRandSel*frMatr;
        end

        frProjHitsRandSelFit = mean(frProjLowDRandSelDraw,3);
    else
        frProjLowDTFResp = [];
        frProjLowDTFNonResp = [];
        frProjHitsRandSelFit = [];
    end
end

