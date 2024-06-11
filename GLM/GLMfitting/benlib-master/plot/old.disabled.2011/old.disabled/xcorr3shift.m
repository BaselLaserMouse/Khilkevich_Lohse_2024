function y = xcorr3shift(stim,filter,maxlag)

y = xcorr3(stim, filter);
shift = size(filter,3)+maxlag(1)-1;
y = [ones(1,shift)*nan y(1,1:end-shift)];
