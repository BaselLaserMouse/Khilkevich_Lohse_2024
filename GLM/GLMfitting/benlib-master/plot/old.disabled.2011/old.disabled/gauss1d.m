function y = gauss1d(len,ctr,sd)
% function y = gauss1d(len,ctr,sd)
% bw mar 2004
% make a gaussian distribution in 1D with specified centre and spread

x = 1:len;
constant = 1/(sd*sqrt(2*pi));
exponent = -((x-ctr).^2)./(2*sd^2);
y = constant * exp(exponent);
