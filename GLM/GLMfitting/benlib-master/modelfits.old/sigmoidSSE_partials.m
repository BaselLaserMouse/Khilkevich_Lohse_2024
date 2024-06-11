function  [E, dE] = sigmoidSSE_partials(X, fitdata)
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
% fX relates to the sigmoid function:
% fX = a + b./(1+exp(-(z_t-c)/d));
% fX = f(X,z_t)
% E = sum[  (fX - y_t)^2  ] over all t
% dE/dX = sum[ 2(fX - y_t) * dfX/dX  ] %we lose -y_t in the partials

% This has been checked with checkgrad.m:
% fitdata.y_t = rand(200,1); fitdata.z_t = rand(200,1);
% d = checkgrad('sigmoidSSE_partials', rand(4,1), 1e-5, fitdata)
%
% d = checkgrad('sigmoidSSE_partials', X, 1e-5, fitdata)
%
% This function does not like small values for d - it gives inf values
% which in turn give NaN values for dE/dc and dE/dd

a = X(1); % y-offset
b = X(2); % y-range
c = X(3); % x-location of inflexion point
d = X(4); % gradient

y_t = fitdata.y_t;
z_t = fitdata.z_t;

% f(P,z_t)
fX = 1./(1+exp(-(z_t-c)/d));
fX = a+b*fX;

% E
residuals = fX - y_t;
E = sum(residuals.^2);

% Making exp(-(z_t-c)/d) (recurs in partials)
x = -(z_t-c)/d;
exp_x = exp(x);

% make stable for high exponentials
% mm = -max(x);
% exp_mm = exp(mm);
% exp_xmm = exp(x+mm);
%
% etrat = exp_xmm./(exp_mm+exp_xmm);
% % above line is a numerically stable equivalent of etrat = exp(x)./(1+exp(x));
% % http://neuro.imm.dtu.dk/software/lyngby/doc/lyngby.latex2html/node106.html
% % sometimes exp_x gives inf results( ~exp(710))
% % this is a problem for inf/inf so we use numerically stable version above
%new numerically stable version
%see http://fa.bianp.net/blog/2013/numerical-optimizers-for-logistic-regression/#fn:1
etrat = nan(size(x));
xnegi = (x<=0);
xposi = (x>0);
etrat(xnegi) = exp_x(xnegi)./(1+exp_x(xnegi));
etrat(xposi) = 1./(1+exp(-x(xposi)));



% PARTIALS
% dE/dP = sum(2*residuals * dfX/dP)
dE = nan(4,1);

% dfX/da = 1
dE(1) = sum(2*residuals);

% dfX/db = 1./(1+exp_x)
dE(2) = sum(2*residuals ./ (1+exp_x));

% dfX/dc = -b*exp_x /[d*(1+exp_x)^2]
%        = -b /[d*(1+exp_x)] * etrat
dE(3) = sum(2*residuals * -b ./ (d*(1+exp_x)) .* etrat);

% dfX/dd = b(-z_t+c)*exp_x / [d*(1+exp_x)]^2
%        = b(-z_t+c)/[d^2*(1+exp_x)] * etrat
dE(4) = sum(2*residuals *b.*(-z_t+c)./(d^2*(1+exp_x)) .* etrat);
