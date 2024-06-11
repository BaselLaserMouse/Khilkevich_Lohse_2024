function yhat_t = threshmodelresp(x, C_t, z_t)
% function yhat_t = threshmodelresp(x, C_t, z_t)
% 
% Calculate output of gain model
% 
% Inputs:
%  x -- parameters
%  C_t -- contrast
%  z_t -- output of separable kernel

data.C_t = C_t;
data.z_t = z_t;

yhat_t = threshmodel(x, data);