function [xb, yb] = bindata(x, y, n_bins)
% function [xb, yb] = bindata(x, y, n_bins)
%
% bin dataset according to x-values
% for plotting smooth curves (e.g. gain curves)
% 
% Inputs:
%  x, y -- vectors containing data
%  n_bins -- number of bins to plot

if ~exist('n_bins', 'var')
  n_bins = 100;
end

binEdges = linspace(min(x), max(x), n_bins+1);

[h,whichBin] = histc(x, binEdges);

for i = 1:n_bins
    flagBinMembers = (whichBin == i);
    binMembers     = y(flagBinMembers);
    binMean(i)     = mean(binMembers);
end

xb = (binEdges(1:end-1)+binEdges(2:end))/2;
yb = binMean;

f = find(isfinite(yb));
xb = xb(f);
yb = yb(f);

