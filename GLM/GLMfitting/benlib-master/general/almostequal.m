function bool = almostequal(x,y)
% function bool = almostequal(x,y)
%
% Check whether two matrices are equal to within
% matlab's tolerance (eps)
%
% Inputs:
%  x, y -- matrices
% 
% Output:
%  1 if x and y are identical to within eps
%  0 otherwise

bool = all(abs(x-y)<eps(x));
