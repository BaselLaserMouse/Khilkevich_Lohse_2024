function [BrainRegGroups, BrainRegGroupNames] = defineBrainRegGroupsV2

VisualEarly = {{'SCsl'}, {'LGd'},  {'VISp'}};

VisualHigherOrder = {{'VISl/pl'}, {'RSP'}, {'PPC'}, {'LP'}, {'LD'}};

cortexRostAndMot = {{'ACA'}, {'MOs'}, {'ORB'}, {'mPFC'}, {'MOp'}, {'FRP'}, {'AI'}};

thalamus = {  {'MG'}, {'Eth'}, {'VAL'}, {'VB'}, {'RT'}, {'PO'}, {'CL'}, {'MD/VM'}, {'PF'}};

cerebellum = {{'SIM'}, {'Lob4/5'}, {'CRUS1/2'}, {'CENT3'},  {'FL/PFL'}, {'DCN'}};

BG = {{'LS'}, {'CP'}, {'GPe'}, {'SNr/GPi'}};

midbrain = {{'SCml/dl'},{'APN'}, {'MRN'}, {'IC'}, {'NPC'}}; %not including MB anymore

hippocampus = { {'ENT'}, {'CA1'}, {'CA3'},  {'DG'}, {'SUB'}};

OroFacialNuc = {{'Orofacial Mot. Nuc.'}, {'GRN'}, {'MV'}, {'LHA'}}; % color LHA separately! 

olfactory = {{'MOB'}, {'TTd'}, {'DP'}};

BrainRegGroups = {VisualEarly, VisualHigherOrder, midbrain, thalamus, cortexRostAndMot, BG, cerebellum, hippocampus, OroFacialNuc, olfactory};
BrainRegGroupNames = {'VisualAreasEarly', 'VisualAreasHigherOrder', 'Midbrain', 'Thalamus','FrontAndMotCortex', 'BasalGanglia', 'Cerebellum', 'Hippocampus', 'Orofacial Nuclei', 'Olfactory areas'};

end