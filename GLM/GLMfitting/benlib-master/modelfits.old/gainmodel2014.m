function yhat_t = gainmodel2014(x, data)
% function yhat_t = gainmodel2014(x, data)
%
% Calculate gain model -- sigmoid where a, b are fixed, but c, d can vary
% with contrast
%
% Inputs:
%  x -- parameters
%  data.z_t -- output of separable kernel
%  data.C_t -- contrast condition (0,1)

a = x(1); % y-offset
b = x(2); % y-range
c = x(3); % x-location of inflexion point
d = x(4); % max slope
e = x(5); % change in c with contrast condition
f = x(6); % change in d with contrast condition

z_t = data.z_t;
C_t = data.C_t;

cp = c+C_t*e;
dp = d+C_t*f;

g = 1./(1+exp(-(z_t-cp)./dp));

yhat_t = a + b*g;

% a + b./(1+exp(-(z_t-(c+C*e))/d+C*f))
