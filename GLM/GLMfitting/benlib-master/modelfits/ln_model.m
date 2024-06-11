function model = ln_model(y_dt, y_hat_lin, fit_idx, pred_idx)

y_t = mean(y_dt, 1);

model = getlnmodel3(y_hat_lin(fit_idx), y_t(fit_idx));

model.y_hat = lnmodel(model.params, y_hat_lin);
model = rmfield(model, 'restarts');
model = rmfield(model, 'fit');

% evaluate it on fit data
[model.cc_norm_fit, model.cc_abs_fit, model.cc_max_fit] = ...
    calc_CCnorm(y_dt(:,fit_idx), model.y_hat(fit_idx));

% evaluate it on prediction data
[model.cc_norm_pred, model.cc_abs_pred, model.cc_max_pred] = ...
    calc_CCnorm(y_dt(:,pred_idx), model.y_hat(pred_idx));


