function r = getresp(stim,filter,lags)
% function r = getresp(stim,filter,lags)
% bw mar 2004
% calculates the response of a filter to a stimulus
% this is a wrapper for xcorr2d which copes with different
% lags
% stim and filter should be mxt1 and mxt2 matrices, i.e. they should be the same 
% size in y, but can differ in x
% lines up the result 'correctly', so that the first
% bin contains the zero-lag response to the first stimulus,
% regardless of the length of stimulus and filter, and values of
% lags.
% HOWEVER, lags must increase in steps of 1.


d = diff(lags);
if min(d)<1 | max(d)>1 
  fprintf('getresp can only cope with lags that are spaced by 1\n');
  return;
end

if length(lags) ~= size(filter,2)
  fprintf('lags should be the same size as the filter\n');
  return;
end

[r xclags] = xcorr2d(stim,flipud(fliplr(filter)),min(0,min(lags))-max(lags),size(stim,2)+max(0,max(lags)));

r = shiftmat(r,max(lags),nan);
f = find(xclags==0);
r = r(f:f+size(stim,2)-1);
