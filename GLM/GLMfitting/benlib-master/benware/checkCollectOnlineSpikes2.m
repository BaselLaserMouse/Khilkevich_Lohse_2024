% check collectOnlineSpikes2

data1 = collectOnlineSpikes(directory);
data2 = collectOnlineSpikes2(directory, 30);
data2 = collectOnlineSpikes2(directory, Inf, data2);

%%
for setidx=1:length(data1.sets);
	for chanidx=1:length(data1.sets(setidx).spikeTimes)
		for repidx=1:length(data1.sets(setidx).spikeTimes{chanidx})
			if all(data1.sets(setidx).spikeTimes{chanidx}{repidx} == ...
				data2.sets(setidx).spikeTimes{chanidx}{repidx})
				fprintf('Set %d, chan %d, rep %d -- success\n', setidx, chanidx, repidx);
			else
				fprintf('Set %d, chan %d, rep %d -- failure\n', setidx, chanidx, repidx);
				keyboard;
			end
		end
	end
end