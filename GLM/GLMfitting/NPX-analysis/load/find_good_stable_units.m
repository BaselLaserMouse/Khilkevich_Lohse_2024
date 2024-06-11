function good_and_stable_clusters = find_good_stable_units(probe)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

good_clusters = probe.cluster_id_KS_good;
ses_tot_time = probe.st(end);
Tbins_numb = 10;
ses_time_bins = 0:(ses_tot_time/Tbins_numb):ses_tot_time;       % divide session into Tbins_numb epochs

for cl = 1:length(good_clusters)
    sp_times = probe.st(probe.clu==good_clusters(cl));
    avg_fr = length(sp_times)/ses_tot_time;
    sp_count_per_time_bin = [];
    for t = 1:length(ses_time_bins)-1
        sp_count_per_time_bin(t) = sum(( sp_times>(ses_time_bins(t)) )&( sp_times<=(ses_time_bins(t+1)  )));
    end
     sp_count_drop_ses = min(sp_count_per_time_bin)/mean(sp_count_per_time_bin);

     if (sp_count_drop_ses > 0.3) && (avg_fr > 0.5)         % somewhat arbitrary cutoff for stability and minimal acceptable firing rate of unit
         is_stable(cl) = 1;
     end
end

disp(['Found ' num2str(sum(is_stable)) ' stable clusters out of ' num2str(length(good_clusters)) ])
good_and_stable_clusters = good_clusters(is_stable==1);   

end

