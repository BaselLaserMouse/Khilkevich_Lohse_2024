function result = p2m_dir(pat,nop2m)
% this is jls() from jamie's toolbox -- matlab's dir() function
% is fucked -- this one returns a list of filenames without loosing
% the directory names..
% set nop2m true if you don't want to attempt to convert files
% which are already p2ms

if nargin == 1
  nop2m = 0;
end

[ecode, x] = unix(sprintf('/bin/ls -1 %s', pat));
result = {};
if ecode == 0
  nl = find(x == 10);
  a = 1;
  n = 1;
  for ix=1:length(nl)
    b = nl(ix)-1;
    result{n} = x(a:b);
    a = b + 2;
    n = n + 1;
  end
  
  if nop2m
    newresult = {};
    for ix=1:length(result)
      if ~strcmp(result{ix}(end-3:end),'.p2m')
	newresult{end+1} = result{ix};
      end
    end
  result = newresult;
  end
end

