function data = collectOnlineSpikes2(directory, maxSweep, data)
% function data = collectOnlineSpikes2(directory, maxSweep, data)
% collect data from benware spike files, version 2:
% directory: a BenWare data directory
% maxSweep: the index of the last sweep you want to get data from
%           (can be Inf or left out)
% data: any data already collected by this function (so you can
%       run it repeatedly)

if ~exist('maxSweep', 'var')
	maxSweep = Inf;
end

if ~exist('data', 'var')
	l = load(fix_slashes([directory '/gridInfo.mat']));
	expt = l.expt;
	grid = l.grid;

	sets = {};
	nSets = size(grid.stimGrid, 1);
	nChannels = expt.nChannels;

	for setIdx = 1:nSets
		sets{setIdx}.stimGridTitles = grid.stimGridTitles;
		sets{setIdx}.stimParams = grid.stimGrid(setIdx,:);
		sets{setIdx}.spikeTimes = cell(1, nChannels);
	end

	minSweep = 1;

else
	expt = data.expt;
	grid = data.grid;
	sets = {};
	for ii = 1:length(data.sets)
		sets{ii} = data.sets(ii);
	end
	nSets = length(data.sets);
	nChannels = length(data.sets(1).spikeTimes);
	minSweep = data.maxSweep + 1;

end

maxSweep = min(maxSweep, length(grid.randomisedGridSetIdx));

for sweepIdx = minSweep:maxSweep

	setIdx = grid.randomisedGridSetIdx(sweepIdx);
	spikeTimes = sets{setIdx}.spikeTimes;

	try
		fprintf('Trying to load sweep %d...', sweepIdx);
		l = load(fix_slashes(...
			[directory '/' constructDataPath(expt.sweepFilename, grid, expt, sweepIdx, 0)]));
		for channelNum = 1:nChannels
			if isempty(spikeTimes{channelNum})
				spikeTimes{channelNum}{1} = l.sweep.spikeTimes{channelNum};
			else
				spikeTimes{channelNum}{end+1} = l.sweep.spikeTimes{channelNum};
			end
		end
		fprintf('success\n');
	catch
		fprintf('failed\n');
		break
	end

	sets{setIdx}.spikeTimes = spikeTimes;
end

sets = [sets{:}];

data.expt = expt;
data.grid = grid;
data.sets = sets;
data.maxSweep = maxSweep;
