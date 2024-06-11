

code_path = '/home/mlohse/tfcd_npx_basicanalysis/NPX-analysis-April2021';
cd('/mnt/mlohse/ceph/public/projects/MiLo_20211201_DMDM_CausalCortex_fromwinstor/NPX_Opto_Recordings/Main/');
subject_path = uigetdir(pwd, 'Select subject folder');

cd(subject_path);
cd('Raw data');

sessions = dir(pwd); 
sessions(contains({sessions.name}, '.')) = [];
% data = [];

for i = 3:4%1:length(sessions)
    session_path = fullfile(subject_path, 'Raw data', sessions(i).name);
    [NPX_data_sesion, subject_name, session_name] = loadSessionNPX_main(session_path);
    data.(subject_name).(session_name) = NPX_data_sesion.(subject_name).(session_name);
end

cd(code_path);

clearvars -except data