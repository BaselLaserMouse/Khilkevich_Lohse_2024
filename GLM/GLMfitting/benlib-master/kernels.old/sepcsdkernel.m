function kernel = sepcsdkernel(X_fht, y_dt, niter)
% function kernel = sepcsdkernel(X_fht, y_dt, niter)
% 
% Compute separable CSD kernel (one freq profile per depth plus
% one inseparable history x depth kernel)
%
% Inputs:
%  X_fht -- tensorized stimulus, freq x history x time
%  y_dt -- CSD, depth x time
%  niter -- number of iterations to run for
% 
% Output:
%  kernel.k_f -- frequency kernel
%  kernel.k_hd -- history x depth kernel kernel
%  kernel.c_f -- constant term for freq
%  kernel.c_d -- constant term for depth

  if ~exist('niter', 'var')
    niter = 15;
  end

  X_fht(end+1, end+1, :) = 1;

  fprintf('Calculating kernel');  
  [n_f, n_h, n_t] = size(X_fht);

  n_d = size(y_dt, 1);
  n_hd = n_h * n_d;

  k_f = ones(n_f, 1);
  k_hd = ones(n_h, n_d);
  
  y_td_unwrap = y_dt(:);

  for ii = 1:niter
    fprintf('.');

    % multiply by history/depth kernel and sum over history
    a_fdt = multiprod(X_fht, k_hd);
    
    % optimise k_f
    a_td_f = reshape(a_fdt, [n_f n_d*n_t])';
    k_f = a_td_f\y_td_unwrap;
    
    % multiply by frequency kernel and sum over frequency
    b_ht = squeeze(multiprod(X_fht, k_f,1));
  
    % optimise the history kernels for each depth separately
    for jj = 1:n_d
      y_t_jj = y_dt(jj,:);
      k_hd(:,jj) = b_ht'\y_t_jj';
    end

  end

  % separate out constant terms
  kernel.c_f = k_f(end);
  kernel.k_f = k_f(1:end-1);

  kernel.c_d = k_hd(end, :);
  kernel.k_hd = k_hd(1:end-1, :);

  % flip kernel if necessary so largest peak is +ve
  idx = find(abs(kernel.k_f)==max(abs(kernel.k_f)));
  sgn = sign(kernel.k_f(idx));
  kernel.k_f = kernel.k_f*sgn;
  kernel.k_hd = kernel.k_hd*sgn;
  
  fprintf('done\n');  

