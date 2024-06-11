function y_t = multisepconv(X_fht, kernels)

if isstruct(kernels) && isfield(kernels, 'kernels')
  kernels = kernels.kernels;
end

if iscell(kernels)
  kernels = [kernels{:}];
end

y_t = 0;

for kk = 1:length(kernels)
  y_t = y_t + sepconv(X_fht, kernels(kk));
end