
function [data, subject_name, session_name] = loadSessionNPX_main(varargin)

    if isempty(varargin)
        try
            cd('/mnt/andreik/winstor/swc/mrsic_flogel/public/projects/AnKh_20200820_NPX_DMDM/Temporal expectation data/');
        end
        session_path = uigetdir(pwd, 'Select session folder with raw data');
    else
        session_path = varargin{1};
    end
    
    ind_tmp = strfind(session_path, '/');
    subject_name = session_path( ind_tmp(end-2)+1:ind_tmp(end-1)-1 );
    subject_name = genvarname(subject_name);
    subject_path = session_path( 1:ind_tmp(end-1) );
    session_name = session_path( ind_tmp(end)+1:end );

    % load beahvioral data
    behav_data = loadSessionBehav(session_path);

    % load NIdaq events 
    session_path = fullfile(subject_path, 'Processed data', session_name);
    cd(session_path);
    cd('Nidaq');
    NI_events_file = dir([ session_name '*']);
    NI_events = load(NI_events_file.name);
    NI_events = NI_events.NIdaq_events;

    % load Kilosort data, keep only units that were labeled "good" for first
    % pass analysis

    cd('..');
    cd('Kilosort&Phy');
    probe_folders = dir([ session_name '*']);

    for p = 1:length(probe_folders)
        kilosort_path = fullfile(session_path, 'Kilosort&Phy', probe_folders(p).name);
%         kilosort_path = fullfile(session_path, 'Kilosort&Phy', probe_folders(p).name, 'run2');

        ALF_path = fullfile(session_path, 'IBL_ALF', probe_folders(p).name);

        cd(kilosort_path);
        probe = loadKSdir(pwd);
        cluster_qual_KS_tmp = tdfread( [pwd '/cluster_KSLabel.tsv'] , 'tab');

        is_cl_labeled_good = [];
        for cl = 1:length(cluster_qual_KS_tmp.cluster_id)
            is_cl_labeled_good(cl) = strcmp(cluster_qual_KS_tmp.KSLabel(cl,:), 'good');
        end
        probe.cluster_id_KS_good = cluster_qual_KS_tmp.cluster_id(is_cl_labeled_good==1);
        probe.cluster_id_good_and_stable = find_good_stable_units(probe);
        
        
        try
            % read probe location in Allen CCF coordinates using priviously done track tracing 
            probe_coord = getProbe_location(ALF_path);
            probe.probe_coord = probe_coord;

            % calculate channel with max aplitude for each good unit, get corresponding brain area
            [~, good_cl_ind, ~] = intersect(probe.cids, probe.cluster_id_KS_good);
            [~, max_ch_good_cl] = max(max(abs(probe.temps(good_cl_ind,:,:)), [], 2), [], 3);
         %    probe_brain_regions = {probe_coord.brain_region};

            clearvars good_cl_coord;
            for cl = 1:length(good_cl_ind)
                good_cl_coord(cl) = probe_coord(max_ch_good_cl(cl));
            end 
            good_cl_coord = rmfield(good_cl_coord ,'axial');
            good_cl_coord = rmfield(good_cl_coord ,'lateral');

            probe.good_cl_coord = good_cl_coord;
            
            [~, good_and_st_cl_ind, ~ ] = intersect(probe.cluster_id_KS_good, probe.cluster_id_good_and_stable);
            good_and_stab_cl_coord = good_cl_coord(good_and_st_cl_ind);
            probe.good_and_stab_cl_coord = good_and_stab_cl_coord;
        end
        
        [spikeAmps, spikeDepths, templateDepths, tempAmps, tempsUnW, templateDuration, waveforms] = templatePositionsAmplitudes(probe.temps, probe.winv, probe.ycoords, probe.spikeTemplates, probe.tempScalingAmps);
        probe.templateDepths = templateDepths;
        probe.templateWaveforms = waveforms;
        
        probe = rmfield(probe, {'spikeTemplates', 'tempScalingAmps', 'temps', 'winv'});
        data.(subject_name).(session_name).NPX_probes(p) = probe;
        
    end
    
    data.(subject_name).(session_name).NI_events = NI_events;
    data.(subject_name).(session_name).behav_data = behav_data;
    
end