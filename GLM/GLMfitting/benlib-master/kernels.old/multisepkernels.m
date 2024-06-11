function kernel = multisepkernels(X_fht, y_t, n_k)

y_resid = y_t;

kernels = {};
kernel.k_fh = 0;
for kk = 1:n_k
  kernels{kk} = sepkerneltensor2(X_fht, y_resid);
  kernels{kk}.k_fh = kernels{kk}.k_f * kernels{kk}.k_h';
  y_hat = multisepconv(X_fht, kernels);
  y_resid = y_t - y_hat;
  kernel.k_fh = kernel.k_fh + kernels{kk}.k_fh;
end
kernels = [kernels{:}];

kernel.kernels = kernels;

