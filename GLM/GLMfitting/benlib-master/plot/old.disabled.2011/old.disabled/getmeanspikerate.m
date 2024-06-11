function [mn,sem,rate,bins] = getmeanspikerate(set,bins)

if ~exist('bins','var')
  bins = [0:50:1000];  
end

if isfield(set,'set')
  set = set.set;
end

rate = zeros(0,length(bins));

for ii = 1:length(set)
  for jj = 1:length(set(ii).repeats)
    rate(end+1,:) = histc(set(ii).repeats(jj).t,bins);
  end
end
rate = rate/(bins(2)-bins(1))*1000;

mn = mean(rate);
sem = std(rate)/sqrt(size(rate,1));
