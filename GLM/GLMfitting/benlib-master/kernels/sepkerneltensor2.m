function kernel = sepkerneltensor(X_fht, y_t, niter)
% function kernel = sepkerneltensor(X_fht, y_t)
%
% Compute separable kernel from tensorized stimulus
% Now returns a single constant, c, rather than
% c_f and c_h
%
% Inputs:
%  X_fht -- stimulus, freq x history x time
%  y_t -- response, 1-D time series
%
% Output:
%  kernel.k_f -- frequency kernel
%  kernel.k_h -- history kernel
%  kernel.c -- constant term

if ~exist('niter', 'var')
  niter = 15;
end

[n_f, n_h, n_t] = size(X_fht);


% subtract off means
mn = nan(n_f, n_h);
for ii = 1:n_f
	for jj = 1:n_h
		mn(ii, jj) = mean(X_fht(ii, jj, :));
		X_fht(ii, jj, :) = X_fht(ii, jj, :) - mn(ii, jj);
	end
end

y_mn = mean(y_t);
y_t = y_t - y_mn;

% estimate k_f and k_h
k_f = ones(n_f, 1);
k_h = ones(n_h, 1);

for ii = 1:niter
 yh = X_fht.*repmat(k_f, [1 n_h n_t]);
 yh = squeeze(sum(yh, 1));
 % the following is OK but seems to be slower
 % yh = squeeze(multiprod(X_fht, k_f, 1));

 k_h = lsqlin(yh', y_t);

 yh = X_fht.*repmat(k_h', [n_f 1 n_t]);
 yh = squeeze(sum(yh, 2));
 % the following is OK and same speed
 % yh = multiprod(X_fht, k_h', 2);

 k_f = lsqlin(yh', y_t);
end


%% we need to convert the kernel back into un-normalised space
% this is adapted from blasso.m -- where both mean and SD of coefficients are adjusted
% before fitting. Here, only the mean is altered.

% we have fit the equation of a line where y' = m'_i x'_i + k' (actually k' = 0)
% and y' = y-mu_y and x'_i = x_i - mu_xi
% by substitution and simplification, we can get y = m_i x_i + k
% where,
% kernel coefficients m_i = m'_i (unchanged)
% offset k = mu_y + Sum(m'_i * mu_xi)

k_fh = k_f * k_h';
kernel.c = y_mn - sum(k_fh(:).*mn(:));
kernel.k_f = k_f;
kernel.k_h = k_h;

