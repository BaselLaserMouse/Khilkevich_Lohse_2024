function [y, bins] = binspikes(set,bins)

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

y = {};
for ii = 1:length(set)
  y{ii} = [];
  for jj = 1:length(set(ii).repeats)
    y{ii}(jj,:) = histc(set(ii).repeats(jj).t,bins);
  end
end

if length(y)==1
  y = y{1};
end