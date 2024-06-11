function binplot(x, y, n_bins)
% function binplot(x, y, n_bins, varargin)
%
% plot binned scatterplot of y against x
% 
% Inputs:
%  x, y -- vectors containing data
%  n_bins -- number of bins to plot
%  varargin -- parameters passed to plot()

if ~exist('n_bins', 'var')
	n_bins = 100;
end

data = sortrows([x(:), y(:)]);
binsize = ceil(size(data, 1)/n_bins);

binned_data = zeros(n_bins, 2);

startidxs = 1:binsize:size(data, 1);
for bin = 1:length(startidxs)
  ii = startidxs(bin);
  binned_data(bin, :) = mean(data(ii:min(ii+binsize-1, size(data, 1)), :));
end

f = find(x==min(x), 1)
g = find(x==max(x), 1)
plot(binned_data(:,1), binned_data(:, 2), 'k-', [x(f) x(g)], [y(f) y(g)], 'ko');

