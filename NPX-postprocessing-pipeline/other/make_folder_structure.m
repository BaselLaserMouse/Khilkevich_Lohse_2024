function [ephys_raw_data_path_winstor, ephys_proc_data_path_winstor, NIdaq_proc_data_path_winstor] = make_folder_structure(subj_folder_winstor, current_ses_name)

    cd(subj_folder_winstor);

    %check if Raw data and Processed data folders exist, don't create them then 
    subj_folders = dir;
    subj_folders(1:2) = [];
    count = 0;
    for f = 1:length(subj_folders)
        if  (strcmp(subj_folders(f).name, 'Raw data') == 1) || (strcmp(subj_folders(f).name, 'Processed data') == 1)
            count = count+1;
        end
    end

    if count < 2
        mkdir('Raw data');
        mkdir('Processed data');
    end

    cd('Raw data')
    if exist(current_ses_name, 'dir')
        current_ses_name = [current_ses_name '_v2'];
    end
    mkdir(current_ses_name);
    cd(current_ses_name);
    mkdir('Cameras');
    mkdir('EphysNidaq');
    mkdir('Session');
    ephys_raw_data_path_winstor = fullfile(pwd, 'EphysNidaq');
    cd('..');
    cd('..');

    cd('Processed data')
    mkdir(current_ses_name);
    cd(current_ses_name);
    mkdir('Cameras');
    mkdir('Kilosort&Phy');
    mkdir('Nidaq');
    ephys_proc_data_path_winstor = fullfile(pwd, 'Kilosort&Phy');
    NIdaq_proc_data_path_winstor = fullfile(pwd, 'Nidaq');

    cd(subj_folder_winstor);
    
end

