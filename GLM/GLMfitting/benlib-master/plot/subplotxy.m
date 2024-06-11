function [x y] = subplotxy(n)
% return number of subplots in x and y for a given number of total plots

root = sqrt(n);
if almostequal(root,round(root))
  x = root;
  y = root;
  return;
end

x = floor(root)+1;
y = ceil(n/x);

  