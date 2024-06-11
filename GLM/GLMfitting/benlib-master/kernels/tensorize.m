function X_fht = tensorize(X_ft, n_h, lag)
% function X_fht = tensorize(X_ft, n_h, lag)
%
% Add a history dimension to a 2D stimulus grid
% FIXME -- pad with nan instead?
%
% Inputs:
%  X_ft -- stimulus, freq x time
%  n_h -- number of history steps
%  lag -- minimum lag
% 
% Outputs:
%  X_fht -- stimulus, freq x history x time

if ~exist('lag', 'var')
  lag = 0;
end

n_f = size(X_ft, 1);
n_t = size(X_ft, 2);

% pad with zeros
X_ft = [zeros(n_f, n_h) X_ft];

n_t_pad = size(X_ft, 2);

% preallocate
X_fht = zeros(n_f, n_h, n_t_pad);

for ii = 1:n_h
  X_fht(:,ii,:) = reshape(circshift(X_ft, [0 lag+n_h-ii]), [n_f, 1, n_t_pad]);
end

X_fht = X_fht(:, :, n_h+1:end);
