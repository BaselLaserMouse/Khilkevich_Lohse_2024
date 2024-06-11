function [data]=loadSpecificSessionsNaive(SubjectFolder)

%code_path = '/home/mlohse/tfcd_npx_basicanalysis/GLMs/BatchTester/GLMfitting/NPX-analysis/load';
%DataPath='/mnt/mlohse/winstor/swc/mrsic_flogel/public/projects/AnKh_20200820_NPX_DMDM/Temporal expectation data/'

DataPath='/mnt/mlohse/winstor/swc/mrsic_flogel/public/projects/AnKh_20200820_NPX_DMDM/Naive controls data/WithRandomReward/'
cd(DataPath);

data=load('ControlMice_NPXAutoCurated_VidSes_AllAdded_cleaned_August2022_struct', ['x' num2str(SubjectFolder)]); 

