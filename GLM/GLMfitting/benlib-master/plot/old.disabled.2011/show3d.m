function h=show3d(A,range,cmap,fixzero,independent)

if ~exist('range','var')
  mx = max(abs(A(:)));
  range = [-mx mx];
end
if ~exist('cmap','var')
  cmap = [];
end
if ~exist('fixzero','var')
  fixzero = [];
end
if exist('independent','var')
  if independent
    range = [];
  end
end

num = size(A,3);
side= ceil(sqrt(num));

for ii = 1:num
  subplotbw(side,side,ii);
  show(A(:,:,ii),range,cmap,fixzero);
end

