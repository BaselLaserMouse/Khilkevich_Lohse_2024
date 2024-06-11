

subjects = fieldnames(data);

for i = 1:length(subjects)
    
    sessions = fieldnames(data.(subjects{i}));
    for j = 1:length(sessions)
        probes_numb = length(data.(subjects{i}).(sessions{j}).NPX_probes);
        
        for p = 1:probes_numb
            sp = data.(subjects{i}).(sessions{j}).NPX_probes(p);
            good_clusters = data.(subjects{i}).(sessions{j}).NPX_probes(p).cluster_id_KS_good;
%             good_cl_coord = data.(subjects{i}).(sessions{j}).NPX_probes(p).good_cl_coord;
           

            ses_tot_time = sp.st(end);
            Tbins_numb = 10;
            ses_time_bins = 0:(ses_tot_time/Tbins_numb):ses_tot_time;
            
            is_stable = zeros(1, length(good_clusters));
            
            for cl = 1:length(good_clusters)
                sp_times = sp.st(sp.clu==good_clusters(cl));
                avg_fr = length(sp_times)/ses_tot_time;
                sp_count_per_time_bin = [];
                for t = 1:length(ses_time_bins)-1
                    sp_count_per_time_bin(t) = sum(( sp_times>(ses_time_bins(t)) )&( sp_times<=(ses_time_bins(t+1)  )));
                end
                 sp_count_drop_ses = min(sp_count_per_time_bin)/mean(sp_count_per_time_bin);
                 
                 if (sp_count_drop_ses > 0.4) && (avg_fr > 0.5)
                     is_stable(cl) = 1;
                 end
            end
            
            disp(['Found ' num2str(sum(is_stable)) ' stable clusters out of ' num2str(length(good_clusters)) ])
            good_and_stable_clusters = good_clusters(is_stable==1);     
            data.(subjects{i}).(sessions{j}).NPX_probes(p).cluster_id_good_and_stable = good_and_stable_clusters;
            
            good_and_stab_cl_coord = good_cl_coord(find(is_stable==1));
            data.(subjects{i}).(sessions{j}).NPX_probes(p).good_and_stab_cl_coord = good_and_stab_cl_coord;                 
        end
                    
   
        
    end
    
end