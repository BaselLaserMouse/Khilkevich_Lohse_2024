function Session = loadSessionBehav(folderSorted)

cd(folderSorted)
cd('Session')

fname = dir('*trials.json');
Runs = length(fname);
trials_data_exp_all = [];

for i = 1:Runs
    fname = dir('*trials.json');
    TrialData = jsondecode(fileread(fname(i).name)); 
    try
        trials_data_exp = [TrialData{:}];
    catch
        trials_data_exp = [TrialData(:)];
    end

    if i==1 % read setting for the first fsm-gui start
        fname = dir('*session_settings.json');
        Session.SessionSettings = jsondecode(fileread(fname(i).name));

        fname = dir('*computer_settings.json');
        Session.ComputerSettings = jsondecode(fileread(fname(i).name));
    end
%     
    for tr = 1:length(TrialData)
        trials_data_exp(tr).IsHit = strcmp(trials_data_exp(tr).trialoutcome, 'Hit');
        trials_data_exp(tr).IsMiss = strcmp(trials_data_exp(tr).trialoutcome, 'Miss');
        trials_data_exp(tr).IsFA = strcmp(trials_data_exp(tr).trialoutcome, 'FA');
        trials_data_exp(tr).IsAbort = strcmp(trials_data_exp(tr).trialoutcome, 'abort');
        trials_data_exp(tr).IsEarlyBlock = strcmp(trials_data_exp(tr).hazardblock, 'early');
        trials_data_exp(tr).IsLateBlock = strcmp(trials_data_exp(tr).hazardblock, 'late');
        trials_data_exp(tr).IsProbe = strcmp(trials_data_exp(tr).hazardprobe, 'probe');
    end

trials_data_exp_all = [trials_data_exp_all trials_data_exp];

end

    Session.trials_data_exp = trials_data_exp_all;

end
