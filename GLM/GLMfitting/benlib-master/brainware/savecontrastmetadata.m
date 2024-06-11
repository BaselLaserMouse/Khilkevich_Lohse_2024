exptdirpattern = '/lab/bork/auditory-objects/data/auditory-objects.data.expt*';

%exptdirs = getdirsmatching(exptdirpattern);

exptdirs = {
    '/lab/bork/auditory-objects/data/auditory-objects.data.expt19';
    '/lab/bork/auditory-objects/data/auditory-objects.data.expt20';
    '/lab/bork/auditory-objects/data/auditory-objects.data.expt21';
    '/lab/bork/auditory-objects/data/auditory-objects.data.expt22'};

for ii = 1:length(exptdirs)
  exptdir = exptdirs{ii};
  datadirs = getdirsmatching([exptdir filesep 'raw.contrast/P*']);
  for jj = 1:length(datadirs)
    datadir = datadirs{jj};
    fprintf([datadir '\n']);
    addbasicmetadata(datadir);
    saveBWVTmetadata(datadir);
  end
end