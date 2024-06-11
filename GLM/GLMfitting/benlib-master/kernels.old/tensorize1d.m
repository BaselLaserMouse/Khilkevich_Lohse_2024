function X_ht = tensorize1d(X_t, n_h, lag)
% function X_ht = tensorize1d(X_ht, n_h, lag)
%
% Add a history dimension to a 1D stimulus vector
% FIXME -- pad with nan instead?
%
% Inputs:
%  X_t -- stimulus, over time
%  n_h -- number of history steps
%  lag -- minimum lag
% 
% Outputs:
%  X_ht -- stimulus, freq x history x time

if ~exist('lag', 'var')
  lag = 0;
end

n_f = size(X_t, 1);
n_t = size(X_t, 2);

X_t = X_t(:);

% pad with zeros
X_t = [zeros(n_h, 1); X_t];

n_t_pad = size(X_t, 1);

% preallocate
X_ht = zeros(n_h, n_t_pad);

for ii = 1:n_h
  X_ht(ii,:) = reshape(circshift(X_t, [lag+n_h-ii]), [1, n_t_pad]);
end

X_ht = X_ht(:, n_h+1:end);
