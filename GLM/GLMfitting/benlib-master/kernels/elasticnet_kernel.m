function kernel = elasticnet_kernel(X_fht, y_dt, fit_idx, pred_idx)

y_t = mean(y_dt, 1);
kernel = elnet_fht(X_fht(:,:,fit_idx), y_t(fit_idx));
kernel.convfunc = @kernelconv;
kernel.y_hat = feval(kernel.convfunc, X_fht, kernel);

% evaluate it on fit data
[kernel.cc_norm_fit, kernel.cc_abs_fit, kernel.cc_max_fit] = ...
    calc_CCnorm(y_dt(:,fit_idx), kernel.y_hat(fit_idx));

% evaluate it on prediction data
[kernel.cc_norm_pred, kernel.cc_abs_pred, kernel.cc_max_pred] = ...
    calc_CCnorm(y_dt(:,pred_idx), kernel.y_hat(pred_idx));
