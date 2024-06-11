function model = gain_model_linmap(z_t, ln_model_low_contrast, ln_model_high_contrast, low_contrast_fit_idx)

% z_t: output of kernel (i.e. the x-axis on a graph of the output nonlinearity)
% ln_model_low_contrast, ln_model_high_contrast: ln models for low and high contrast
% low_contrast_fit_idx, high_contrast_fit_idx: fit_idx for low and high contrast

% make a vector spanning the x-range for low contrast data
z_lo = linspace(min(z_t(low_contrast_fit_idx)), ...
                max(z_t(low_contrast_fit_idx)), 50);

% get responses of low contrast LN model to z_lo
y_hat_lo = lnmodel(ln_model_low_contrast.params, z_lo);

% get linear transform that maps high contrast LN model to the above data
model = getgainmodellinmap(z_lo, y_hat_lo, ln_model_high_contrast);

model = rmfield(model, 'restarts');
model = rmfield(model, 'fit');
