function data = collectOnlineSpikes(fileSpec, maxSweep)
% collect data from benware or brainware spike files

if any(fileSpec=='*')
	% then this should be a pattern matching .src files
	data = struct;
	files = getfilesmatching(fileSpec);
	sets = {};
	fileIdx = 1;
	fprintf('Reading %s...\n', files{fileIdx});
	indata = readSRCfile(files{fileIdx});
  fprintf('done\n')

	for setIdx=1:length(indata.sets)
		set = struct;
		set.stimGridTitles = indata.sets(setIdx).stim.paramName;
		set.stimParams = indata.sets(setIdx).stim.paramVal';
		set.spikeTimes = {};
		sw = indata.sets(setIdx).clusters(1).sweeps;
		set.spikeTimes = {};
		for sweepIdx = 1:length(sw)
			set.spikeTimes{fileIdx}{sweepIdx} = [sw(sweepIdx).spikes.time]';
		end
		sets{setIdx} = set;
	end

	for fileIdx = 2:length(files)
		fprintf('Reading %s\n', files{fileIdx});
		indata = readSRCfile(files{fileIdx});
		for setIdx=1:length(indata.sets)
			set = sets{setIdx};
			sw = indata.sets(setIdx).clusters(1).sweeps;
			for sweepIdx = 1:length(sw)
				set.spikeTimes{fileIdx}{sweepIdx} = [sw(sweepIdx).spikes.time]';
			end
			sets{setIdx} = set;
		end
	end

	sets = [sets{:}];
	data.sets = sets;
else
	% then this is a benware directory
	directory = fileSpec;
	if ~exist('maxSweep', 'var')
		maxSweep = Inf;
	end

	l = load([directory '/gridInfo.mat']);
	expt = l.expt;
	grid = l.grid;

	nSets = size(grid.stimGrid, 1);
	nChannels = expt.nChannels;

	sets = {};
	for setIdx = 1:nSets
		fprintf('Set %d\n', setIdx);
		sets{setIdx}.stimGridTitles = grid.stimGridTitles;
		sets{setIdx}.stimParams = grid.stimGrid(setIdx,:);
		sweepIndices = find(grid.randomisedGridSetIdx==setIdx)';

		spikeTimes = cell(1, nChannels);

		for sweepNum = sweepIndices
			if sweepNum>maxSweep
				continue
			end

			try
				fprintf('Trying to load sweep %d...', sweepNum);
				l = load([directory '/' fix_slashes(constructDataPath(expt.sweepFilename, grid, expt, sweepNum, 0))]);
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
		end

		sets{setIdx}.spikeTimes = spikeTimes;
	end

	sets = [sets{:}];

	data.expt = expt;
	data.grid = grid;
	data.sets = sets;
end