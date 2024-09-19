function frMatr = leaveOnlyCommonUnits(frMatr, UnitIndNotUsed, UnitIndNotUsedOther)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if ~isempty(UnitIndNotUsedOther)
    if ~isempty(UnitIndNotUsed)
        unitNumbVect = 1:(size(frMatr,1)+length(UnitIndNotUsed));
        [wasUnitDel,~] = ismember(unitNumbVect, UnitIndNotUsed);
        frMatrExp(wasUnitDel==0,:,:) = frMatr;
        frMatrExp(wasUnitDel==1,:,:) = NaN;
    else
        frMatrExp = frMatr;
    end
    try
        indToDel = unique([UnitIndNotUsed UnitIndNotUsedOther]);
    catch
        indToDel = unique([UnitIndNotUsed UnitIndNotUsedOther']);
    end
    frMatrExp(indToDel,:,:) = [];
    frMatr = frMatrExp;    
end
end

