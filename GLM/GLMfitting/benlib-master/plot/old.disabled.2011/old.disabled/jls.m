function result = jls(pat)
% result = jls(pat)
%
% Jamie's ls() functions -- used to be ls(), but conflicts with
% the matlab builtin -- change to jls 16-feb-2003
% 
% Returns set of file names matching pattern
% if length(result) == 0, then error or no matches..
%
% Thu Feb 17 14:08:39 2000 mazer 


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
end

