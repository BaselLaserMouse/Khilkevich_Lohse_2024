function model = gain_model_3free(z_t, C_t, y_dt, ln_model, fit_idx, pred_idx)

y_t = mean(y_dt, 1);
model = getgainmodel3free(z_t(fit_idx), C_t(fit_idx), y_t(fit_idx), ln_model);

model = rmfield(model, 'fit');
model = rmfield(model, 'restarts');

tmpdata.z_t = z_t;
tmpdata.C_t = C_t;
model.y_hat = gainmodel3free(model.params, tmpdata);

% evaluate it on fit data
[model.cc_norm_fit, model.cc_abs_fit, model.cc_max_fit] = ...
    calc_CCnorm(y_dt(:,fit_idx), model.y_hat(fit_idx));

% evaluate it on prediction data
[model.cc_norm_pred, model.cc_abs_pred, model.cc_max_pred] = ...
    calc_CCnorm(y_dt(:,pred_idx), model.y_hat(pred_idx));

