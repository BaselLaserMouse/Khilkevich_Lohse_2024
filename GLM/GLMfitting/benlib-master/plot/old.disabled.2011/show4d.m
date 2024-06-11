function h=show4d(A,range,cmap,fixzero,independent)

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

for ii = 1:size(A,3)
  for jj = 1:size(A,4)
  subplotbw(size(A,4),size(A,3),ii+(jj-1)*size(A,3),0.05);
  show(A(:,:,ii,jj),range,cmap,fixzero);
  end
end


