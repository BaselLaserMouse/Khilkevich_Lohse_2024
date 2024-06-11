function kernel = blasso_fht(X_fht, y_t, vararg)

if exist('vararg', 'var') && isstruct(vararg)
  params = vararg;
else
  params = struct;
  params.display_kernel = false;
  params.suppress_display = true;
  if exist('vararg', 'var') && isscalar(vararg)
  	params.epsilon = vararg;
  end
end

[n_f, n_h, n_t] = size(X_fht);

X_fit_fh_t = reshape(X_fht, [n_f*n_h], size(X_fht, 3));
[k_fh_1d, c] = blasso_bw4(X_fit_fh_t', y_t', params);

y_hat = multiprod(X_fit_fh_t, k_fh_1d, 1);
coeff = regress(y_t', [ones(size(y_hat)); y_hat]');

% refit overall gain and offset (this makes me uncomfortable)
kernel.c = coeff(1);
kernel.k_fh = reshape(k_fh_1d, n_f, n_h) * coeff(2);
