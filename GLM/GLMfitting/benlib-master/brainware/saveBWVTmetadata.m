function metadata = saveBWVTmetadata(dir)
%% get metadata from BWVT files and save it in metadata.mat
%% only for BWVTs with one file per sweep/channel combo

l = load([dir filesep 'metadata.mat']);
metadata = l.metadata;

pattern = [num2str(metadata.channelOffset+1, '%03d') '-swp0000.bwvt'];

files = getfilesmatching([dir filesep '*' pattern '*']);

metadata.sweeps = [];

for file = files'
  fprintf('Reading files like %s...', file{1});
  s = splitstr(filesep, file{1});
  s = s{end};
  f = findstr(s, pattern);
  st = s(1:f-1);
  en = s(f+length(pattern):end);
  
  sweep = 0;
  found_data = true;
  

  while found_data
    sweep = sweep + 1;
    filepattern = [st '%n-swp' num2str(sweep, '%04d') '.bwvt' en];
    filename = regexprep(filepattern, '%n', ...
			 num2str(metadata.channelOffset+1, '%03d'));
    pathname = [dir filesep filename];

    if ~exist(pathname, 'file')
      found_data = false;
      continue;
    end
    
    bwvt = bwvtFileGunzipAndRead(pathname);
    if isempty(bwvt)
      fprintf('Empty bwvt file!\n');
      continue;
    end

    % contrast data type -- guess from length
    % NB this does not work for 'scaled' stimuli
    bwvt.stimlen = length(bwvt.signal)*bwvt.samplePeriod/1000;
    if round(bwvt.stimlen)==31
      bwvt.contraststim_version = 6;
    else
      bwvt.contraststim_version = 7;
    end
    
    bwvt = rmfield(bwvt, 'signal');
    
    bwvt.datafilepattern = filepattern;
    if isempty(metadata.sweeps)
      metadata.sweeps = bwvt;
    else
      metadata.sweeps(end+1) = bwvt;
    end
  end
  fprintf(' found %d sweeps\n', sweep);
    
end

metadata.contraststim_version = unique([metadata.sweeps(:).contraststim_version]);

% organise by stimulus in 'set' structure, one entry per stimulus
stimdir{6} = '/lab/bork/auditory-objects/stimuli/contrast/tokens/frozen.grids';
stimdir{7} = '/lab/bork/auditory-objects/stimuli/tokens/v7.grids';

stimfilepattern{6} = 'grid.contrast.%w.token.%t.mat';
stimfilepattern{7} = 'grid.contrast.fullwidth.%w.token.%t.mat';

stimparams = [reach(metadata.sweeps, 'stim.paramVal')' ...
              reach(metadata.sweeps, 'contraststim_version')'];
uniqueparams = unique(stimparams, 'rows');

set = [];
for setidx = 1:size(uniqueparams, 1)
  params = uniqueparams(setidx,:);
  thisset.sweepidx = find(all((stimparams==repmat(params,[size(stimparams,1) 1]))')');
  thisset.sweeps = metadata.sweeps(thisset.sweepidx);
  thisset.stim = thisset.sweeps(1).stim;
  thisset.contraststim_version = thisset.sweeps(1).contraststim_version;

  thisset.stim.fullwidth = ...
      thisset.stim.paramVal([strcmp(thisset.stim.paramName, 'Fullwidth')]);
  thisset.stim.token = ...
      thisset.stim.paramVal([strcmp(thisset.stim.paramName, 'Token')]);

  thisset.stimdir = stimdir{thisset.contraststim_version};
  stimfilename = regexprep(stimfilepattern{metadata.contraststim_version},  ...
                        '%w', num2str(thisset.stim.fullwidth));
  thisset.stimfilename = regexprep(stimfilename, ...
                        '%t', num2str(thisset.stim.token));

  if isempty(set)
    set = thisset;
  else
    set(end+1) = thisset;
  end
end

metadata.set = set;

try
  metadatafilename = [dir filesep 'metadata.mat'];
  updatemetadatafile(metadatafilename, metadata);
catch
  fprintf('Couldn''t save metadata file --- permissions problem?\n');
end
