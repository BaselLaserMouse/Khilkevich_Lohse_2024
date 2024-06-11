function plotraster(data)

% make raster itself
offset = 0;
liney = [];
for ii = 1:length(data.set)
  plot(data.set(ii).spikes.t,data.set(ii).spikes.repeat_id+offset,'k.');
  hold on;
  axis ij;
  
  offset = max(data.set(ii).spikes.repeat_id)+offset;
  liney = [liney offset];
end

for ii = 1:(length(liney)-1)
  plot(xlim,[liney(ii) liney(ii)]+.5,'k-');
end
hold off;
axis tight;
xlabel('ms');
ylabel('Repeat #');

labely = ([0 liney(1:end-1)]+liney(1:end))/2;


%% generate labels
fns = fieldnames(data.set(1).stim_params);
fns = fns(~strcmp(fns,'all'));

% only include stim params that have more than one unique value
% (i.e. that vary within the data set)
labels = {};
for ii = 1:length(fns)
  vals = reach(data.set,['stim_params.' fns{ii}]);
  if length(unique(vals))>1
    for jj = 1:length(data.set)
      if length(labels)<jj
        labels{jj} = '';
      end
      labels{jj} = sprintf([ labels{jj} fns{ii} ' ' num2str(vals(jj)) '\n']);
    end
  end
end

% remove trailing punctuation
for ii = 1:length(labels)
  labels{ii} = labels{ii}(1:end-1);
end

xl = xlim*1.02;
% add labels to plot
for ii = 1:length(labels)
  %labels{ii}
  text(xl(2),labely(ii),textfix(labels{ii}));
end
pos = get(gca,'Position');
set(gca,'Position',[pos(1)-.05 pos(2) pos(3)*.95 pos(4)]);

