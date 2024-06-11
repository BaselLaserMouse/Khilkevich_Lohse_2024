function y = truthtable(base)
% function y = truthtable(base)
% willmore apr 2005
%
% make a truth table, i.e. a matrix where every value on every
% dimension is sampled.
% base is a vector specifying the base of each column. e.g. [2 2]
% gives a standard 4-row table; [3 2] gives a 6-row table
% non-integer bases not supported :-)

y = [];
for ii = 1:length(base)
  y = truthtable_addrow(y,base(ii));
end

% -------

function y = truthtable_addrow(y,base)

if isempty(y)
  y = (1:base)'-1;
else
  new = ceil((1:base*length(y))/length(y))'-1;
  y = [new repmat(y,[base 1])];
end
