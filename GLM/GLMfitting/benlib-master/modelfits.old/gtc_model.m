function model = gtc_model(dt, z_t, C_ht, y_dt, gain_model, fit_idx, pred_idx)

y_t = mean(y_dt, 1);
model = getgtcmodel(dt, z_t(fit_idx), C_ht(:, fit_idx), y_t(fit_idx), gain_model);

model = rmfield(model, 'fit');
model = rmfield(model, 'restarts');

model.y_hat = gtcmodelresp(model.params, dt, C_ht, z_t);


% evaluate it on fit data
[model.cc_norm_fit, model.cc_abs_fit, model.cc_max_fit] = ...
    calc_CCnorm(y_dt(:,fit_idx), model.y_hat(fit_idx));

% evaluate it on prediction data
[model.cc_norm_pred, model.cc_abs_pred, model.cc_max_pred] = ...
    calc_CCnorm(y_dt(:,pred_idx), model.y_hat(pred_idx));

