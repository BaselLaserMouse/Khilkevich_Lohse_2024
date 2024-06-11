
code_path = pwd; 
allen = loadStructureTree_short(fullfile(code_path, '/analysis/Brain_regions/allen_structure_tree_safe_2017.csv'));

unit_count_probe_per_reg = zeros(1, length(allen.id));
subjects = fieldnames(data);

for i = 1:length(subjects)
    
    sessions = fieldnames(data.(subjects{i}));
    for j = 1:length(sessions)
        probes_numb = length(data.(subjects{i}).(sessions{j}).NPX_probes);
        
        for k = 1:probes_numb    
            good_cl_coord = data.(subjects{i}).(sessions{j}).NPX_probes(k).good_cl_coord;
            unit_count_probe_per_reg = get_units_per_regions_probe(good_cl_coord, allen, unit_count_probe_per_reg);
        end
    end
    
end
%%
[unit_count_per_brain_reg_sorted, ind] = sort(unit_count_probe_per_reg, 'descend');
brain_reg_sorted = allen.acronym(ind);
brain_reg_numb = sum(unit_count_per_brain_reg_sorted>5);

figure('units','normalized','outerposition',[0 0.1 1 0.85]);
coulums_numb = 25;
rows_numb = ceil(brain_reg_numb/coulums_numb);
 
for row = 1:rows_numb
    subplot(rows_numb, 1, row) 
    
    brain_reg_sorted_row = brain_reg_sorted(1+coulums_numb*(row-1):row*coulums_numb);
    bar(1:coulums_numb, unit_count_per_brain_reg_sorted(1+coulums_numb*(row-1):row*coulums_numb ), 'b'); 
    
%     if row == 1
%        ylim_all = ylim; % use the same y scale for al rows
%     end
    
    xticks(1:coulums_numb)
    xticklabels(brain_reg_sorted_row);
%     ylim(ylim_all);
box off
end
