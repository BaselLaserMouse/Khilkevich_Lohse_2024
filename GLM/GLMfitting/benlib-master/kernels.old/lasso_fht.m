function [kernel, allKernels, lassoStats] = lasso_fht(X_fht, y_t, varargin)
% function [kernel, allKernels, lassoStats] = lasso_fht(X_fht, y_t, varargin)
%
% Attempt to use matlab's lasso.m to do lasso regression
% Superceded by elnet_fht(..., 'lasso') which uses the much
% faster glmnet

if isempty(varargin)
	varargin = {'NumLambda', 20, 'LambdaRatio', 0.4};
end

% get data into format expected by lasso.m
[n_f, n_h, n_t] = size(X_fht);
X_t_fh = reshape(X_fht, n_f*n_h, n_t)';
y_t = y_t';

% get 10% of data for choosing hyperparameter (lambda)
val_prop = 0.1;
n_fit = ceil((1-0.1)*n_t);
r = randperm(n_t);
X_fit = X_t_fh(r(1:n_fit), :);
y_fit = y_t(r(1:n_fit));

X_val = X_t_fh(r(n_fit+1:end), :);
y_val = y_t(r(n_fit+1:end));

% estimate kernel for a range of lambda values
[allKernels, lassoStats] = lasso(X_fit, y_fit, varargin{:});
c = lassoStats.Intercept;

% test the lambda values on the validation set and choose the best
n_kernels = size(allKernels, 2);
y_val_hat = repmat(c,[size(y_val,1) 1]) + X_val*allKernels;
err = y_val_hat - repmat(y_val, [1 n_kernels]);
mse = mean(err.^2);

best = find(mse==min(mse), 1);

if best==1
	fprintf('Using smallest lambda value -- should increase range\n');
elseif best>=(n_kernels-1)
		fprintf('Using largest or second-largest lambda value -- should increase range\n');
end

kernel.c = c(best);
kernel.k_fh = reshape(allKernels(:, best), n_f, n_h);
