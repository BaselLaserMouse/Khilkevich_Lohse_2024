% copy metadata from contrast data dirs to a local dir (./metadata) for
% analysis

exptdirpattern = '/lab/bork/auditory-objects/data/auditory-objects.data.expt*';

%exptdirs = getdirsmatching(exptdirpattern);

exptdirs = {
    '/lab/bork/auditory-objects/data/auditory-objects.data.expt19';
    '/lab/bork/auditory-objects/data/auditory-objects.data.expt20';
    '/lab/bork/auditory-objects/data/auditory-objects.data.expt21';
    '/lab/bork/auditory-objects/data/auditory-objects.data.expt22'};

if ~exist('./metadata', 'dir')
  mkdir('./metadata');
end

for ii = 1:length(exptdirs)
  exptdir = exptdirs{ii};
  datadirs = getdirsmatching([exptdir filesep 'raw.contrast/P*']);
    for jj = 1:length(datadirs)
    datadir = datadirs{jj};
    fprintf([datadir '\n']);
    try
      origfile = [datadir filesep 'metadata.mat'];
      l = load(origfile);
      metadata = l.metadata;
      newfile = ['./metadata/e' num2str(metadata.exptnum) '.' metadata.penid ...
	       '.' metadata.side '.' metadata.exptname '.metadata.mat'];
      copyfile(origfile, newfile);
    catch
      fprintf('failed\n');
    end

  end
end