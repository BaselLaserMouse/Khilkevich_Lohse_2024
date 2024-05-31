function Run_TPrime_all_sessions_per_subject(varargin)

    TPrime_matlab_path = 'C:\Users\NPX1\Documents\code\DMDM_NPX_postprocessing_tools\TPrime-Matlab';
    
    if isempty(varargin)
        try
            cd('/mnt/andreik/winstor/swc/mrsic_flogel/public/projects/AnKh_20200820_NPX_DMDM/Temporal expectation data/');
        catch
            try
                cd('Z:\swc\mrsic_flogel\public\projects\AnKh_20200820_NPX_DMDM\Temporal expectation data');
            end
        end
            subject_path = uigetdir(pwd, 'Select subject folder to run TPrime');
    else
        subject_path = varargin{1};
    end
    
    sessions_processed = dir(fullfile(subject_path, 'Processed data'));
    sessions_processed(contains({sessions_processed.name}, '.')) = [];
    
    for i = 1:length(sessions_processed)
        
        try         % easy way to skip histology and other misc folders
            Run_TPrime(TPrime_matlab_path, fullfile(sessions_processed(i).folder, sessions_processed(i).name), 1)
        end
    end   
end