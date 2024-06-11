function yhat_t = gtcmodelresp(x, dt, C_ht, z_t)
% function yhat_t = gtcmodelresp(x, C_ht, z_t)
% 
% Calculate output of gtc model
% 
% Inputs:
%  x -- parameters
%  C_ht -- contrast
%  z_t -- output of separable kernel

data.dt = dt;
data.C_ht = C_ht;
data.z_t = z_t;

yhat_t = gtcmodel(x, data);