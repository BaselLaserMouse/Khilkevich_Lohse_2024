function h=showrows(A,range,cmap,fixzero,independent,quick)

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
if ~exist('quick','var')
  quick = false;
end

num = size(A,1);
side= ceil(sqrt(num));
sz  = sqrt(size(A,2));

if ~quick
  for ii = 1:num
    subplot(side,side,ii);
    show(reshape(A(ii,:),sz,sz),range,cmap,fixzero);
  end
  
else
  B = zeros(side*sz);
  for count = 1:num
    [xo, yo] = ind2sub([side side],count);
    yo = (yo-1)*sz+1;
    xo = (xo-1)*sz+1;
    data = reshape(A(count,:),[sz sz]);
    if independent
      data = data-min(data(:));
      data = data/max(data(:));
    end
    B(yo:yo+sz-1,xo:xo+sz-1) = data;
  end
  B = B-min(B(:));
  B = B/max(B(:));
  show(B);
  
  hold on;
  for count = 1:num
    [xo, yo] = ind2sub([side side],count);
    yo = (yo-1)*sz+.5;
    xo = (xo-1)*sz+.5;
    h2=line([xo xo xo+sz xo+sz xo],[yo yo+sz yo+sz yo yo]);
    set(h2,'Color',[0 0 0]);
  end
  hold off;
end
