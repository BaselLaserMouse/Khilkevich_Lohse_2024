function [data]=loadSpecificSessions(SubjectFolder, SessionId)

code_path = '/home/mlohse/tfcd_npx_basicanalysis/GLMs/BatchTester/GLMfitting/NPX-analysis/load';
DataPath='/mnt/mlohse/winstor/swc/mrsic_flogel/public/projects/AnKh_20200820_NPX_DMDM/Temporal expectation data/'
cd(DataPath);

%subject_path = uigetdir(pwd, 'Select subject folder');

subject_path = [DataPath num2str(SubjectFolder) '/'];

cd(subject_path);
cd('Raw data');

sessions = dir(pwd); 
sessions(contains({sessions.name}, '.')) = [];
% data = [];

for i = SessionId%1:length(sessions)
    session_path = fullfile(subject_path, 'Raw data', sessions(i).name);
    [NPX_data_sesion, subject_name, session_name] = loadSessionNPX_main(session_path);
    data.(subject_name).(session_name) = NPX_data_sesion.(subject_name).(session_name);
end

cd(code_path);

clearvars -except data