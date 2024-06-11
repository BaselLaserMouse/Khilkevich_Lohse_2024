function b = circshift(a,p)
%CIRCSHIFT Shift array circularly.
%   B = CIRCSHIFT(A,SHIFTSIZE) circularly shifts the values in the array A
%   by SHIFTSIZE elements. SHIFTSIZE is a vector of integer scalars where
%   the N-th element specifies the shift amount for the N-th dimension of
%   array A. If an element in SHIFTSIZE is positive, the values of A are
%   shifted down (or to the right). If it is negative, the values of A
%   are shifted up (or to the left).
%
%   Class Support
%   -------------
%   A can be of any class.  B is of the same class as A.
%
%   Example
%   -------
%   A = [ 1 2 3;4 5 6; 7 8 9];
%   B = circshift(A,1);% circularly shifts first dimension values down by 1.
%   B =     7     8     9
%           1     2     3
%           4     5     6
%
%   B = circshift(A,[1 -1]);% circularly shifts first dimension values
%                           % down by 1 and second dimension left by 1.
%   B =     8     9     7
%           2     3     1
%           5     6     4
%
%   See also FFTSHIFT.

%   Copyright 1993-2001 The MathWorks, Inc.  
%   $Revision: 1.7 $  $Date: 2001/01/18 15:28:41 $

if (nargin~=2)
    error('There should be two input arguments.');
end

[p, sizeA, numDimsA, msg] = ParseInputs(a,p);
if (~isempty(msg))
    error(msg);
end

idx = cell(1, numDimsA);
for k = 1:numDimsA
    m      = sizeA(k);
    idx{k} = mod((0:m-1)-p(k), m)+1;
end

b = a(idx{:});


%%%
%%% Parse inputs
%%%
function [p, sizeA, numDimsA, msg] = ParseInputs(a,p)

% default values
sizeA    = size(a);
numDimsA = ndims(a);
msg      = '';

sh        = p(:);
isFinite  = all(isfinite(sh));
isInteger = all(isa(sh,'double') & (imag(sh)==0) & (sh==round(sh)));
isVector  = ((ndims(p) == 2) & ((size(p,1) == 1) | (size(p,2) == 1)));

if ~(isFinite & isInteger & isVector)
    msg = 'Invalid shift type: must be a finite, real integer vector.';
    return;
end

% Make sure the shift vector has the same length as numDimsA. 
% The missing shift values are assumed to be 0. The extra 
% shift values are ignored when the shift vector is longer 
% than numDimsA.
if (prod(size(p)) < numDimsA)
   p(numDimsA) = 0;
end



%
% Part of BeamLab Version:200
% Built:Friday,23-Aug-2002 00:00:00
% This is Copyrighted Material
% For Copying permissions see COPYING.m
% Comments? e-mail beamlab@stat.stanford.edu
%
%
% Part of BeamLab Version:200
% Built:Saturday,14-Sep-2002 00:00:00
% This is Copyrighted Material
% For Copying permissions see COPYING.m
% Comments? e-mail beamlab@stat.stanford.edu
%