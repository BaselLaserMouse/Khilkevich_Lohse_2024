function kernel = sepkernel(X_ft, varargin)
% function kernel = sepkernel(X_ft, varargin)
% 
% Compute separable kernel using sepkerneltensor
%
% Inputs:
%  X_ft -- stimulus, freq x time
%  varargin -- other arguments passed to sepkerneltensor
% 
% Output:
%  kernel.k_f -- frequency kernel
%  kernel.k_h -- history kernel
%  kernel.c_f -- constant term for freq
%  kernel.c_h -- constant term for history

X_fht = tensorize(X_ft, n_h);
kernel = sepkerneltensor(X_fht, varargin);
