function kernel = rank_n_kernel(X_fht, y_dt, fit_idx, pred_idx)

sepkernels = {};

rank = 0;
best_cc_abs = -inf;
y_t = mean(y_dt, 1);
y_hat = zeros(1, size(y_dt, 2));
residuals = mean(y_dt, 1);
k_insep.c = 0;
k_insep.k_fh = 0;
done = false;

n_fit = floor(0.9*length(fit_idx));
val_idx = fit_idx(n_fit+1:end);
newfit_idx = fit_idx(1:n_fit);
assert(all([newfit_idx val_idx]==fit_idx));

while done == false
    rank = rank + 1;

    k_sep = sepkerneltensor2(X_fht(:,:,newfit_idx), residuals(newfit_idx));
    k_sep.y_hat = y_hat + sepconv(X_fht, k_sep);

    % evaluate it on validation data
    [val_cc_norm, val_cc_abs, val_cc_max] = ...
        calc_CCnorm(y_dt(:,val_idx), k_sep.y_hat(val_idx));

    % % evaluate it on prediction data
    % [k_sep.cc_norm, k_sep.cc_abs, k_sep.cc_max] = ...
    %     calc_CCnorm(y_dt(:,pred_idx), k_sep.y_hat(pred_idx));

    if val_cc_abs > best_cc_abs
        sepkernels{rank} = k_sep;
        best_cc_abs = val_cc_abs;
        y_hat = k_sep.y_hat;
        residuals = y_t - y_hat;

        % accumulate inseparable equivalent kernel
        k_insep.c = k_insep.c + k_sep.c;
        k_insep.k_fh = k_insep.k_fh + k_sep.k_f*transpose(k_sep.k_h);

    else
        done = true;
    end

end
sepkernels = [sepkernels{:}];

% remove extra y_hats coz they're too darn big
if length(sepkernels)>0
    sepkernels = rmfield(sepkernels, 'y_hat');
end

k_insep.y_hat = kernelconv(X_fht, k_insep);

% evaluate it on fit data (inc validation)
[k_insep.cc_norm_fit, k_insep.cc_abs_fit, k_insep.cc_max_fit] = ...
    calc_CCnorm(y_dt(:,fit_idx), k_insep.y_hat(fit_idx));

% evaluate it on prediction data
[k_insep.cc_norm_pred, k_insep.cc_abs_pred, k_insep.cc_max_pred] = ...
    calc_CCnorm(y_dt(:,pred_idx), k_insep.y_hat(pred_idx));

% try
%     assert(max(abs(sepkernels(end).y_hat - k_insep.y_hat)) < 200*eps);
% catch
%     fprintf('Inseparable kernel predictions dont match separable kernels');
%     keyboard
% end

kernel = k_insep;
kernel.rank = length(sepkernels);
kernel.convfunc = @kernelconv;
kernel.sepkernels = sepkernels;
