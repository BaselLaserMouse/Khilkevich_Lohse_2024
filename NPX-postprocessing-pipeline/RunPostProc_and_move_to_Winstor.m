
function RunPostProc_and_move_to_Winstor

    code_path = 'C:\Users\NPX1\Documents\code\DMDM_NPX_postprocessing_tools';
    cd('D:\SGL_DATA');  %default NPX data directory
    [NIbinName, ses_path_raw] = uigetfile('*.bin', 'Select NI Binary File');
    ind = strfind(NIbinName, '_g');
    ind = ind(end);

    current_ses_name = NIbinName(1:ind-1);

    try 
        cd('Y:\public\projects') % ceph
    catch
        try
            cd('Z:\swc\mrsic_flogel\public\projects')   % winstor
        end
    end

    subj_folder_winstor = uigetdir(pwd, 'Select subject folder on Winstor');

    % create folder structure for Raw amd Processed data
    [ephys_raw_data_path_winstor, ephys_proc_data_path_winstor, NIdaq_proc_data_path_winstor] = make_folder_structure(subj_folder_winstor, current_ses_name);

    % Extract times of events from NIdaq data
    disp('Extracting events from NI file')
    NIdaq_events_ses_path = extract_events_times_from_NI_data(NIbinName, ses_path_raw);
    [status, msg] = copyfile(NIdaq_events_ses_path, NIdaq_proc_data_path_winstor);

    if status == 1
        disp('Extracted events have been copied to Winstor')
    else
        disp(msg)
    end

    %copy raw data
    disp('Copying raw data to Winstor')
    [status, msg] = copyfile(ses_path_raw, ephys_raw_data_path_winstor);

    if status == 1
        disp('Raw data had been copied to Winstor')
    else
        disp(msg)
    end
    % run CatGT on NPX data only, copy to winstor   
    disp('Running CatGT')
    Run_CatGT_just_probes(ses_path_raw, current_ses_name)    

    cd('E:\CGT_OUT'); % default CatGT folder
    catgt_folders = dir;
    catgt_folders(1:2) = [];

    for i = 1:length(catgt_folders)
        if ~isempty(strfind(catgt_folders(i).name, ['catgt_' current_ses_name ]))
            ses_path_catgt = fullfile(catgt_folders(i).folder, catgt_folders(i).name);

            disp('Copying processed data to Winstor')
            [status, msg] = copyfile(ses_path_catgt, ephys_proc_data_path_winstor);
            if status == 1
                disp('Processed data had been copied to Winstor')
            else
                disp(msg)
            end
        else % should mean it was a habituation session
            disp('No probe files found')
        end
    end

  
    disp('Finished!')
    cd(code_path)
end

