function [xb, yb] = bindata(x, y, n_bins)
% function [xb, yb] = bindata(x, y, n_bins)
%
% bin dataset according to x-values
% for plotting smooth curves (e.g. gain curves)
% 
% Inputs:
%  x, y -- vectors containing data
%  n_bins -- number of bins to plot

data = sortrows([x(:), y(:)]);
if ~exist('n_bins', 'var')
  n_bins = 100;
end

binsize = ceil(size(data, 1)/n_bins);

binned_data = zeros(n_bins, 2);

startidxs = 1:binsize:size(data, 1);
for bin = 1:length(startidxs)
  ii = startidxs(bin);
  binned_data(bin, :) = mean(data(ii:min(ii+binsize-1, size(data, 1)), :));
end

xb = binned_data(:, 1);
yb = binned_data(:, 2);
