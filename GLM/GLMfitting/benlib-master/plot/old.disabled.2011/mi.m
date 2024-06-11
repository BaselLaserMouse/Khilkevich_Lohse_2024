function y = mi(x,y,xbin,ybin,display)

if ~exist('display','var')
  display = false;
end

px = histc(x,xbin);
px = px/sum(px);

py = histc(y,ybin);
py = py/sum(py);

pxy = hist3([x; y]','Edges',{xbin,ybin});
pxy = pxy/sum(pxy(:));

pxyi = px'*py;
pxyi = pxyi/sum(pxyi(:));

y = nansum(nansum(pxy.*log2(pxy./pxyi)));

if display
  subplot(2,1,1);
  imagesc(pxy);
  subplot(2,1,2);
  imagesc(pxyi);
end