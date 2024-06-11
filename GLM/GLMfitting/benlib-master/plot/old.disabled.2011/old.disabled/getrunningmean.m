function y = getrunningmean(x,winlen)
% function y = getrunningsd(x,winlen)
% get mean of x in a boxcar window of length winlen
% bw jun 2005

x = shiftdim(x);

if ~exist('winlen') | isempty(winlen)
  winlen = 50;
end

xs = zeros(length(x),winlen)+nan;
for ii = 1:winlen
  tmp = x(ii:end);
  xs(1:length(tmp),ii) = tmp;
end

y = nanmean(xs')';

y = reshape(y,size(x));
