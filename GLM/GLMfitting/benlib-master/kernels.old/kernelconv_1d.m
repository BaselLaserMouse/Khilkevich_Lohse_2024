function y_t = kernelconv_1d(X_fh_t, kernel)
% function y_t = kernelconv(X_fh_t, kernel)
% 
% Calculate output of inseparable kernel to stimulus X_fh_t
%
% Inputs:
%  X_fh_t -- tensorized, unravelled stimulus, 2d, i.e. (n_f * n_h) by n_t
%  kernel -- kernel containing k_fh_1d, c
% 
% Output:
%  y_t -- response vector

y_t = kernel.c + multiprod(X_fh_t', kernel.k_fh_1d)';
