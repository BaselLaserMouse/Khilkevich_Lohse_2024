function z_t = lnmodel_reverse(x, data)
% function z_t = lnmodel(x, data)
% 
% Calculate sigmoid LN model
% 
% Inputs:
%  x -- parameters
%  data.z_t -- output of separable kernel

a = x(1);
b = x(2);
c = x(3);
d = x(4);

y_hat = data.y_hat;

z_t = c - d * log(b./(y_hat-a)-1);
