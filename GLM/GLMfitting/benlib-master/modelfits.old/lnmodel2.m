function yhat_t = lnmodel2(x, data, idx)
% function yhat_t = lnmodel(x, data)
% 
% Calculate sigmoid LN model
% Different inputs -- works with fitmodel2 and friends
% 
% Inputs:
%  x -- parameters
%  data -- output of separable kernel
%  idx -- indices to fit

if ~exist('idx', 'var')
	idx = 1:length(z_t);
end

a = x(1);
b = x(2);
c = x(3);
d = x(4);

z_t = data.z_t(idx);

g = 1./(1+exp(-(z_t-c)/d));

yhat_t = a + b*g;
