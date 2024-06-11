function qapplytodir(funcname,dirname,varargin)

% apply a function to every file in a directory
% bw feb 2005

[success, dirname] = unix(['cd ' dirname '; pwd']);

dirname(end) = '/';

l = jls([dirname, '*.mat']);

length(varargin)
if ~isempty(varargin)
  argstr = ',';
  for ii = 1:length(varargin)
    % FIXME! only works for numeric arguments
    argstr = [argstr num2str(varargin{ii}) ','];
  end
  argstr = argstr(1:end-1);
else
  argstr = '';
end

for ii = 1:length(l)
  cmdstr = [funcname '(''' l{ii} '''' argstr ')']
  dbaddqueuemaster(cmdstr,cmdstr);
end
