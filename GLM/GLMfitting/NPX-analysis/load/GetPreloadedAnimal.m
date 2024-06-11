function [data]=loadSpecificSessions(SubjectFolder)

code_path = '/home/mlohse/tfcd_npx_basicanalysis/GLMs/BatchTester/GLMfitting/NPX-analysis/load';
%DataPath='/mnt/mlohse/winstor/swc/mrsic_flogel/public/projects/AnKh_20200820_NPX_DMDM/Temporal expectation data/'

DataPath='/mnt/mlohse/winstor/swc/mrsic_flogel/public/projects/MiLo_20211201_DMDM_CausalCortex/NPX_Opto_Recordings'
cd(DataPath);

data=load('dataAllMice', ['x' num2str(SubjectFolder)]); 

