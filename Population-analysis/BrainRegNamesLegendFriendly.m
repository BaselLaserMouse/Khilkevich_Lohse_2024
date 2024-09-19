function BrainRegNames = BrainRegNamesLegendFriendly(brRegOfIntr)
    brRegOfIntrLeg = [];
    
    for j=1:length(brRegOfIntr)
        if j==length(brRegOfIntr)
            brRegOfIntrLeg{j} = [brRegOfIntr{j}];
        else
            brRegOfIntrLeg{j} = [brRegOfIntr{j} ', '];
        end
    end
    BrainRegNames = cell2mat(brRegOfIntrLeg);
end

