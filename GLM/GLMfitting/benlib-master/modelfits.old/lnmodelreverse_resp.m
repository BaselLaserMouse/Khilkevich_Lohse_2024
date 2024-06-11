function z_t = lnmodel(x, y_hat)
% function z_t= lnmodel(x, data)
% 
% Calculate sigmoid LN model
% 
% Inputs:
%  x -- parameters
%  y_hat -- output of separable kernel

data.y_hat = y_hat;

z_t = lnmodel_reverse(x, data);