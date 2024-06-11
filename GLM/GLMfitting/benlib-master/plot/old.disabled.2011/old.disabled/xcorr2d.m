function [xc,lags] = xcorr2d(bigger,smaller,minlag,maxlag)
% function xc = xcorr2d(bigger,smaller)
% bw apr 2004
% calculate the cross-correlation between a long matrix and a short matrix, at
% all time lags.
% long and short should be mxt1 and mxt2 matrices, i.e. they should be the same 
% size in y, but can differ in x

if size(smaller,2) > size(bigger,2)
  tmp = smaller;
  smaller = bigger;
  bigger = smaller;
end

if ~exist('minlag','var')
  minlag = -size(bigger,2)+1;
  maxlag = size(bigger,2)-1;
  
elseif ~exist('maxlag','var')
  maxlag = minlag+size(bigger,2)-1;
end

if size(bigger,1) ~= size(smaller,1)
  fprintf('first dimension of the two matrices must be the same length for xcorr2d\n');
end

smaller = flipud(smaller);
xc = zeros(1,2*maxlag+1);
for ii = 1:size(bigger,1)
  [tmp,lags] = xcorr(bigger(ii,:),smaller(ii,:),maxlag);
  xc = xc+tmp;
end

start = find(lags==minlag);
stop  = find(lags==maxlag);
xc = xc(start:stop);
lags = lags(start:stop);

