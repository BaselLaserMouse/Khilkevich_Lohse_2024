function y = sigmoidresp(params, x)
% function y = sigmoidresp(params, x)
% 
% Calculate sigmoid LN model
% 
% Inputs:
%  params -- parameters
%  x -- x values at which to evaluate sigmoid

a = params(1); % y-offset
b = params(2); % y-range
c = params(3); % x-location of inflexion point
d = params(4); % max slope

if isstruct(x)
  x = x.x;
end

g = 1./(1+exp(-(x-c)/d));

y = a + b*g;
