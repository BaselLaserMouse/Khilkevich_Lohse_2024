function l=ls(varargin)
%LS List directory.
%   LS displays the results of the 'ls' command on UNIX.  You can
%   pass any flags to LS as well that your operating system supports.
%   On UNIX, ls returns a \n delimited string of file names.
%
%   On all other platforms, LS executes DIR and takes at most one input
%   argument. 
%
%   See also DIR.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.17 $  $Date: 2002/04/08 20:51:22 $

% validate input parameters
if iscellstr(varargin)
    args = strcat(varargin,{' '});
else
    error('Inputs must be strings.');
end

% perform platform specific directory listing
if isunix
    if nargin == 0
        [s,l] = unix('ls');
    else
        [s,l] = unix(['ls ', args{:}]);
    end
else
    if nargout > 0
        error('Too many output arguments.')
    end
    
    if nargin == 0
        dir;
    elseif nargin == 1
        dir(varargin{1});
    else
        error('Too many input arguments.')
    end
    
end
