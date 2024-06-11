function [fit_sp_exp, pred_sp_exp] = ...
  get_sp_exp(yhat_t, y_tr, fitidx, predidx)
% function [fit_sp_exp, pred_sp_exp] = ...
%  get_sp_exp(yhat_t, y_tr, fitidx, predidx)
%
% Calculate signal power explaind of fit and prediction data sets given:
% 
% Inputs:
%  yhat_t -- predicted response vector
%  y_tr -- actual response matrix
%  fitidx -- indices of fit data
%  predidx -- indices of prediction data
% 
% Output:
%  fit_sp_exp -- signal power explained for fit set
%  pred_sp_exp -- signal power explained for pred set
%
% I'm not sure this function with its weird inputs is a good idea

n_r = size(y_tr, 2);
yhat_tr = repmat(yhat_t, n_r);

% var(pred.y_t)-var(pred.y_t-pred_yhat_t))/pred.sigpower
fit_sp = sahani_quick(y_tr(fitidx,:)');
fit_sp_exp = (var(ravel(y_tr(fitidx,:))) - ...
            var(ravel(y_tr(fitidx,:))-ravel(yhat_tr(fitidx,:)))) / fit_sp;

pred_sp = sahani_quick(y_tr(predidx,:)');
pred_sp_exp = (var(ravel(y_tr(predidx,:))) - ...
            var(ravel(y_tr(predidx,:))-ravel(yhat_tr(predidx,:)))) / pred_sp;
