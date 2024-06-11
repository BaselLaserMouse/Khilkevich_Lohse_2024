function batchmode_parallel(fn, filespec, varargin)
% function batchmode(fn, filepattern, varargin)
% 
% Applies a function to all files matching filepattern
% 
% Inputs:
%  fn -- function name or handle
%  filespec -- pattern the files should match, or list of files
%  varargin -- parameters that will be passed to fn
%  ..., 'reverse' or 'flip' -- last argument should be one of these
%    if you want the files to be processed in reverse order

% e.g. batchmode('compute_csdkernel', './metadata/*.mat', 10, 6.25, 6.25)

batchmode(fn, filespec, 'parallel', varargin);

return;

%% no longer used
reverse = false;
if ~isempty(varargin)
  if strcmp(varargin{end}, 'reverse') || strcmp(varargin{end}, 'flip')
    reverse = true;
    varargin = varargin(1:end-1);
  end
  if length(varargin)>1 && strcmpi(varargin{end-1}, 'poolsize')
    poolsize = varargin{end};
    varargin = varargin(1:end-2);
  end
end

% attempt to open a pool
if matlabpool('size') == 0
  if exist('poolsize', 'var')
    matlabpool(poolsize);
  else
    matlabpool;
  end
end

if isstr(fn)
  fnstr = fn;
else
  fnstr = func2str(fn);
end

% create log dir if it doesn't exist
logdir = './batch.log';
if ~exist(logdir, 'dir')
  mkdir(logdir);
end

% overcomplicated formatting of parameters for printing in log file
paramsdot = [];
paramscomma = [];
for ii = 1:length(varargin)
  if isstr(varargin{ii})
    pstr = varargin{ii};
    paramsdot = [paramsdot pstr '.'];
    paramscomma = [paramscomma ', ''' pstr ''''];
  elseif isnumeric(varargin{ii}) && isscalar(varargin{ii})
    pstr = num2str(varargin{ii});
    paramsdot = [paramsdot pstr '.'];
    paramscomma = [paramscomma ', ' pstr];
  else
    pstr = '.';
  end
end

% logfile filename
logfile = [logdir filesep datestr(now, 'yyyy.mm.dd_HH.MM') '.' ...
	   fnstr '.' paramsdot 'log'];
	   
% start saving output to logfile
diary(logfile);

% find files matching filespec (unless it is already a list)
if isstr(filespec)
  files = getfilesmatching(filespec);
else
  files = filespec;
end

% reverse order in which files will be processed
if reverse
  files = flipud(files);
end

% do it
nargs = nargout(fn);
result = {};

% loop through files
parfor ii = 1:length(files)
  diary on;
  file = files{ii};
  fprintf(['== Running ' fnstr '(''' file '''' paramscomma ') ...\n']);

  try
    feval(fn, file, varargin{:});
  catch
    fprintf('failed!\n');
  end

  diary off;
end
