function y_dt = sepcsdconv(X_fht, kernel)
% function y_t = sepconv(X_fht, kernel)
% 
% Calculate output of separable CSD kernel to stimulus X_fht
%
% Inputs:
%  X_fht -- tensorized stimulus
%  kernel -- separable kernel containing k_f, k_hd, c_f, c_d
% 
% Output:
%  y_dt -- response matrix, depth x time

% deal with constant terms
X_fht(end+1, end+1, :) = 1;

k_f = [kernel.k_f; kernel.c_f];
k_hd = [kernel.k_hd; kernel.c_d];

[n_f, n_h, n_t] = size(X_fht);

n_d = size(k_hd, 2);
n_hd = n_h * n_d;

%X_fh1t = reshape(X_fht,[n_f, n_h, 1, n_t]);

%b_fhdt = X_fh1t .* repmat(k_f, [1 n_h 1 n_t]);
%b_1hdt = sum(b_fhdt, 1);
%b_ht = reshape(b_1hdt(:,:,1,:), [n_h n_t]);

b_ht = squeeze(multiprod(X_fht, k_f, 1));

y_dt = zeros(n_d, n_t);  
for jj = 1:n_d
  y_dt(jj,:) = sum(b_ht.*repmat(k_hd(:,jj),[1 n_t]), 1);
end
