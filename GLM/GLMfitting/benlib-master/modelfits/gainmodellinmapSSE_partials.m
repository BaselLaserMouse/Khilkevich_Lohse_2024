function [E, dE] = gainchangemodel_partials(x, data)
% function y_hat_t = gainchangemodel_partials(x, data)
%
% Calculate linear transform
%
% Inputs:
%  x -- parameters
%  data.z_t -- output of separable kernel

% This has been checked with:
% fitdata.y_t = rand(200,1);
% fitdata.z_t = rand(200,1);
% fitdata.lnmodel.params = rand(4,1);
% d = checkgrad('gainchangemodel_partials', rand(3,1), 1e-5, fitdata)

% calculate SSE
fX = gainmodellinmap(x, data);
residuals = fX - data.y_t;
E = sum(residuals.^2);

A = x(1); % x-offset
B = x(2); % y-offset
C = x(3); % multiplier


% parameters of LN model
a = data.lnmodel.params(1); % y-offset
b = data.lnmodel.params(2); % y-range
c = data.lnmodel.params(3); % x-location of inflexion point
d = data.lnmodel.params(4); % max slope

% Making exp((-C.*data.z_t - B + c)./d) (recurs in partials)
k = (-C.*data.z_t - B + c)./d;
exp_k = exp(k);

% numerically stable version of exp(k)/(1+exp(k)).^2
etrat_sq = exp(-abs(k))./((1+exp(-abs(k))).^2);
%etrat_sq = exp(k) ./ (exp(k)+1).^2;

% PARTIALS
% dE/dP = sum(2*residuals * dfX/dP)
dE = nan(3,1);

% dfX/dA = 1
dE(1) = sum(2*residuals);

% dfX/dB = (C ./d) * 1./(1+exp_x).^2
dE(2) = sum(2*residuals .* etrat_sq .* b ./ d);

% dfX/dC = x .* (C ./d) * 1./(1+exp_x).^2
dE(3) = sum(2*residuals .* etrat_sq .* data.z_t .* b ./ d);
