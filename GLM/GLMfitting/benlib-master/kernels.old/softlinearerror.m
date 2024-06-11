function  [E, dE] = softlinearerror(X, fitdata)
% error and partial derivatives for soft threshold linear model
% of neuronal output nonlinearity
% [E, dE] = sigmoidSSE_partials(X, fitdata)
% X is a vector of arguments:
%   a = X(1); % minimum
%   b = X(2); % range
%   c = X(3); % offset to right
%   d = X(4); % gradient
% fitdata is a struct:
%   fitdata.y_t is observed values (vector, <t x 1>) column
%   fitdata.z_t is predicted values (vector, <t x 1>) column
%
% E is the function value (sum-of-squared-errors)
% dE is a vector of partial derivatives (by a,b,c,d of X)
%

% This has been checked with checkgrad.m:
% fitdata.y_t = rand(200,1); fitdata.z_t = rand(200,1);
% d = checkgrad('softlinearerror', rand(4,1), 1e-5, fitdata)

a = X(1); % y-offset
b = X(2); % slope
c = X(3); % x-offset
d = X(4); % sharpness of transition

y_t = fitdata.y_t;
z_t = fitdata.z_t;

% f(P,z_t)
% PREVIOUS VERSION BW:
%log_tmp = log(1+exp(z_t-c));
%fX = a + b.*log_tmp;

w = d*(z_t-c);
exp_tmp = exp(w);
log_tmp = log(1+exp_tmp);

% Replace log_tmp with numerically stable version if w>700
% (because exp(710) is Inf.
% log_tmp = log(1+exp_tmp) = log(1+exp(w))
% For large values, we are in the linear regime, so
% our numerically stable approximation is just w itself:
% could use log(realmax) instead of 700
log_tmp(w>700) = w(w>700);

fX = a + b./d.*log_tmp;

% E
residuals = fX - y_t;
E = sum(residuals.^2);

% PARTIALS
% PREVIOUS VERSION BW:
% dE = nan(3,1);
% dE(1) = sum(2*residuals);
% dE(2) = sum(2.*log_tmp.*residuals);
% dE(3) = -sum((2*b*exp(z_t).*residuals)./(exp(c)+exp(z_t)));
%
% Partial derivatives from Wolfram Alpha

dE = nan(4,1);
dE(1) = sum(2*residuals);
dE(2) = sum(2./(d^2).*log_tmp.*(d*(a-y_t)+b.*log_tmp));

% dE(3) = -sum(2*b*exp_tmp.*residuals./(exp_tmp+1));
% This a numerically stable version of the above, see:
% http://fa.bianp.net/blog/2013/numerical-optimizers-for-logistic-regression/#fn:1
% Note that exp_tmp = exp(w)
etrat = exp_tmp./(1+exp_tmp);
etrat(w>0) = 1./(1+exp(-w(w>0)));

% Equivalent code (to the above) from sigmoidSSE_partials.m
% etrat = nan(size(w));
% xnegi = (w<=0);
% xposi = (w>0);
% etrat(xnegi) = exp_tmp(xnegi)./(1+exp_tmp(xnegi));
% etrat(xposi) = 1./(1+exp(-w(xposi)));
dE(3) = -sum(2*b*residuals.*etrat);

% tmp1 = d*(c-z_t).*exp(d*z_t);
% tmp2 = exp(c*d)+exp(d*z_t);
% dE4_orig = -sum(2*b/(d^2)*(tmp1./tmp2 + log_tmp).*residuals);

% dE(4) is -sum(2*b/(d^2)*(tmp1./tmp2 + log_tmp).*residuals);
%        = -sum(2*b/(d^2)*(d*(c-z_t).*exp(d*z_t)./(exp(c*d)+exp(d*z_t)) + log_tmp).*residuals);
% If m = d*z_t, then
% dE(4) is ...exp(m)./(exp(c*d)+exp(m))...
% This is similar (but not identical) to the logistic derivative exp(x)/(1+exp(x)) which 
% we already have a numerically stable equivalent for (see etrat above)
% By multiplying top and bottom by exp(-c*d), we can rewrite this part of dE(4) as
% dE(4) = ...exp(x-c*d)/(1+exp(x-c*d))
% If we now set y = m-c*d, then we can use the same etrat trick again to get the relevant
% bit of dE(4).
x = d*z_t-c*d; % equals d*(z_t-c), but it may be clearer left this way
exp_x = exp(x);
etrat = exp_x./(1+exp_x);
etrat(x>0) = 1./(1+exp(-x(x>0)));
dE(4) = -sum(2*b/(d^2)*(d*(c-z_t).*etrat + log_tmp).*residuals);
