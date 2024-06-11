function yhat_t = gainmodel3free(x, data)
% function yhat_t = gainmodel3free(x, data)
%
% Calculate gain model with no time course for stimulus
% with high and low gain states only
%
% Inputs:
%  x -- parameters
%  data.z_t -- output of separable kernel
%  data.C_t -- contrast of stimulus

a_L = x(1);
a_H = x(2);
b   = x(3);
c_L = x(4);
c_H = x(5);
d_L = x(6);
d_H = x(7);

z_t = data.z_t;
C_t = data.C_t;

g_L = 1./(1+exp(-(z_t-c_L)/d_L));
g_H = 1./(1+exp(-(z_t-c_H)/d_H));

yhat_t = a_L.*(C_t==0) + a_H.*(C_t==1) + b*(g_L.*(C_t==0) + g_H.*(C_t==1));
