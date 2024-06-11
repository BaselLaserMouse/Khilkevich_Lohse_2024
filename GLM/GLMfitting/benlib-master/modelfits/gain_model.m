function model = gain_model(z_t, C_t, y_dt, ln_model, fit_idx, pred_idx)
% Fit a "gain model" which is an LN sigmoid model where the parameters
% c and d have different values for high and low contrast data.

y_t = mean(y_dt, 1);
model = getgainmodel2(z_t(fit_idx), C_t(fit_idx), y_t(fit_idx), ln_model);

model = rmfield(model, 'fit');
model = rmfield(model, 'restarts');

tmpdata.C_t = C_t;
tmpdata.z_t = z_t;

model.y_hat = gainmodel(model.params, tmpdata);


% evaluate it on fit data
[model.cc_norm_fit, model.cc_abs_fit, model.cc_max_fit] = ...
    calc_CCnorm(y_dt(:,fit_idx), model.y_hat(fit_idx));

% evaluate it on prediction data
[model.cc_norm_pred, model.cc_abs_pred, model.cc_max_pred] = ...
    calc_CCnorm(y_dt(:,pred_idx), model.y_hat(pred_idx));

