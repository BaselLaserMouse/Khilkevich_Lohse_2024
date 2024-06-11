function  unit_count_probe_per_reg = get_units_per_regions_probe(good_cl_coord, allen, unit_count_probe_per_reg)


brain_reg = {good_cl_coord.brain_region};

for i = 1:length(brain_reg)
     brain_region_ind = find(strcmp(allen.acronym, brain_reg{i})==1);
     unit_count_probe_per_reg(brain_region_ind) = unit_count_probe_per_reg(brain_region_ind) + 1;
end


end

