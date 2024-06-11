function params = getnrparams(cellid)

runclassid = 2; % natrev
speed = 60; % 60Hz

cellfiles = dbgetscellfile('runclassid',runclassid,'speed',speed,'cellid',cellid);

params = struct;

% put stim and resp files in the appropriate fields of params struct
params.stimfiles = {};
params.respfiles = {};
for ii = 1:length(cellfiles)
  params.stimfiles{end+1} = [cellfiles(ii).stimpath cellfiles(ii).stimfile];
  params.respfiles{end+1} = [cellfiles(ii).path cellfiles(ii).respfile];
end

% reorder stim and resp so that conf data comes last and is
% therefore (?) used for validation

isconf = [];
for ii = 1:length(params.stimfiles)
  if findstr(params.stimfiles{ii},'conf')
    isconf(ii) = 1;
  else
    isconf(ii) = 0;
  end
end

isconf = isconf';
isconf(:,2) = [1:length(isconf)]';
isconf = sortrows(isconf,1);

params.stimfiles = params.stimfiles(isconf(:,2));
params.respfiles = params.respfiles(isconf(:,2));

params.stimloadcmd = 'loadimfile';
params.stimloadparms = {16, 17, 16};
params.stimfiltercmd = '';
params.stimfilterparms = [];

params.resploadcmd = 'respload';
params.resploadparms = {'',1,1,1};
params.respfiltercmd = '';
params.respfilterparms = [];

params.maxlag = [-6 13];
params.times = xcfilefracs(params);
