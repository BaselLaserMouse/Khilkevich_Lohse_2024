function ReRun_extract_NI_events(varargin)

    if isempty(varargin)
        try
            cd('/mnt/andreik/winstor/swc/mrsic_flogel/public/projects/AnKh_20200820_NPX_DMDM/Temporal expectation data/');
        catch
            try
                cd('Z:\swc\mrsic_flogel\public\projects\AnKh_20200820_NPX_DMDM\Temporal expectation data');
            end
        end
        subject_path = uigetdir(pwd, 'Select subject folder: NI events will be reextracted ON ALL SESSIONS!');
    else
        subject_path = varargin{1};
    end
    
    sessions_raw = dir(fullfile(subject_path, 'Raw data'));
    sessions_processed = dir(fullfile(subject_path, 'Processed data'));
    sessions_raw(contains({sessions_raw.name}, '.')) = [];
    sessions_processed(contains({sessions_processed.name}, '.')) = [];
    
    for i = 1:length(sessions_raw)
        cd(fullfile(sessions_raw(i).folder, sessions_raw(i).name, 'EphysNidaq'));
        nidq_file = dir('*.nidq.bin');
        NI_save_path = fullfile(sessions_processed(i).folder, sessions_processed(i).name, 'Nidaq');
        extract_events_times_from_NI_data(nidq_file.name, nidq_file.folder, NI_save_path);
    end   
    
end