function y_hat_t = gainchangemodel(x, data)
% function y_hat_t = gainchangemodel(x, data)
%
% Calculate linear transform
%
% Inputs:
%  x -- parameters
%  data.z_t -- output of separable kernel

a = x(1); % x-offset
b = x(2); % y-offset
c = x(3); % multiplier

if isstruct(data)
  z = data.z_t;
else
  z = data;
end

z_prime = c*z + b;
y_hat_t = lnmodel(data.lnmodel.params, z_prime) + a;
