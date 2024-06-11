function  [E, dE] = sigmoidSSE_partials(X, fitdata)
% [E, dE] = sigmoidSSE_partials(X, fitdata)
% X is a vector of arguments:
%   a = X(1); % minimum
%   b = X(2); % range
%   c = X(3); % offset to right
%   d = X(4); % gradient
% fitdata is a struct:
%   fitdata.y is observed values (vector, <t x 1>) column
%   fitdata.x is predicted values (vector, <t x 1>) column
%
% E is the function value (sum-of-squared-errors)
% dE is a vector of partial derivatives (by a,b,c,d of X)
%
% fX relates to the sigmoid function:
% fX = a + b./(1+exp(-(z_t-c)/d));
% fX = f(X,z_t)
% E = sum[  (fX - y)^2  ] over all t
% dE/dX = sum[ 2(fX - y) * dfX/dX  ] %we lose -y in the partials

% This has been checked with checkgrad.m:
% fitdata.y = rand(200,1); fitdata.x = rand(200,1);
% d = checkgrad('sigmoidSSE_partials2', rand(4,1), 1e-5, fitdata)
%
% d = checkgrad('sigmoidSSE_partials2', X, 1e-5, fitdata)
%
% This function does not like small values for d - it gives inf values
% which in turn give NaN values for dE/dc and dE/dd

a = X(1); % y-offset
b = X(2); % y-range
c = X(3); % x-location of inflexion point
d = X(4); % gradient

y = fitdata.y;
x = fitdata.x;

% f(P,z_t)
fX = 1./(1+exp(-(x-c)/d));
fX = a+b*fX;

% E
residuals = fX - y;
E = sum(residuals.^2);

% Making exp(-(z_t-c)/d) (recurs in partials)
w = -(x-c)/d;
exp_w = exp(w);

% make stable for high exponentials
% mm = -max(w);
% exp_mm = exp(mm);
% exp_wmm = exp(w+mm);
%
% etrat = exp_wmm./(exp_mm+exp_wmm);
% % above line is a numerically stable equivalent of etrat = exp(x)./(1+exp(x));
% % http://neuro.imm.dtu.dk/software/lyngby/doc/lyngby.latex2html/node106.html
% % sometimes exp_w gives inf results( ~exp(710))
% % this is a problem for inf/inf so we use numerically stable version above
%new numerically stable version
%see http://fa.bianp.net/blog/2013/numerical-optimizers-for-logistic-regression/#fn:1
% etrat = nan(size(w));
% xnegi = (w<=0);
% xposi = (w>0);
% etrat(xnegi) = exp_w(xnegi)./(1+exp_w(xnegi));
% etrat(xposi) = 1./(1+exp(-x(xposi)));
etrat = exp_w./(1+exp_w);
etrat(w>0) = 1./(1+exp(-w(w>0)));

% PARTIALS
% dE/dP = sum(2*residuals * dfX/dP)
dE = nan(4,1);

% dfX/da = 1
dE(1) = sum(2*residuals);

% dfX/db = 1./(1+exp_w)
dE(2) = sum(2*residuals ./ (1+exp_w));

% dfX/dc = -b*exp_w /[d*(1+exp_w)^2]
%        = -b /[d*(1+exp_w)] * etrat
dE(3) = sum(2*residuals * -b ./ (d*(1+exp_w)) .* etrat);

% dfX/dd = b(-z_t+c)*exp_w / [d*(1+exp_w)]^2
%        = b(-z_t+c)/[d^2*(1+exp_w)] * etrat
dE(4) = sum(2*residuals *b.*(-x+c)./(d^2*(1+exp_w)) .* etrat);