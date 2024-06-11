function yhat_t = threshmodel(x, data)
% function yhat_t = threshmodel(x, data)
% 
% Calculate gain model with no time course for stimuls
% with high and low gain states only
% 
% Inputs:
%  x -- parameters
%  data.z_t -- output of separable kernel
%  data.C_t -- contrast of stimulus

a = x(1);
b = x(2);
c_L = x(3);
c_H = x(4);
d = x(5);

z_t = data.z_t;
C_t = data.C_t;

g_L = 1./(1+exp(-(z_t-c_L)/d));
g_H = 1./(1+exp(-(z_t-c_H)/d)); 

yhat_t = a + b*(g_L.*(C_t==0) + g_H.*(C_t==1));
