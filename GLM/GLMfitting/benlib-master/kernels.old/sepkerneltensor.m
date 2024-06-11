function kernel = sepkerneltensor(X_fht, y_t)
% function kernel = sepkerneltensor(X_fht, y_t)
% 
% Compute separable kernel from tensorized stimulus
%
% Inputs:
%  X_fht -- stimulus, freq x history x time
%  y_t -- response, 1-D time series
%  n_h -- number of history steps desired
% 
% Output:
%  kernel.k_f -- frequency kernel
%  kernel.k_h -- history kernel
%  kernel.c_f -- constant term for freq
%  kernel.c_h -- constant term for history

fprintf('sepkerneltensor has been superceded by sepkerneltensor2.\n');

if ~exist('niter', 'var')
  niter = 15;
end

% insert constant so we can estimate constant terms
X_fht(end+1, end+1, :) = 1;

[n_f, n_h, n_t] = size(X_fht);

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

% separate out constant terms
kernel.c_f = k_f(end);
kernel.k_f = k_f(1:end-1);
kernel.c_h = k_h(end);
kernel.k_h = k_h(1:end-1);

