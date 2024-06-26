clear params;
params.stimfile='/auto/fs1/willmore/natrev2005.128.index60.1.imsm';
if 0
  params.sf = 8;
  params.ratio = 0.01; % ratio of +ve and -ve parts of impulse response
  params.t1=0.25; % time constant of +ve part
  params.t2=0.5; % time constant of -ve part
end

lag = 2;

% note i'm using an altered versions of modelgenresponse so the RF
% is 1/3 of the stimulus size

% responses to natrev
[psth,stim,strf]=modelgenresponse(params);
psth = max(psth,0);
save /auto/fs1/willmore/ed_data/e2004-08-08/model4.edrev3.000.mat psth;

% make opti 2
optichoosescript('model4',0,lag,128,1);

pypestim2imsmraw('/auto/sal2/optichosen/e2004-08-08/model4/','index1','/auto/fs1/willmore/ed_data/e2004-08-08/model4.opti1.imsm',1);

params.stimfile='/auto/fs1/willmore/ed_data/e2004-08-08/model4.opti1.imsm';

% responses to opti 1
[psth,stim,strf]=modelgenresponse(params);
psth = max(psth,0);
save /auto/fs1/willmore/ed_data/e2004-08-08/model4.edrev3.001.mat psth;

% make opti 2
optichoosescript('model4',[0 1],lag,128,1);

pypestim2imsmraw('/auto/sal2/optichosen/e2004-08-08/model4/','index2','/auto/fs1/willmore/ed_data/e2004-08-08/model4.opti1.imsm',1);

params.stimfile='/auto/fs1/willmore/ed_data/e2004-08-08/model4.opti1.imsm';

% responses to opti 2
[psth,stim,strf]=modelgenresponse(params);
