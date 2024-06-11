function output = applytodir(funcname,dirname,pauseafter,varargin)

% apply a function to every file in a directory
% bw feb 2005

if ~exist('pauseafter','var')
  pauseafter = 0;
end

if dirname(end)~='/'
  dirname(end+1) = '/';
end

l = jls([dirname, '*.mat']);

output = {};
for ii = 1:length(l)
  fprintf([l{ii} '\n'])
  failed = 0;
  try
    output{ii} = feval(funcname,l{ii},varargin{:});
  catch
    failed = 1;
  end
  if failed==1
    try
      feval(funcname,l{ii},varargin{:});
      output{ii} = [];
    catch
      fprintf('Failed\n');
      output{ii} = nan;
    end
  end
  
  if ~isempty(pauseafter) & pauseafter
    pause;
  end
  
end
