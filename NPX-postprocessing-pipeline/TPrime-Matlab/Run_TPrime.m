
function Run_TPrime(TPrime_matlab_path, ses_ephys_processed_data_path, verbose_level)

    cd(fullfile(ses_ephys_processed_data_path, 'Kilosort&Phy'));
    probe_folders = dir(pwd);
    probe_folders(contains({probe_folders.name}, '.')) = [];
    probes_numb = length(probe_folders);

    for p = 1:probes_numb
        probe_path{p} = fullfile(probe_folders(p).folder, probe_folders(p).name);
        cd(probe_path{p});
        metafile = dir('*.ap.meta');
        meta = ReadMeta(metafile.name, pwd);
        NPX_sample_rate = str2double(meta.imSampRate);
        ss = readNPY('spike_times.npy');
        st = double(ss)/NPX_sample_rate;
        
        writeNPY(st, 'spike_times_sec.npy');
        probe_sync_txt_path_tmp = dir('*tcat.imec*.txt');
        probe_sync_txt_path{p} = fullfile(probe_sync_txt_path_tmp.folder, probe_sync_txt_path_tmp.name); 
        last_spike_time_old(p) = st(end);
    end

    cd(fullfile(ses_ephys_processed_data_path, 'Nidaq'));
    NI_events_file = dir('*NIdaq_events.mat');
    load(NI_events_file.name);
    sync = NIdaq_events.Synch.rise_t;
        
    fid_NI_sync = fopen('NI_Sync.txt', 'w');
    fprintf(fid_NI_sync,'%.6f\n', sync);
    fclose(fid_NI_sync);
    NI_Sync_txt_path = dir('NI_Sync.txt');
    NI_Sync_txt_path = fullfile(NI_Sync_txt_path.folder, NI_Sync_txt_path.name);

    cd(TPrime_matlab_path);
    bat_id = fopen('TPrime_templ.bat');
    bat_templ = textscan(bat_id, '%s', 'Delimiter', '^');
    line3 = bat_templ{1}{3};
    line3_path_start_ind = strfind(line3, 'NI_SYtxt_path');
    line3_new = [line3(1:line3_path_start_ind-1) '"' NI_Sync_txt_path '"'];

    bat_probe_lines = [];
    counter = 0;
    for p = 1:probes_numb       % make "-fromstream" lines
       counter = counter+1;
       bat_probe_lines{counter, 1} = ['-fromstream=' num2str(p) ',"' probe_sync_txt_path{p} '"'];
    end

    for p = 1:probes_numb       % make "-events," lines
       counter = counter+1;
       bat_probe_lines{counter, 1} = ['-events=' num2str(p) ',"' fullfile(probe_path{p}, 'spike_times_sec.npy') ','  fullfile(probe_path{p}, 'spike_times_sec_adj.npy') '"'];
    end
    
    bat_new = bat_templ{1};
    bat_new{3} = line3_new;
    bat_new = [bat_new; bat_probe_lines];
    
    for i = 1:length(bat_new)
        if i>=3
            line_tmp = bat_new{i};
            ind = strfind(line_tmp, '\');
            line_tmp(ind) = '/';
            bat_new{i} = line_tmp;
        end
        
        if i>=2&&i<length(bat_new)
            bat_new{i} = [bat_new{i} ' ^']; 
        end
    end
    
    bat_new_id = fopen('Run_TPrime.bat','w'); 
    fprintf(bat_new_id, '%s\n', bat_new{:});
    fclose(bat_new_id);

    system('Run_TPrime.bat');

    if verbose_level>0
        for p = 1:probes_numb           % read new spike times
            probe_path = fullfile(probe_folders(p).folder, probe_folders(p).name);
            cd(probe_path);
            st = readNPY('spike_times_sec_adj.npy');
            last_spike_time_new = st(end);
            drift = last_spike_time_new - last_spike_time_old(p);
            disp([probe_folders(p).name ', fixed clock drift of ' num2str(round(drift*1000)) ' ms' ])
        end    
    end    
end

