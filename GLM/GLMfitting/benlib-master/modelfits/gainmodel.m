function yhat_t = gainmodel(x, data)
% function yhat_t = gainmodel(x, data)
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
d_L = x(5);
d_H = x(6);

z_t = data.z_t;
C_t = data.C_t;

g_L = 1./(1+exp(-(z_t-c_L)/d_L));
g_H = 1./(1+exp(-(z_t-c_H)/d_H)); 

yhat_t = a + b*(g_L.*(C_t==0) + g_H.*(C_t==1));
