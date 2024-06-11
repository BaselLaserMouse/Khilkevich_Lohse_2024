function varargout = batchmode(fn, filespec, varargin)
% function batchmode(fn, filepattern, varargin)
% 
% Applies a function, fn,  to all files matching filepattern (with extra
% parameters varargin{:}), optionally in parallel on multiple workers in 
% a matlab pool.
% 
% Inputs:
%  fn -- function name or handle (or cell array of either)
%  filespec -- pattern the files should match, or list of files
%  varargin -- parameters that will be passed to fn
%  ..., 'reverse' or 'flip' -- process commands in reverse order
%  ..., 'parallel' -- open a local matlabpool and use parfor to process
%  ..., 'noparallel' -- don't
%  ..., 'pause' -- pause after each iteration (ignored if parallel=true)
%  ..., 'poolsize', n -- restrict matlabpool size to n
%
%  If fn is a cell array, varargin should have length 0 (no parameters)
%  or 1, in which case varargin{1} is a cell array of parameters to be 
%  passed to each of the functions specified in fn. This is useful when
%  running in parallel because it stops the cluster running out of jobs
%  when 1 job in a batch is very slow.
% 
%  By default, parallel=true if matlab is running with -nodisplay; otherwise
%  parallel=false, but both can be overridden.
% 
% Outputs:
%  varargout{1} = a cell array of outputs from the jobs only if parallel=false
%  If parallel=true, there is no output
% 
% Examples:
% Single batch, no output:
% batchmode('compute_csdkernel', './metadata/*.mat', 10, 6.25, 6.25);
%
% Single batch, with output:
% results = batchmode('getvar', './metadata/*.mat', 'results');
% 
% Multiple batches
% batchmode({'compute_csdkernel'; 'compute_csdkernel2'}, ...
%                 './metadata/*.mat', {{10, 6.25, 6.25}, {15, 12.5, 12.}});

% default parameters
reverse = false;
shouldPause = false;
if feature('ShowFigureWindows')
  % by default, use parallel processing if matlab was called with -nodisplay
  parallel = false;
else
  % by default, otherwise, no parallel
  parallel = true;
end
poolsize = Inf;

% parse parameters by working backwards until we no longer recognise 
% the parameter as a special one; of course this means that the last parameter
% passed to fn can't be a member of this set
done = false;
while ~isempty(varargin) && ~done
  if isstr(varargin{end}) || isscalar(varargin{end})
    if strcmp(varargin{end}, 'reverse') || strcmp(varargin{end}, 'flip')
      reverse = true;
      varargin = varargin(1:end-1);
    elseif strcmp(varargin{end}, 'pause')
      % ignored if parallel==true
      shouldPause = true;
      varargin = varargin(1:end-1);
    elseif strcmp(varargin{end}, 'parallel')
      parallel = true;
      varargin = varargin(1:end-1);
    elseif strcmp(varargin{end}, 'noparallel')
      parallel = false;
      varargin = varargin(1:end-1);
    elseif length(varargin)>1 && strcmpi(varargin{end-1}, 'poolsize')
      poolsize = varargin{end};
      varargin = varargin(1:end-2);
    else
      done = true;
    end
  else
    done = true;
  end
end

% print the parameters
falsetrue = {'false','true'};
fprintf('parallel=%s, pause=%s, reverse=%s, poolsize=%d\n', ...
  falsetrue{parallel+1}, falsetrue{shouldPause+1}, falsetrue{reverse+1}, poolsize);

% open a pool if necessary
if parallel
  % attempt to open a pool
  if matlabpool('size') ~= 0
    matlabpool close;
  end

  if isinf(poolsize)
    matlabpool;
  else
    matlabpool(poolsize);
  end

  pause(2);
end 

% parse the function names and arguments
if isa(fn, 'function_handle')
  % then we have a single function 
  fns = {fn};
  args = {varargin};
elseif isstr(fn)
  % then we have a single function 
  fns = {str2func(fn)};
  args = {varargin};
elseif iscell(fn)
  % then we have a cell array of functions
  fns = {};
  for ii = 1:length(fn)
    if isa(fn, 'function_handle')
      fns{ii} = fn{ii};
    else
      fns{ii} = str2func(fn{ii});
    end
  end
  assert(length(varargin)<=1);
  args = varargin{1};
end

% find files matching filespec (unless it is already a list)
if isstr(filespec)
  files = getfilesmatching(filespec);
else
  files = filespec;
end

% construct a list of commands to be executed
cmds = {};
for fnIdx = 1:length(fns)
  fn = fns{fnIdx};
  fnstr = func2str(fn);
  
  if isempty(args)
    arg = {};
  else
    arg = args{fnIdx};
  end
  
  for fileIdx = 1:length(files)
    file = files{fileIdx};

    cmd = struct;
    cmd.cell = {fn, file, arg{:}};
    cmd.fnstr = fnstr;

    % overcomplicated formatting of parameters for printing in log file
    paramsdot = [];
    paramscomma = [];
    for ii = 1:length(arg)
      if isstr(arg{ii})
        pstr = arg{ii};
        paramsdot = [paramsdot pstr '.'];
        paramscomma = [paramscomma ', ''' pstr ''''];
      elseif isnumeric(arg{ii}) && isscalar(arg{ii})
        pstr = num2str(arg{ii});
        paramsdot = [paramsdot pstr '.'];
        paramscomma = [paramscomma ', ' pstr];
      else
        pstr = '.';
      end
    end
    cmd.strdot = sprintf('%s.%s', func2str(fn), paramsdot);
    if isempty(paramscomma)
      cmd.strcomma = sprintf('%s(''%s'')', fnstr, file);
    else
      cmd.strcomma = sprintf('%s(''%s''%s)', fnstr, file, paramscomma);
    end
    cmds{end+1} = cmd;
  end
end
cmds = [cmds{:}];

% create log dir if it doesn't exist
logdir = './batch.log';
if ~exist(logdir, 'dir')
  mkdir(logdir);
end

% logfile filename
if length(fns)==1
  logfile = [logdir filesep datestr(now, 'yyyy.mm.dd_HH.MM') '.' ...
	   cmds(1).strdot 'log'];
else
  logfile = [logdir filesep datestr(now, 'yyyy.mm.dd_HH.MM') '.multiple.log'];
end

% start saving output to logfile
diary(logfile);

% reverse the order in which files will be processed
if reverse
  cmds = flipud(cmds);
end

%% execute the commands in cmds
nargs = nargout(fn);
result = {};

% loop through cmds
if ~parallel
  % not parallel

  for ii = 1:length(cmds)
    cmd = cmds(ii);

    fprintf('== %s: Running %s ...\n', datestr(now, 'yyyy.mm.dd HH.MM'), cmd.strcomma);

    try
      if nargs==0
        feval(cmd.cell{:});
      elseif nargs<0 || nargs==1
        out = feval(cmd.cell{:});
        result{end+1} = out;
      else
        [out{1:nargs}] = feval(cmd.cell{:});
        result{end+1} = out;
      end
      
      fprintf('=> %s: success\n\n', cmd.strcomma);

    catch
      warning(lasterr);
      fprintf('=> %s: failure\n\n', cmd.strcomma);

    end

    if shouldPause;
        fprintf('Pausing...')
        pause;
        fprintf('\n');
    end
  end

else
  % parallel

  parfor ii = 1:length(cmds)

    if ii==length(files)
      fprintf('II Queueing last job\n');
    end

    t = getCurrentTask();
    worker = t.ID;

    cmd = cmds(ii);
    fprintf('== %s, Lab %d: Running %s ...\n', datestr(now, 'yyyy.mm.dd HH.MM'), worker, cmd.strcomma);

    try
      feval(cmd.cell{:});    
      fprintf('=> %s Lab %d: %s -> success\n\n', datestr(now, 'yyyy.mm.dd HH.MM'), worker, cmd.strcomma);

    catch
      warning(lasterr);
      fprintf('=> %s Lab %d: %s -> failure\n\n', datestr(now, 'yyyy.mm.dd HH.MM'), worker, cmd.strcomma);

    end

  end

end

diary off;

if length(result)
 [varargout{1:nargout}] = result;
end
