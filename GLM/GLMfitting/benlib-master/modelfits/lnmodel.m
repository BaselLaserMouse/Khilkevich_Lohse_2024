function yhat_t = lnmodel(x, data)
% function yhat_t = lnmodel(x, data)
% 
% Calculate sigmoid LN model
% 
% Inputs:
%  x -- parameters
%  data.z_t -- output of separable kernel

a = x(1); % y-offset
b = x(2); % y-range
c = x(3); % x-location of inflexion point
d = x(4); % max slope

if isstruct(data)
  z_t = data.z_t;
else
  z_t = data;
end

g = 1./(1+exp(-(z_t-c)/d));

yhat_t = a + b*g;
