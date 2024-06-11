function nrf_model = nrf(X_fht, y_dt, fit_idx, pred_idx, n_hidden)

if ~exist('n_hidden', 'var')
    n_hidden = 10;
end

y_t = mean(y_dt, 1);

n_fit = floor(0.9*length(fit_idx));
val_idx = fit_idx(n_fit+1:end);
newfit_idx = fit_idx(1:n_fit);
assert(all([newfit_idx val_idx]==fit_idx));
fit_idx = newfit_idx;

lambdas = logspace(-8, -3, 6);

restarts = {};

for ll = 1:length(lambdas)
    lambda = lambdas(ll);
    restart = struct;
    restart.lambda = lambda;

    [restart.theta, restart.train_err] = fit_NRF_model(X_fht(:,:,fit_idx), y_t(fit_idx), 20, 'abs', lambda, {n_hidden 1});
    restart.y_hat = NRF_model(X_fht, restart.theta);

    % evaluate it on validation data
    [restart.cc_norm, restart.cc_abs, restart.cc_max] = ...
        calc_CCnorm(y_dt(:,val_idx), restart.y_hat(val_idx));

    restarts{ll} = restart;

end

restarts = [restarts{:}];

cc_abs = [restarts(:).cc_abs];
best_restart = find(cc_abs==max(cc_abs));
if isempty(best_restart)
    best_restart = 1;
end

nrf_model = struct;
nrf_model.theta = restarts(best_restart).theta;
nrf_model.lambda = restarts(best_restart).lambda;
nrf_model.y_hat = restarts(best_restart).y_hat;
r = rmfield(restarts, 'y_hat');
nrf_model.restarts = r;

% evaluate it on fit data
[nrf_model.cc_norm_fit, nrf_model.cc_abs_fit, nrf_model.cc_max_fit] = ...
    calc_CCnorm(y_dt(:,fit_idx), nrf_model.y_hat(fit_idx));

% evaluate it on prediction data
[nrf_model.cc_norm_pred, nrf_model.cc_abs_pred, nrf_model.cc_max_pred] = ...
    calc_CCnorm(y_dt(:,pred_idx), nrf_model.y_hat(pred_idx));
