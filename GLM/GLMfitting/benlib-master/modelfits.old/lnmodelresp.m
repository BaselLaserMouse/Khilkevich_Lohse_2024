function yhat_t = lnmodel(x, z_t)
% function yhat_t = lnmodel(x, z_t)
% 
% Calculate sigmoid LN model
% 
% Inputs:
%  x -- parameters
%  z_t -- output of separable kernel

data.z_t = z_t;

yhat_t = lnmodel(x, data);
