function [sp_exp, cc] = testfit2(y_t, yhat_t, sigpower)

%sp_exp = (var(y_t)-var(y_t-yhat_t))/sigpower;
% this is how Nicol does it
sp_exp = (var(y_t)-mean((y_t-yhat_t).^2))./sigpower;

cc = corrcoef(y_t, yhat_t);
cc = cc(1,2);