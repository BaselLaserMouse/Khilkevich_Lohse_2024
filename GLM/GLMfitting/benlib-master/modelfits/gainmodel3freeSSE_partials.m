function [E, dE] = gainmodel3freeSSE_partials(x, data)
% function y_hat_t = gainmodel3freeSSE_partials(x, data)
%
% Calculate linear transform
%
% Inputs:
%  x -- parameters
%  data.z_t -- output of separable kernel

% This has been checked with:
% fitdata.y_t = rand(200,1);
% fitdata.z_t = rand(200,1);
% fitdata.C_t = rand(200,1)>0.5;
% d = checkgrad('gainmodel3freeSSE_partials', rand(7,1), 1e-5, fitdata)

% calculate SSE
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
residuals = yhat_t - data.y_t;
E = sum(residuals.^2);


% See sigmoidSSE_partials.m for rationale
x_L = -(z_t-c_L)/d_L;
exp_x_L = exp(x_L);
etrat_L_sq = exp(-abs(x_L))./((1+exp(-abs(x_L))).^2);

x_H = -(z_t-c_H)/d_H;
exp_x_H = exp(x_H);
etrat_H_sq = exp(-abs(x_H))./((1+exp(-abs(x_H))).^2);


% PARTIALS
% dE/dP = sum(2*residuals * dfX/dP)
dE = nan(7,1);

% dfX/da = 1
dE(1) = sum(2 .* residuals .* (C_t==0));

% dfX/da = 1
dE(2) = sum(2 .* residuals .* (C_t==1));

% dfX/db = 1./(1+exp_x)
dE(3) = sum(2 .* residuals ./ (1+(exp_x_L.*(C_t==0))+(exp_x_H.*(C_t==1))));

% dfX/dc = -b*exp_x /[d*(1+exp_x)^2]
%        = -b /[d*(1+exp_x) * etrat]
dE(4) = sum(2 .* residuals .* -b .* (C_t==0) .* etrat_L_sq ./ d_L);

% dfX/dc = -b*exp_x /[d*(1+exp_x)^2]
%        = -b /[d*(1+exp_x)] * etrat
dE(5) = sum(2 .* residuals .* -b .* (C_t==1) .* etrat_H_sq ./ d_H);;

% dfX/dd = b(-z_t+c)*exp_x / [d*(1+exp_x)]^2
%        = b(-z_t+c)/[d^2*(1+exp_x)] * etrat
dE(6) = sum(2 .* residuals .* b .* (C_t==0) .* (-z_t+c_L) .* etrat_L_sq ./ d_L.^2);

% dfX/dd = b(-z_t+c)*exp_x / [d*(1+exp_x)]^2
%        = b(-z_t+c)/[d^2*(1+exp_x)] * etrat
dE(7) = sum(2 .* residuals .* b .* (C_t==1) .* (-z_t+c_H) .* etrat_H_sq ./ d_H.^2);
