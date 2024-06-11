function [beta, k, xcs, beta_history, k_history, fitidx, validx] = blasso_bw4(X, Y, params, Xp, Yp)
    % function beta, k, xcs, beta_history, k_history] = blasso_bw4(X, Y, params, Xp, Yp)
    %
    % main boosting core code
    %   - original: bw 2006-11
    %   - updated: ncr 2008-05-28
    %   - 2008-08-28 -- allow for interruptions
    %   - 2012-08-02 -- BW -- deals with standardisation of data (and kernels), so you 
    %                          don't need to standardise input
    %                      -- returns the whole lasso path (as far as it is estimated)
    %                           in beta_history
    %                      -- chooses data for fitting regularisation parameter (Xv) itself
    %
    % inputs:
    %   - X is samples x channels
    %   - Y is samples x 1
    %   - Xp, Yp: data for prediction
    %
    %
    % outputs:
    %   - beta: predictor matrix
    %   - xcs: vector of correlation coefficients
    %       [xc_training xc_validation xc_prediction]
    %
    % NB: this is compact mode for batch processing -- see B5_STRFs

    
%% optional inputs and parameters
    if ~exist('params','var') | isempty(params)
      params = struct;
    end

    if ~isfield(params, 'valprop')
      % proportion of data to use for validation set
      params.valprop = 0.1;
    end
    
    if ~isfield(params,'allowinterrupts')
        params.allowinterrupts = 0;
    end

    if params.allowinterrupts
        global JOB_INTERRUPT; %#ok<TLEV>
    end

    if ~isfield(params,'earlystop')
      params.earlystop = 0;
    end

    if ~isfield(params, 'maxiter')
      params.maxiter = +Inf;
    end

    if ~isfield(params,'maxlag') | isempty(params.maxlag)
      lags = 1;
    else
      lags = (params.maxlag(1):params.maxlag(2))+1;
    end

    if ~isfield(params,'l2boost')
      params.l2boost = 0; % default to blasso
    end  

    if ~isfield(params,'display_xcs_full')
      params.display_xcs_full = 0;
    end
    
    if ~isfield(params,'display_xcs_short')
      params.display_xcs_short = 1;
    end

    if ~isfield(params,'display_kernel')
      params.display_kernel = 0;
    end

    if ~isfield(params,'display_print')
        params.display_print = 0;
    end
    
    % step size. should be about 1/1000th of the SD of Y (which is 1)
        epsilon = getparm(params,'epsilon',0.01);

    % fudge factor which prevents oscillations.  good values seem to be
    % about 1/10000th of epsilon
        xi = getparm(params,'xi',1e-6) * epsilon;
        
    % suppress printouts?
        suppress_display = getparm(params,'suppress_display',0);
        if suppress_display
            params.display_print = 0;
            params.display_kernel = 0;
            params.display_xcs_short = 0;
            params.display_xcs_full = 0;
        else
            if params.l2boost
              fprintf('Using L2Boost\n');
            else
              fprintf('Using BLasso\n');
            end
        end


    if ~exist('Yv','var') || isempty(Yv)
      Xv = zeros(1,size(X,2));
      Yv = nan;
    end

    if ~exist('Yp','var') || isempty(Yp)
      Xp = zeros(1,size(X,2));
      Yp = nan;
    end

%% split X and Y into fit and validation sets
%% fit set will be used to do the regression
%% validation set will be used to choose the regularisation parameter
rand('seed', 110876);
n = size(X, 1);
idx = randperm(n);

n_fit = floor((1-params.valprop)*n);
fitidx = idx(1:n_fit);
validx = idx(n_fit+1:end);

Xf = X(fitidx, :);
Yf = Y(fitidx, :);

Xv = X(validx, :);
Yv = Y(validx, :);

X = Xf;
Y = Yf;


%% standardisation of X and Y
%% The algorithm uses correlation coefficient to choose which steps to take
%% This only works if mean(X_i)=0 and std(X_i)=1. I don't think it's strictly
%% necessary to standardise Y, but it helps when choosing step size (epsilon).
%% Note that Xv and Xp need to undergo exactly the same transformation as X.
%% Similarly for Yv and Yp.

X_mn = mean(X, 1);
X_sd = std(X, [], 1);

for ii = 1:size(X, 2)
  X(:, ii) = X(:, ii) - X_mn(ii);
  X(:, ii) = X(:, ii) / X_sd(ii);

  if isfinite(Yv)
    Xv(:, ii) = Xv(:, ii) - X_mn(ii);
    Xv(:, ii) = Xv(:, ii) / X_sd(ii);
  end

  if isfinite(Yp)
    Xp(:, ii) = Xp(:, ii) - X_mn(ii);
    Xp(:, ii) = Xp(:, ii) / X_sd(ii);
  end

end

y_mn = mean(Y);
y_sd = std(Y);

Y = Y - y_mn;
Y = Y / y_sd;

if isfinite(Yv)
  Yv = Yv - y_mn;
  Yv = Yv / y_sd;
end

if isfinite(Yp)
  Yp = Yp - y_mn;
  Yp = Yp / y_sd;
end

    
%% initial parameters    

    lambda = +Inf;

    X_sz    = size(X,1);

    Y_hat   = zeros(size(Y));
    Y_resid = Y;

    Yv_hat  = zeros(size(Yv));
    Yp_hat  = zeros(size(Yp));

    beta    = zeros(size(X,2),length(lags));

    beta_history = zeros([size(beta,1) size(beta,2) 0]);
    xc_history   = [];
    mse_history  = [];

    t = 0;

    n_bwd = 0;
    n_fwd = 0;

    stop = 0;
    
    tic;


    
%% main while loop

while lambda>=0 && ~stop
    
  % test for interrupt every 500ms, if requested
  % --------------------------------------------
  if params.allowinterrupts
    if toc > 0.5
      pause(0.01);
      switch JOB_INTERRUPT
        case 1
          error('interrupt:delay','wait for a while');
        case 2
          error('interrupt:quit','exit rfjobclient altogether');
        otherwise
      end
      tic;
    end
  end          

  % calculate dot products between learners and residals
  % ----------------------------------------------------  
  for lagnum = 1:length(lags)
    padding = zeros(lags(lagnum)-1,1);
    XY(:,lagnum) = ([Y_resid(lagnum:end); padding])' * X; %#ok<AGROW>
  end


  % calculate best forward step
  % ---------------------------
      % best forward step (for L2 loss) is the one with the highest dot product
      % (or most negative dot product). to prove it, write out the L2
      % loss and remove terms that are constant. NB this only works
      % when the library resps have mean=0 and SD=1.
      [j_fwd,l_fwd] = find(abs(XY)==max(abs(XY(:))));
      j_fwd = j_fwd(1);
      l_fwd = l_fwd(1);
      s_fwd = epsilon * sign(XY(j_fwd,l_fwd));

  % calculate best backward step
  % -----------------------------
      % if there's no backward step, make the backward step infinitely bad
      if sum(abs(beta(:)))==0 | params.l2boost
        L_t   = 0;
        L_tst = +Inf;

      else
        % best backward step (for L2 loss) is the one which is least
        % correlated with the residuals
        XY_bwd = XY.*sign(beta);
        XY_bwd(sign(beta)==0) = nan;
        [j_bwd,l_bwd] = find(XY_bwd==nanmin(XY_bwd(:)));
        j_bwd = j_bwd(1);
        l_bwd = l_bwd(1);
        s_bwd = -epsilon * sign(beta(j_bwd,l_bwd));

        % does backward step improve lasso loss?
        beta_tst = beta;
        beta_tst(j_bwd,l_bwd) = beta(j_bwd,l_bwd) + s_bwd;
        padding = zeros(lags(l_bwd)-1,1);
        Y_hat_tst = Y_hat + s_bwd * [padding; X(1:end-lags(l_bwd)+1,j_bwd)];
        Y_resid_tst = Y - Y_hat_tst;
        Yv_hat_tst= Yv_hat + s_bwd * [padding; Xv(1:end-lags(l_bwd)+1,j_bwd)];
        Yp_hat_tst= Yp_hat + s_bwd * [padding; Xp(1:end-lags(l_bwd)+1,j_bwd)];

        L_t   = sum(Y_resid.^2) + lambda * sum(abs(beta(:)));
        L_tst = sum(Y_resid_tst.^2) + lambda * sum(abs(beta_tst(:)));

      end
      
  % choose whether to take forward or backward step
  % -----------------------------------------------
      if (L_tst-L_t) < -xi
        % take backward step...
        %fprintf('bwd\n');
        n_bwd = n_bwd + 1;
        beta    = beta_tst;
        Y_hat   = Y_hat_tst;
        Y_resid = Y_resid_tst;
        Yv_hat  = Yv_hat_tst;
        Yp_hat  = Yp_hat_tst;

      else
        % take forward step ...
        %fprintf('fwd\n');
        n_fwd = n_fwd + 1;
        Y_resid_prev = Y_resid;
        beta(j_fwd,l_fwd) = beta(j_fwd,l_fwd) + s_fwd;
        padding = zeros(lags(l_fwd)-1,1);
        Y_hat       = Y_hat + s_fwd * [padding; X(1:end-lags(l_fwd)+1,j_fwd)];
        Y_resid     = Y - Y_hat;
        Yv_hat      = Yv_hat + s_fwd * [padding; Xv(1:end-lags(l_fwd)+1,j_fwd)];
        Yp_hat      = Yp_hat + s_fwd * [padding; Xp(1:end-lags(l_fwd)+1,j_fwd)];

        % ... and update lambda
        lambda_tst = 1/epsilon * (sum(Y_resid_prev.^2) - sum(Y_resid.^2));
        lambda = min(lambda,lambda_tst);
      end
   
  l1 = round(sum(abs(beta(:)))/epsilon);
  beta_history(:,:,l1) = beta;
  
  % evaluate current model
  % ----------------------
      warning off MATLAB:divideByZero;
      %fitxc   = nanxc(Y,Y_hat);
      %valxc   = nanxc(Yv,Yv_hat);
      %predxc  = nanxc(Yp,Yp_hat);
        fitxc = quickcc(Y,Y_hat);
        valxc = quickcc(Yv,Yv_hat);
        predxc= quickcc(Yp,Yp_hat);
      warning on MATLAB:divideByZero;
      xc_history(l1, :)  = [fitxc valxc predxc]; %#ok<AGROW>
  
  % display, if requested
  
      if params.display_print
        if l1>1
            fprintf(['L1 norm = ' num2str(l1-1) '\n']);
            fprintf(['XCs = ' num2str(xc_history(l1-1,:)) '\n']);
        end
      end

      if params.display_xcs_full
        % generate mean standard error history
        fitmse  = mean((Y-Y_hat).^2);
        valmse  = nanmean((Yv-Yv_hat).^2);
        predmse = nanmean((Yp-Yp_hat).^2);
        mse_history(l1,:) = [fitmse valmse predmse]; %#ok<AGROW>

        figure(1);
        subplot(3,1,1);
            plot(xc_history);
            title([num2str(xc_history(end,1)) ' ' num2str(xc_history(end,2)) ...
             ' ' num2str(xc_history(end,3))]);
        subplot(3,1,2);
            plot(mse_history);
            title([num2str(mse_history(end,1)) ' ' num2str(mse_history(end,2)) ...
               ' ' num2str(mse_history(end,3))]);
        subplot(3,1,3);
            plot(1:length(Yv),Yv,'b',1:length(Yv),Yv_hat,'g');
        drawnow;
      end
      
      if params.display_xcs_short
        figure(1);
        subplot(1,1,1);
            plot(xc_history);
            title([num2str(xc_history(end,1)) ' ' num2str(xc_history(end,2)) ...
             ' ' num2str(xc_history(end,3))]);
      end

      
      if params.display_kernel && mod(size(beta_history,3), 50)==0
        figure(2);
        if size(beta_history,3)==1
          bh_tmp = beta_history;
        else
          bh_tmp = reshape(beta_history,size(beta_history,1)* ...
                   size(beta_history,2), size(beta_history,3));
        end

        beta_ind = find(abs(bh_tmp(:,end))>0);
        size(beta_ind)
        if size(beta_ind,1) >0
          plot((bh_tmp(beta_ind,:))'/epsilon);
          ylabel(num2str(length(find(abs(beta(:))>0))));
        end

        figure(3);
        mx = max(abs(beta_history(:,:, end)));
        imagesc(reshape(beta_history(:,:,end), 25, 23)');
        drawnow;

      end

  % if early stopping, is it time to stop?
      if params.earlystop & l1>200 & ...
        (max(xc_history(1:l1-1,2))-xc_history(l1-1,2))>.01
        % last converged estimate was more than 0.01 worse than the
        % best-ever validation xc.  we're unlikely to get that much better
        % again, so:
        stop = 1;
      end

      if l1>params.maxiter
        stop = 1;
      end

% run cycle again
end

%% to output

%% we need to convert the kernel back into un-normalised space

% we have fit the equation of a line where y' = m'_i x'_i + k' (actually k' = 0)
% and y' = (y-mu_y)/sigma_y and x'_i = (x_i - mu_xi)/sigma_xi
% by substitution and simplification, we can get y = m_i x_i + k
% where,
% kernel coefficients m_i = (sigma_y/sigma_xi)* m'_i
% offset k = mu_y + k'*sigma_y - sigma_y * Sum((m'_i * mu_xi)/sigma_xi)
% actually k' = 0, since we fit y' = m'x', not y' = m'x' + k'

k = nan(1, size(beta_history, 3));
for beta_idx = 1:size(beta_history, 3)
  m_dash = beta_history(:, :, beta_idx);
  m = y_sd ./ repmat(X_sd', [1, lags]) .* m_dash;
  beta_history(:, :, beta_idx) = m;
  k(beta_idx) = y_mn - y_sd * sum((m_dash .* repmat(X_mn', [1, lags]))./repmat(X_sd', [1, lags]));
end

k_history = k;

   if any(isfinite(xc_history(:,2)))
      %% choose best kernel based on validation data
      %% the 'best' is the one with the highest value of xc_val
      quality = xc_history(:, 2);
      best_l1 = find(quality==max(quality), 1);
      %best_l1 = find(xc_history(:,2)==max(xc_history(:,2)));
      %best_l1 = best_l1(1);
    else
      best_l1 = size(xc_history, 1);
    end

    beta = beta_history(:,:,best_l1);
    k = k_history(best_l1);
    
    if ~suppress_display
        fprintf(['Best L1  = ' num2str(best_l1) '\n']);
        fprintf(['Best XCs = ' num2str(xc_history(best_l1,:)) '\n']);
        fprintf(['Number of steps (fwd, bwd) = ' num2str([n_fwd n_bwd]) '\n']);
    end

    beta = beta_history(:,:,best_l1);
    xcs = xc_history(best_l1,:);

end