function [y, bins] = plotpsth(set,bins,noplot,nodivide)

if ~exist('bins','var')
  bins = [0:50:1000];  
end

if isfield(set,'set')
  set = set.set;
end

if ~exist('noplot','var')
  noplot = false;
end

if ~exist('nodivide','var')
  nodivide = false;
end

times = [];
divisor = 0;
for ii = 1:length(set)
  for jj = 1:length(set(ii).repeats)
    times = [times set(ii).repeats(jj).t];
    divisor = divisor + 1;
  end
end

y = histc(times,bins);

if ~nodivide
  y = y/divisor;
end

if noplot==false  
  bar(bins,y,'histc');
end
