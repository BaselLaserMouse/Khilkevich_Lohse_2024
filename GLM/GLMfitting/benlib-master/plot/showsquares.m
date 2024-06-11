function h=showsquares(A, n_x, independent)

[side_y, side_x, n_squares] = size(A);

if ~exist('n_x', 'var') || isempty(n_x)
  n_x = ceil(sqrt(n_squares));
end
n_squares, n_x, ceil(n_squares/n_x)
n_y = ceil(n_squares/n_x);

if ~exist('independent','var')
  independent = true;
end

maxabs = max(abs(A(:)));

B = zeros(n_y * side_y, n_x * side_x);
for count = 1:n_squares
  [xo, yo] = ind2sub([n_x n_y],count);
  yo = (yo-1)*side_y+1;
  xo = (xo-1)*side_x+1;
  data = A(:,:,count);

  if independent
    maxabs = max(abs(data(:)));
    data = data/maxabs;
  end

  B(yo:yo+side_y-1,xo:xo+side_x-1) = data;
end
B = B / max(abs(B(:)));
imagesc0(B);
colormap(redbluemap);

hold on;
for count = 1:n_squares
  [xo, yo] = ind2sub([n_x n_y],count);
  yo = (yo-1)*side_y+.5;
  xo = (xo-1)*side_x+.5;
  h2=line([xo xo xo+side_x xo+side_x xo],[yo yo+side_y yo+side_y yo yo]);
  set(h2,'Color',[0 0 0]);
end
hold off;
