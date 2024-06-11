function [kernel, allKernels, res] = elnet_fht(X_fht, y_t, varargin)
% function [kernel, res] = elnet_fht(X_fht, y_t, params)
%
% Elastic net kernel estimation using glmnet
% X_fht -- fxhxt "tensorised" stimulus
% y_t   -- 1xt response vector
% varargin -- 'lasso' or 'ridge'
%             an options structure as produced by glmnetSet except
% 					alpha may be a vector, o
% 			  a list of indices to use for cross-validation

% process parameters
while ~isempty(varargin)
	v = varargin{1};
	if isstr(v)
		if strcmp(v, 'lasso')
		  alphas = 1;
		elseif strcmp(v, 'ridge')
		  alphas = 0.01; % minimum "reliable" value for glmnet
		end

	elseif isnumeric(v)
		val_idx = v;

	elseif isstruct(v)
		options = v;
	else
		error('unreocognised parameter');
	end
	varargin = varargin(2:end);
end

if ~exist('options', 'var')
  options = glmnetSet;
  if isfield(options, 'alphas')
  	alphas = options.alphas;
  end
end

if ~exist('alphas', 'var')
	alphas = logspace(log10(.01), 0, 5);
end

% get data into format expected by glmnet.m
[n_f, n_h, n_t] = size(X_fht);
X_t_fh = reshape(X_fht, n_f*n_h, n_t)';
y_t = y_t(:);

% get 10% of data for choosing hyperparameters (lambda, alpha)
if ~exist('val_idx', 'var')
    fprintf('Choosing a random subset for cross-validation.\n');
    fprintf('If this is not what you want, provide an array of validation indices.\n');
	val_prop = 0.1;
	n_val = ceil(val_prop*n_t);
	r = randperm(n_t);
	val_idx = r(1:n_val);
end

fit_idx = setdiff(1:n_t, val_idx);

X_fit = X_t_fh(fit_idx, :);
y_fit = y_t(fit_idx);

X_val = X_t_fh(val_idx, :);
y_val = y_t(val_idx);

% get kernels for a range of lambdas and alphas
result = {};
n_alphas = length(alphas);
fprintf('Getting kernels for %d alpha%s', n_alphas, repmat('s',(n_alphas>1)));
for alphaIdx = 1:n_alphas
  fprintf('.');
  options.alpha = alphas(alphaIdx);
  result{alphaIdx} = glmnet(X_fit, y_fit, 'gaussian', options);
  result{alphaIdx}.alpha = ones(size(result{alphaIdx}.lambda)) * options.alpha;
end
result = [result{:}];
fprintf('done\n');

% concatenate results
res.alpha = cat(1,result(:).alpha);
res.lambda = cat(1,result(:).lambda);
res.a0 = cat(1,result(:).a0);
res.beta = cat(2,result(:).beta);

% choose lambda and alpha based on validation set
y_hat = repmat(res.a0', [length(y_val) 1]) + X_val*res.beta;
err = y_hat - repmat(y_val, [1 size(y_hat, 2)]);
mse = sum(err.^2)/size(y_hat,1);
f = find(mse==min(mse),1);
res.mse = mse;
res.best_mse = f;
res.raw_results = result;

% return selected kernel
kernels{1}.c = res.a0(f);
kernels{1}.k_fh = reshape(res.beta(:, f), n_f, n_h);
kernels{1}.alpha = res.alpha(f);
kernels{1}.lambda = res.lambda(f);
kernels{1}.info = 'fit set only';

% refit kernel using the final lambda and alpha based on the whole data set
fprintf('Refitting gain and intercept...');
beta = res.beta(:, f);
y_hat = X_t_fh*beta;
coeff = regress(y_t, [ones(size(y_hat)) y_hat]);
kernels{2}.c = coeff(1);
kernels{2}.k_fh = reshape(res.beta(:, f), n_f, n_h)*coeff(2);
kernels{2}.alpha = res.alpha(f);
kernels{2}.lambda = res.lambda(f);
kernels{2}.info = 'gain and intercept refit on whole set';
fprintf('done\n');

% refit kernel using selected alpha/lambda, using whole data set
fprintf('Refitting kernel on whole dataset...');
options.alpha = res.alpha(f);
options.lambda = res.lambda(f);
refit = glmnet(X_t_fh, y_t, 'gaussian', options);
kernels{3}.c = refit.a0;
kernels{3}.k_fh = reshape(refit.beta, n_f, n_h);
kernels{3}.alpha = res.alpha(f);
kernels{3}.lambda = res.lambda(f);
kernels{3}.info = 'refit on whole set';
fprintf('done\n');

allKernels = [kernels{:}];
kernel = allKernels(3); % use the refit one

% % compare refit kernel with best previous kernel, based on MSE over
% % over whole data set
% a0 = [kernel(:).c]';
% beta = cat(3,kernel(:).k_fh);
% beta = reshape(beta, n_f*n_h, length(kernel));
% y_hat = repmat(a0', [length(y_t) 1]) + X_t_fh*beta;
% err = y_hat - repmat(y_t, [1 size(y_hat, 2)]);
% mse = sum(err.^2)/size(y_hat,1);

