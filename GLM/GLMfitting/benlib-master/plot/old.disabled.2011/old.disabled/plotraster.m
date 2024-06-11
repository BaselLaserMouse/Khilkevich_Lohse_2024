function plotraster(data,plotinfo)

if ~exist('plotinfo','var')
  plotinfo = 0;
end

offset = 1;
liney = [];
for ii = 1:length(data.set)
  for jj = 1:length(data.set(ii).repeats)
    times = data.set(ii).repeats(jj).t;
    plot(times,zeros(size(times))+offset,'k.');
    hold on;
    axis ij;
    offset = offset + 1;
  end
  liney = [liney offset];
end

for ii = 1:length(liney)
  plot(xlim,[liney(ii) liney(ii)]+.5,'k-');
end
hold off;