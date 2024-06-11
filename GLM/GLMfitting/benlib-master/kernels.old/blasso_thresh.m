function kernel = blasso_threshold(X_fht, y_t)
% use blasso_bw4 to fit kernel
% drop all coefficients whose magnitude is less than 10% of max

params = struct;
params.display_kernel = false;
params.suppress_display = true;

[n_f, n_h, n_t] = size(X_fht);

X_fit_fh_t = reshape(X_fht, [n_f*n_h], size(X_fht, 3));
[k_fh_1d, c] = blasso_bw4(X_fit_fh_t', y_t', params);

% get rid of coefficients whose magnitude is less than 10% of the maximum
mx = max(abs(k_fh_1d));
k_fh_1d(abs(k_fh_1d)<0.1*mx) = 0;

% refit overall gain and offset (this makes me uncomfortable)
y_hat = multiprod(X_fit_fh_t, k_fh_1d, 1);
coeff = regress(y_t', [ones(size(y_hat)); y_hat]');
kernel.c = coeff(1);
kernel.k_fh = reshape(k_fh_1d, n_f, n_h) * coeff(2);
