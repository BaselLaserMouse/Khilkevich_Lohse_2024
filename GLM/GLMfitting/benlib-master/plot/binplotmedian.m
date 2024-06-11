function [x, y] = binplot(x, y, n_bins, varargin)
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
  binned_data(bin, :) = nanmedian(data(ii:min(ii+binsize-1, size(data, 1)), :));
end

if nargout==0
	plot(binned_data(:,1), binned_data(:, 2), varargin{:});
else
	x = binned_data(:,1);
	y = binned_data(:,2);
end
