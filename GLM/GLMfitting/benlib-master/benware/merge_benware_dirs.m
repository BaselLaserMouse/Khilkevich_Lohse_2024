function merge_benware_dirs(dir1, dir2)
% function merge_benware_dirs(dir1, dir2)
% 
% Merge two directories of benware data from the same
% grid type, merging the metadata appropriately
% 
% Outputs:
%  saved in dir1.merged
% load both gridInfo.mat files
grid1 = load([dir1 '/gridInfo.orig.donotalter.mat']);
grid2 = load([dir2 '/gridInfo.orig.donotalter.mat']);

% check that the grid names are the same
if ~strcmp(grid1.grid.name, grid2.grid.name)
  error('Grid names are not the same');
end

% check that the grids are the same
%if any(size(grid1.grid.stimGrid)~=size(grid1.grid.stimGrid)) || ...
%      any(grid1.grid.stimGrid(:)~=grid2.grid.stimGrid(:))
%  fprintf('Cannot yet deal with different stim grids\n');
%keyboard
%end

% find how many complete sweeps are present in dir1

% first, find if we have data from channel 1 in sweep 1. if not,
% assume channel 17 (it is probably a RHS penetration)
dir1path = regexprep(grid1.expt.dataFilename, '\', '/');
dir1path = [dir1 '/' dir1path];
datapath = constructDataPath(dir1path, ...
		       grid1.grid, grid1.expt, 1, 1);

if exist(datapath, 'file')
  firstChannel = 1;
else
  firstChannel = 17;
end

% now, find the last sweep that has data saved for the first channel

for sweepNum = 1:grid1.grid.nSweepsDesired
  datapath = constructDataPath(dir1path, ...
			       grid1.grid, grid1.expt, sweepNum, firstChannel);
  if ~exist(datapath, 'file')
    sweepNum = sweepNum - 1;
    break;
  end
end


% now, check that the last sweep is complete, i.e. has the same 
% number of channels as the first
wildcardpath = regexprep(dir1path, '%C', '*');
sweep1path = constructDataPath(wildcardpath, ...
                               grid1.grid, grid1.expt, 1, 1);
nChannels = length(getfilesmatching(sweep1path));
sweepNpath = constructDataPath(wildcardpath, ...
                               grid1.grid, grid1.expt, sweepNum, 1);
nFilesN = length(getfilesmatching(sweepNpath));

if nFilesN ~= nChannels
  sweepNum = sweepNum - 1;
end

lastSweep = sweepNum;

% merge grid info
grid = grid1.grid;
grid.stimGrid = union(grid1.grid.stimGrid, grid2.grid.stimGrid,'rows');
grid.randomisedGrid = [grid1.grid.randomisedGrid(1:lastSweep,:); grid2.grid.randomisedGrid];
[dummy, grid.randomisedGridSetIdx] = ismember(grid.randomisedGrid, grid.stimGrid, 'rows');
grid1.grid.nSweepsDesired = length(grid1.grid.randomisedGridSetIdx);

expt = grid1.expt;

% temporary directory for result of merge
tmpdir = tempname('.');
mkdir(tmpdir);
save([tmpdir '/gridInfo.orig.donotalter.mat'], 'expt', ...
      'grid');

% copy f32 files from dir1
mkdir([tmpdir '/raw.f32']);

% copy files from dir1/raw.f32 to tmpdir/raw.f32
files = getfilesmatching([dir1 '/raw.f32/*.f32']);
fprintf('Copying %d files from %s\n', length(files), dir1);

for ii = 1:length(files)
  file = files{ii};
  [dirname, leafname] = split_path(file);
  unix(['cp -l ' file ' ' tmpdir '/raw.f32/' leafname]);
  %fprintf('\n');
end

% copy files from dir2/raw.f32 to tmpdir/raw.f32
% they will be named using name convention from dir1
% so that they look like extra sweeps continuing after those from dir1
dir2path = regexprep(grid2.expt.dataFilename, '\', '/');
dir2path = [dir2 '/' dir2path];
tmppath = regexprep(grid1.expt.dataFilename, '\', '/');
tmppath = [tmpdir '/' tmppath];
for sweepNum = 1:grid2.grid.nSweepsDesired
  fprintf('Copying sweep %d from %s sweep %d\n', sweepNum, dir2, sweepNum);
  for channelNum = firstChannel:firstChannel+nChannels-1
    sourcepath = constructDataPath(dir2path, ...
			       grid2.grid, grid2.expt, sweepNum, channelNum);
    destpath = constructDataPath(tmppath, ...
			       grid1.grid, grid1.expt, sweepNum+lastSweep, ...
				 channelNum);
    if ~exist(sourcepath, 'file')
      break;
    end
    
    unix(['cp -l ' sourcepath ' ' destpath]);
   
  end

  if ~exist(sourcepath, 'file')
    break;
  end

  %fprintf('\n');
end

% copy peninfo.csv
copyfile([dir1 '/peninfo.csv'], [tmpdir '/peninfo.csv']);

unix(['mv ' tmpdir ' ' dir1 '.merged']);

