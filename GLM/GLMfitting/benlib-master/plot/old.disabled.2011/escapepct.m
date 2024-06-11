function y = escapepct(x)
% function y = escapepct(x)
% bw apr 2005
% 
% escape % in a string

f = strfind(x,'%');

y = [];
if length(f)
  p = 1;
  for ii = 1:length(f)
    y = [y x(p:f(ii)) '%'];
    p = f(ii)+1;
  end
  y = [y x(p:end)];
else
  y = x;
end
